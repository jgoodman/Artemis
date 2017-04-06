#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Plugin::Pathfinder::Combat::Test::ManageQueue;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;
use File::Path qw(remove_tree);

use lib "$Bin/../../../lib";

use base qw(Test::Class);

sub queue_dir     { "$Bin/../../../.queue" }
sub pid_queue_dir { shift->queue_dir."/$$" }

sub load_modules : Test(startup => 1) {
    use_ok('Artemis::Plugin::Pathfinder::Combat');
}

sub main : Test(2) {
    my $self = shift;

    my $combat = Artemis::Plugin::Pathfinder::Combat->new({
        queue_dir => $self->queue_dir,
        participant_timeout_limit => 5,
    });

    isa_ok($combat, 'Artemis::Plugin::Pathfinder::Combat');

    my $pid_queue_dir = $self->pid_queue_dir;
    ok(-e $pid_queue_dir, 'Object created queue dir') or return "Failed to create queue dir [$pid_queue_dir]";
}

sub remove_queue : Test(shutdown => 1) {
    my $self = shift;
    ok(! -e $self->pid_queue_dir, 'Object removed queue dir') or remove_tree($self->pid_queue_dir);
}
