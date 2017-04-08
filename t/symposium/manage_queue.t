#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Symposium::Test::ManageQueue;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;
use File::Path qw(remove_tree);

use lib "$Bin/../../lib";

use base qw(Artemis::TestBase::Symposium);

sub queue_dir     { "$Bin/../../.queue" }
sub pid_queue_dir { shift->queue_dir."/$$" }

sub load_modules : Test(startup => 1) {
    use_ok('Artemis::Symposium');
}

sub main : Test(2) {
    my $self = shift;

    my $symposium = $self->symposium;

    isa_ok($symposium, 'Artemis::Symposium');

    my $pid_queue_dir = $symposium->pid_queue_dir;
    ok(-e $pid_queue_dir, 'Object created queue dir') or diag "Failed to create queue dir [$pid_queue_dir]";
}

