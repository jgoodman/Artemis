#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 5;
use Test::Deep;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Artemis::Item;
use Artemis::Entity;

use_ok('Artemis::Transaction');
can_ok('Artemis::Transaction', qw(new purchase error));

my $item = Artemis::Item->new({
    type     => 'weapon',
    subtype  => 'simple',
    name     => 'Dagger',
    cost     => '2 gp',
});

my $merchant = Artemis::Entity->new({
    has => [qw(inventory purse)],
});

$merchant->inventory->add_item($item->id);

my $character = Artemis::Entity->new({
    has => [qw(inventory purse)],
});

$character->purse->add(gp => 3);

my $transaction = Artemis::Transaction->new({
    item   => $item,
    buyer  => $character,
    seller => $merchant,
});
ok($transaction->purchase, 'Purchase Item');

cmp_deeply($transaction->error, [], 'No error returned');

is(
    scalar @{$character->inventory->list->{$item->id}},
    1,
    'Character has Purchased Item in Inventory',
);

# TODO BEYOND MVP AT THIS POINT...
# Entity does not have item
# Entity has insufficent gold
# Entity has insufficent level
# Entity has insufficent fame
# Entity is not in same location as Entity

