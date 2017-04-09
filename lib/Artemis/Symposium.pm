package Artemis::Symposium;

=head1 NAME

Artemis::Symposium - Queue handler for turn based events (such as combat)

=cut

use strict;
use warnings;

use Carp qw(confess cluck);
use Time::HiRes qw(sleep);
use Games::Dice qw(roll);
use AnyEvent;
use JSON;
use File::Path qw(make_path remove_tree);

use Artemis::Symposium::Request;

use Role::Tiny::With;
with 'Artemis::Role::Debug';
with 'Artemis::Role::DBH';

sub new {
    my $class = shift;
    my %args  = @_;
    my $self  = bless \%args, $class;

    $self->init_queue;
    return $self;
}

sub insert {
    my $self = shift;

    $self->dbh->do(
        'INSERT INTO symposiums (class, pid, state) VALUES (?,?,?)',
        { }, $self->class, $$, 'INSERT_START'
    ) or confess 'Failed to insert record: symposiums';
    $self->symposium_id($self->dbh->last_insert_id(undef, undef, 'symposiums', undef));

    $self->state('insert_complete', {pid => $$});
    return $self;    
}

sub load {
    my $self = shift;

    $self->state('load_start');

    my $row = $self->dbh->selectrow_hashref(
        "SELECT * FROM symposiums WHERE symposium_id = ?",
        { }, $self->id
    ) || confess('Symposium not found');

    confess("Symposium is locked [pid:$$]") if $row->{'pid'};

    $self->dbh->do(
        'UPDATE symposiums SET pid = ? WHERE symposium_id = ?',
        { }, $$, $self->id
    ) or confess("Trouble inserting lock in database: symposiums.pid");

    $self->state('load_complete');

    return $self;
}

sub DESTROY {
    my $self = shift;

    $self->state('destroy_start');
    $self->dbh->do(
        'UPDATE symposiums SET pid = NULL WHERE symposium_id = ?',
        { }, $self->id
    ) or warn "Trouble removing lock in database: symposiums.pid";

    my $dir  = $self->pid_queue_dir;
    remove_tree($dir) or warn "Trouble removing pid_queue_dir [$dir]";

    $self->state('destroy_complete');
}

sub id { goto &symposium_id }
sub symposium_id {
    my $self = shift;
    $self->{'symposium_id'} = shift if scalar @_;
    return $self->{'symposium_id'} || confess 'symposium_id missing';
}

sub class { shift->{'class'} ||= 'combat' }
sub init_queue { make_path(shift->pid_queue_dir) }

sub queue_dir {
    my $self = shift;
    $self->{'queue_dir'} ||= shift if scalar @_;
    return $self->{'queue_dir'} || confess 'queue_dir missing';
}

sub pid_queue_dir {
    my $self = shift;
    $self->queue_dir.'/'.$$;
}

sub state {
    my $self = shift;
    if(scalar @_) {
        my $state = $self->{'state'} = uc(shift);
        my $meta  = shift || { };
        $meta->{'pid'} ||= $$;
        $meta = encode_json($meta) if $meta;
        $self->debug('State: '.$state);
        $self->dbh->do(
            'INSERT INTO symposium_logs (symposium_id,state,meta) VALUES (?,?,?)',
            { }, $self->id, $state, $meta
        ) or warn 'Failed to insert record: symposium_logs';

        $self->dbh->do(
            'UPDATE symposiums SET state = ? WHERE symposium_id = ?',
            { }, $state, $self->id
        ) or warn 'Failed to update record: symposiums.state';
    }
    return $self->{'state'} || 'UNDEFINED';
}

sub add_entities { push @{shift->entities}, @_ }
sub entities { shift->{'entities'} ||= [ ] }

sub initiative_check {
    my $self = shift;
    $self->state('initiative_check_start');
    my %rolls;
    my @entities = @{$self->entities};
    while (my $c = shift(@entities)) {
        my $key = roll('1d20+'.$c->DEX).'.'.$c->DEX;
        $self->debug("Rolled: ".$c->name." => $key");
        if(exists $rolls{$key}) {
            # Re-roll when same occurs
            push @entities, delete($rolls{$key});
            push @entities, $c;
        }
        else {
            $rolls{ $key } = $c;
        }
        sleep .5 if scalar @entities;
    }

    foreach my $roll (keys %rolls) {
        my $c = $rolls{$roll};
        #my $cmd = 'touch '.$self->pid_queue_dir.'/'.$c->id;
        #`$cmd`;
    }
    $self->state('initiative_check_complete');

    return \%rolls;
}

sub loop {
    my $self = shift;

    $self->state('loop_start');
    my $initiatives = $self->initiative_check;

    $self->{'t'} = 0;
    while(my @order = sort { $b <=> $a } keys %$initiatives) {
        foreach my $roll (@order) {
            my $t = $self->{'t'}++;
            my $entity = $initiatives->{$roll};

            $self->state('waiting_on_entity', {
                turn => $t,
                entity => { id => $entity->id, name => $entity->name }
            });
            
            my $request = $self->wait_on_entity($entity, { initiatives => $initiatives });
            
            $self->state('processing_request', {
                turn => $t,
                entity => { id => $entity->id, name => $entity->name }
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

    $self->state('loop_complete');
}

sub load_action_class {
    my $self   = shift;
    my $action = shift;
    my $action_class = "Artemis::Actions::".join('', map{ ucfirst($_) } split('_', $action));
    (my $file = "$action_class.pm") =~ s{::}{/}g;
    require $file;
    return $action_class;
}

sub entity_timeout_limit { shift->{'entity_timeout_limit'} ||= 180 }

sub wait_on_entity {
    my $self      = shift;
    my $entity = shift;
    my $args      = shift;
    my $end_turn  = AnyEvent->condvar;

    my $request;
    my $t = $self->{'t'} ||= 0;
    $self->debug("Wait on entity [pid:$$ - turn:$t - id:".$entity->id.']');
    
    my $timeout   =  AnyEvent->timer(
        after => $self->entity_timeout_limit,
        cb    => sub {
            $request = 'Skip';
            $self->debug("Reached timeout limit when waiting on entity [pid:$$ - turn:$t - id:".$entity->id.']');
            $end_turn->send;
        },
    );
        
    my $wait_on_queue = AnyEvent->timer(
        after    => 0,
        interval => 2.0,
        cb       => sub {
            my $queue_file = $self->pid_queue_dir.'/'.$entity->id;
            $self->debug("Checking if queue_file exists [$queue_file]", 2);
            return unless -e $queue_file;
            $self->debug("Found queue_file [$queue_file]");
            $request = Artemis::Symposium::Request->load(queue_file => $queue_file);
            $end_turn->send;
        },
    );

    $end_turn->recv;

    return $request;
}


1;
