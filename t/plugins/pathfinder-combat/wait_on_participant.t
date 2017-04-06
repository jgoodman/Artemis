#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Plugin::Pathfinder::Combat::Test::WaitOnParticipant;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/../../../lib";

use base qw(Artemis::Plugin::Pathfinder::Combat::TestBase);

sub setup_queue    : Test(setup => 1) {
    my $self = shift;

    my $pid_queue_dir = $self->pid_queue_dir;
    mkdir $pid_queue_dir unless -e $pid_queue_dir;

    my $echo = "echo '{\"actions\":[\"test\",\"1,1\",\"standard\",{\"attack\":2}]}' > $pid_queue_dir/1";
    `$echo`;

    pass('Queue setup complete');
}

sub teardown_queue : Test(teardown => 1) {
    my $self = shift;
    delete $self->{'combat'};
    remove_tree($self->pid_queue_dir) if -e $self->pid_queue_dir;
    pass('Queue teardown complete');
}

sub timeout : Test(1) {
    my $self = shift;

    $self->combat->{'participant_timeout_limit'} = 3;
    is(
        $self->combat->wait_on_participant($self->participants->[1]),
        'Skip',
        'Got timeout'
    );
}

sub got_turn : Test(3) {
    my $self = shift;

    my $turn = $self->combat->wait_on_participant($self->participants->[0]);
    like(
        ref($turn),
        qr/Combat::Turn$/,
        'Got turn object back'
    );
    note '$turn='.$turn unless ref($turn);

    my $action = $turn->actions->[0];
    my $args   = $turn->actions->[1];
    my $action_class = $self->combat->load_action_class($action);
    ok($action_class, "Load class for action $action");

    ok($action_class->$action($args, {}), 'Execute action');
}

