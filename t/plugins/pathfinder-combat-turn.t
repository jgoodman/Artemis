#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Plugin::Pathfinder::Combat::Turn::Test;

use strict;
use warnings;

use FindBin qw($Bin);
use File::Path qw(remove_tree);
use Test::More;

use lib "$Bin/../../lib";

use base 'Test::Class';

sub queue_dir  { "$Bin/../../.queue/$$" }
sub queue_file { shift->queue_dir().'/1' }

sub load_modules : Test(startup => 1) {
    use_ok('Artemis::Plugin::Pathfinder::Combat::Turn');
}

sub setup_queue : Test(setup => 1) {
    my $self = shift;
    mkdir $self->queue_dir;
    pass('Setup queue complete');
}

sub main : Test(5) {
    my $self = shift;

    my $queue_file = $self->queue_file;
    my $turn = Artemis::Plugin::Pathfinder::Combat::Turn->new({queue_file => $queue_file});
    isa_ok($turn, 'Artemis::Plugin::Pathfinder::Combat::Turn');

    $turn->actions(
        move     => '1,1',
        standard => { attack => 2 }
    );

    $turn->queue;
    ok(-e $queue_file, 'Saved queue_file');

    $turn = undef;
    $turn = Artemis::Plugin::Pathfinder::Combat::Turn->load({queue_file => $queue_file});
    isa_ok($turn, 'Artemis::Plugin::Pathfinder::Combat::Turn');
    is($turn->{'actions'}->[0], 'move', 'Correct key in queue_file found');
    is($turn->{'actions'}->[1], '1,1',  'Correct value in queue_file found');
}

sub teardown_queue : Test(teardown => 1) { remove_tree(shift->queue_dir); pass('Teardown queue complete') }

