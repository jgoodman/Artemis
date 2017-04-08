package Artemis::Symposium;

=head1 NAME

Artemis::Symposium - Queue handler for turn based events (such as combat)

=cut

use strict;
use warnings;

use Time::HiRes qw(sleep);
use Games::Dice qw(roll);
use AnyEvent;
use File::Path qw(make_path remove_tree);

use Artemis::Symposium::Request;

use Role::Tiny::With;
with 'Artemis::Role::Debug';
with 'Artemis::Role::DBH';

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
        $self->debug($s->{'msg'});
    }
    return $self->{'status'} || { msg => 'no status set' };
}

sub add_participants { push @{shift->participants}, @_ }
sub participants { shift->{'participants'} ||= [ ] }

sub initiative_check {
    my $self = shift;
    $self->status({pid => $$, msg => 'initiative_check'});
    my %rolls;
    my @participants = @{$self->participants};
    while (my $c = shift(@participants)) {
        my $key = roll('1d20+'.$c->DEX).'.'.$c->DEX;
        $self->debug("Rolled: ".$c->name." => $key");
        if(exists $rolls{$key}) {
            # Re-roll when same occurs
            push @participants, delete($rolls{$key});
            push @participants, $c;
        }
        else {
            $rolls{ $key } = $c;
        }
        sleep .5 if scalar @participants;
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

    my $initiatives = $self->initiative_check;

    $self->{'t'} = 0;
    while(my @order = sort { $b <=> $a } keys %$initiatives) {
        foreach my $roll (@order) {
            my $t = $self->{'t'}++;
            my $participant = $initiatives->{$roll};

            $self->status({
                pid  => $$,
                msg  => 'waiting on participant',
                turn => $t,
                participant => { id => $participant->id, name => $participant->name }
            });
            
            my $request = $self->wait_on_participant($participant, { initiatives => $initiatives });
            
            $self->status({
                pid  => $$,
                msg  => 'processing request for participant',
                turn => $t,
                participant => { id => $participant->id, name => $participant->name }
            });

            if(!ref($request) && $request) {
                next if $request eq 'Skip';
            }
            else {
                my $actions = $request->actions;
                while(my $action = shift(@$actions)) {
                    my $args = shift(@$actions);
                    $self->load_action_class($action)->execute($args);
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
    my $action_class = "Artemis::Actions::".join('', map{ ucfirst($_) } split('_', $action));
    (my $file = "$action_class.pm") =~ s{::}{/}g;
    require $file;
    return $action_class;
}

sub participant_timeout_limit { shift->{'participant_timeout_limit'} ||= 180 }

sub wait_on_participant {
    my $self      = shift;
    my $participant = shift;
    my $args      = shift;
    my $end_turn  = AnyEvent->condvar;

    my $request;
    my $t = $self->{'t'} ||= 0;
    $self->debug("Wait on participant [pid:$$ - turn:$t - id:".$participant->id.']');
    
    my $timeout   =  AnyEvent->timer(
        after => $self->participant_timeout_limit,
        cb    => sub {
            $request = 'Skip';
            $self->debug("Reached timeout limit when waiting on participant [pid:$$ - turn:$t - id:".$participant->id.']');
            $end_turn->send;
        },
    );
        
    my $wait_on_queue = AnyEvent->timer(
        after    => 0,
        interval => 2.0,
        cb       => sub {
            my $queue_file = $self->pid_queue_dir.'/'.$participant->id;
            $self->debug("Checking if queue_file exists [$queue_file]", 2);
            return unless -e $queue_file;
            $self->debug("Found queue_file [$queue_file]");
            $request = Artemis::Symposium::Request->load({queue_file => $queue_file});
            $end_turn->send;
        },
    );

    $end_turn->recv;

    return $request;
}


1;
