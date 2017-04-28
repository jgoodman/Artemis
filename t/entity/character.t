#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 6;
use Test::Deep;

use FindBin qw($Bin);
use lib "$Bin/../../lib";

use_ok('Artemis::Entity::Character');
isa_ok('Artemis::Entity::Character', 'Artemis::Entity');

my $e = Artemis::Entity::Character->new;

ok($e,            'Can new up Character object');
ok($e->id,        'Got Entity Id');
ok($e->purse,     'Get Purse object');
ok($e->inventory, 'Get Inventory object');

