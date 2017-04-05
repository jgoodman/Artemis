#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use File::Path qw(remove_tree);
use Test::More tests => 6;

use lib "$Bin/../../lib";

use_ok('Artemis::Plugin::Pathfinder::Combat::Turn');

my $queue_dir = "$Bin/../../.queue/$$";
my $queue_file = "$queue_dir/1";
mkdir $queue_dir;

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

END { remove_tree($queue_dir) }
