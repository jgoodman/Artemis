#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 8;
use Test::Deep;
use File::Path qw(remove_tree);

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Artemis::Model;

use_ok('Artemis::Purse');
can_ok('Artemis::Purse', qw(new list add subtract));

my $purse = Artemis::Purse->new;
ok($purse, 'Can new up Purse object');

ok($purse->add(gp => 3), 'Add gold to Purse');

is($purse->list, 300, 'Get purse amount');

ok($purse->subtract(gp => 2), 'Subtract gold from Purse');

is($purse->list, 100, 'Amount has been subracted');

my $load_purse = Artemis::Purse->new({id => $purse->id});
is($load_purse->list, 100, 'Can load Purse object');

