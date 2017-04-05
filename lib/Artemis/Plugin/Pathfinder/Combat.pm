package Artemis::Plugin::Pathfinder::Combat;

use strict;
use warnings;

use Time::HiRes qw(sleep);
use Games::Dice qw(roll);
use AnyEvent;
use File::Path qw(make_path remove_tree);

use Artemis::Plugin::Pathfinder::Combat::Turn;

use base 'Artemis::Role::Debug';

sub new {
    my $class = shift;
    my $args  = shift || { };
    my $self = bless $args, $class;

    mkdir $self->pid_queue_dir;

    return $self;
}

sub DESTROY {
    my $self = shift;
    my $dir  = $self->pid_queue_dir;
    warn "Trouble removing pid_queue_dir [$dir]?\n" unless remove_tree($dir);
}

sub queue_dir {
    my $self = shift;
    $self->{'queue_dir'} ||= shift if scalar @_;
    return $self->{'queue_dir'} || die 'queue_dir missing';
}

sub pid_queue_dir {
    my $self = shift;
    $self->queue_dir.'/'.$$;
}

sub status {
    my $self = shift;
    if(scalar @_) {
        my $s = $self->{'status'} = shift;
        my $sub = (caller(1))[3];
        $self->debug($s->{'msg'}, $sub);
    }
    return $self->{'status'} || { msg => 'no status set' };
}

sub  board {
    my $self = shift;
    $self->{'board'} ||= shift if scalar @_;
    return $self->{'board'};# || die 'board missing';
}

sub initiative_check {
    my $self = shift;
    $self->status({pid => $$, msg => 'initiative_check'});
    my %rolls;
    while (my $c = shift) {
        my $key = roll('1d20+'.$c->DEX).'.'.$c->DEX;
        $self->debug("Rolled: ".$c->name." => $key");
        if(exists $rolls{$key}) {
            push @_, delete($rolls{$key});
            push @_, $c;
        }
        else {
            $rolls{ $key } = $c;
        }
        sleep .5 if scalar @_;
    }

    foreach my $roll (keys %rolls) {
        my $c = $rolls{$roll};
        #my $cmd = 'touch '.$self->pid_queue_dir.'/'.$c->id;
        #`$cmd`;
    }

    return \%rolls;
}

sub loop {
    my $self = shift;

    my $initiatives = $self->initiative_check(@_);

    $self->{'t'} = 0;
    while(my @order = sort { $b <=> $a } keys %$initiatives) {
        foreach my $roll (@order) {
            my $t = $self->{'t'}++;
            my $combatant = $initiatives->{$roll};

            $self->status({
                pid  => $$,
                msg  => 'waiting on combatant',
                turn => $t,
                combatant => { id => $combatant->id, name => $combatant->name }
            });
            
            my $turn = $self->wait_on_combatant($combatant, { initiatives => $initiatives });
            
            $self->status({
                pid  => $$,
                msg  => 'processing request for combatant',
                turn => $t,
                combatant => { id => $combatant->id, name => $combatant->name }
            });

            if(!ref($turn) && $turn) {
                last if $turn eq 'EndCombat';
                next if $turn eq 'Skip';
            }
            else {
                # TODO process request
                my $actions = $turn->actions;
                while(my $action = shift(@$actions)) {
                    my $args = shift(@$actions);
                    $self->load_action_class($action)->$action($args, {
                        combatant   => $combatant,
                        initiatives => $initiatives,
                        board       => $self->board
                    });
                }   
            }
        }
    }

    $self->status({
        pid  => $$,
        msg  => 'finished loop',
    });
}

sub load_action_class {
    my $self   = shift;
    my $action = shift;
    my $action_class = "Artemis::Plugin::Pathfinder::Combat::Actions::".join('', map{ ucfirst($_) } split('_', $action));
    (my $file = "$action_class.pm") =~ s{::}{/}g;
    require $file;
    return $action_class;
}

sub combatant_timeout_limit { shift->{'combatant_timeout_limit'} ||= 180 }

sub wait_on_combatant {
    my $self      = shift;
    my $combatant = shift;
    my $args      = shift;
    my $end_turn  = AnyEvent->condvar;

    my $turn;
    my $t = $self->{'t'} ||= 0;
    $self->debug("Wait on combatant [pid:$$ - turn:$t - id:".$combatant->id.']');
    
    my $timeout   =  AnyEvent->timer(
        after => $self->combatant_timeout_limit,
        cb    => sub {
            $turn = 'Skip';
            $self->debug("Combat turn as reached timeout limit [pid:$$ - turn:$t - id:".$combatant->id.']');
            $end_turn->send;
        },
    );
        
    my $wait_on_queue = AnyEvent->timer(
        after    => 0,
        interval => 2.0,
        cb       => sub {
            my $queue_file = $self->pid_queue_dir.'/'.$combatant->id;
            #$self->debug("Checking if queue_file exists [$queue_file]");
            return unless -e $queue_file;
            $self->debug("Found queue_file [$queue_file]");
            $turn = Artemis::Plugin::Pathfinder::Combat::Turn->load({queue_file => $queue_file});
            #$turn->execute;
            $end_turn->send;
        },
    );

    $end_turn->recv;

    return $turn;
}


1;
