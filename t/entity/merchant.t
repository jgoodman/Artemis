#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 6;
use Test::Deep;

use FindBin qw($Bin);
use lib "$Bin/../../lib";

use_ok('Artemis::Entity::Merchant');
isa_ok('Artemis::Entity::Merchant', 'Artemis::Entity');

my $e = Artemis::Entity::Merchant->new;

ok($e,            'Can new up Merchant object');
ok($e->id,        'Got Entity Id');
ok($e->purse,     'Get Purse object');
ok($e->inventory, 'Get Inventory object');

