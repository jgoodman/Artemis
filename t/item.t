#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;
use Test::Deep;

use FindBin qw($Bin);
use lib "$Bin/../lib";

my $args = {
    type     => 'weapon',
    subtype  => 'simple',
    name     => 'Dagger',
    cost     => '2 gp',
};

use_ok('Artemis::Item');
can_ok('Artemis::Item', qw(new info));

my $item = Artemis::Item->new($args);
ok($item, 'Can new up Item object');

my %info = $item->info;
cmp_deeply(
    \%info,
    $args,
    'Get item info'
);

