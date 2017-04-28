#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 5;
use Test::Deep;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use_ok('Artemis::Entity');
can_ok('Artemis::Entity', qw(new has columns info id link_by inventory purse model));

my $e = Artemis::Entity->new({
    has => [qw(inventory purse)],
});

ok($e, 'Can new up Entity object');

ok($e->id, 'Got Entity Id');

my $expect = {
    id    => re('^\d+$'),
    name  => ignore(),
    class => ignore(),
};
my %info = $e->info;
cmp_deeply(\%info, $expect, 'Got Entity info');

