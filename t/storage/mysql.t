#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 3;

use FindBin qw($Bin);
use lib "$Bin/../../lib";

use_ok('Artemis::Storage::MySQL');
can_ok('Artemis::Storage::MySQL', qw(insert load update remove));

local $TODO = 'Write more assertions to test CRUD methods';
fail('CRUD methods are tested');
