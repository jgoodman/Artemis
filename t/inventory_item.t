#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 5;
use Test::Deep;

use FindBin qw($Bin);
use lib "$Bin/../lib";

my $info = {
    inventory_id => 2,
    item_id      => 3,
};

use_ok('Artemis::InventoryItem');
can_ok('Artemis::InventoryItem', qw(new info));

my $item = Artemis::InventoryItem->new($info);
ok($item, 'Can new up InventoryItem object');

is($item->inventory_id, 2, 'Got inventory_id');
is($item->item_id,      3, 'Got item_id');

