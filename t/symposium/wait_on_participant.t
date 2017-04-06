#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Symposium::Test::WaitOnParticipant;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/../../lib";

use base qw(Artemis::TestBase::Symposium);

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
    delete $self->{'symposium'};
    remove_tree($self->pid_queue_dir) if -e $self->pid_queue_dir;
    pass('Queue teardown complete');
}

sub timeout : Test(1) {
    my $self = shift;

    $self->symposium->{'participant_timeout_limit'} = 3;
    is(
        $self->symposium->wait_on_participant($self->participants->[1]),
        'Skip',
        'Got timeout'
    );
}

sub request_exists : Test(3) {
    my $self = shift;

    my $request = $self->symposium->wait_on_participant($self->participants->[0]);
    like(
        ref($request),
        qr/Symposium::Request$/,
        'Got Request object back'
    );
    note '$request='.$request unless ref($request);

    my $action = $request->actions->[0];
    my $args   = $request->actions->[1];
    my $action_class = $self->symposium->load_action_class($action);
    ok($action_class, "Load class for action $action");

    ok($action_class->$action($args, {}), 'Execute action');
}

