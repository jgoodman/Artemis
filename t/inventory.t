#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 8;
use Test::Deep;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Artemis::Item;

my $item = Artemis::Item->new({
    type     => 'weapon',
    subtype  => 'simple',
    name     => 'Dagger',
    cost     => '2 gp',
});

use_ok('Artemis::Inventory');
can_ok('Artemis::Inventory', qw(new list add_item remove_item));

my $inventory = Artemis::Inventory->new;
ok($inventory, 'Can new up Inventory object');

my $item_id = $item->id;
ok($inventory->add_item($item_id), 'Add item to Inventory');

is(scalar @{$inventory->list->{$item_id}}, 1, 'There is now 1 item in inventory');

cmp_deeply(
    { $inventory->list->{$item_id}->[0]->info },
    { id => re('^\d+$'), inventory_id => $inventory->id, item_id => $item->id },
    'Got InventoryItem info'
);

ok($inventory->remove_item($item_id), 'Remove item to Inventory');
cmp_deeply(
    $inventory->list->{$item_id},
    [ ],
    'Inventory is empty'
);



