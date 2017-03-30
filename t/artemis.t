#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 5;

use_ok('Artemis::Piece');
use_ok('Artemis::Space');
use_ok('Artemis');

my $a = Artemis->new(board_id => 1);
isa_ok($a, 'Artemis');

ok($a->space(1), 'Get space_id 1');
