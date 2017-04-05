#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More tests => 9;
use File::Slurp qw(write_file);
use AnyEvent;

use lib "$Bin/../../lib";

use_ok('Artemis::Plugin::Pathfinder::Combat');

my $queue_dir = "$Bin/../../.queue";

my $combat = Artemis::Plugin::Pathfinder::Combat->new({
    queue_dir => $queue_dir,
    combatant_timeout_limit => 5,
});

isa_ok($combat, 'Artemis::Plugin::Pathfinder::Combat');

ok(-e "$queue_dir/$$", 'Object created queue dir');

require Artemis::Plugin::Pathfinder::Combat::Participant;

my @combatants = map { Artemis::Plugin::Pathfinder::Combat::Participant->new($_) } (
    { id => 1, name => 'Gary',    DEX => 2 },
    { id => 2, name => 'Bob',     DEX => 2 },
    { id => 3, name => 'Sue',     DEX => 3 },
    { id => 4, name => 'Goblin1', DEX => 1 },
    { id => 5, name => 'Goblin2', DEX => 1 },
);

my $initiatives = $combat->initiative_check(@combatants);
is(scalar keys %$initiatives, 5, 'Initiative check works');

is(
    $combat->wait_on_combatant($combatants[0], { initiatives => $initiatives }),
    'Skip',
    'Got timeout'
);

my $echo = "echo '{\"actions\":[\"test\",\"1,1\",\"standard\",{\"attack\":2}]}' > $queue_dir/$$/1";
`$echo`;

$combat->{'combatant_timeout_limit'} = 30;
my $turn = $combat->wait_on_combatant($combatants[0], { initiatives => $initiatives });
like(
    ref($turn),
    qr/Combat::Turn$/,
    'Got turn object back'
);
note '$turn='.$turn unless ref($turn);

my $action = $turn->actions->[0];
my $args   = $turn->actions->[1];
my $action_class = $combat->load_action_class($action);
ok($action_class, "Load class for action $action");

ok($action_class->$action($args, {}), 'Execute action');

$combat = undef;
ok(! -e "$queue_dir/$$", 'Object removed queue dir');


