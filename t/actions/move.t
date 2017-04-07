#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Actions::Move::Test;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/../../lib";

use base qw(Artemis::TestBase::DB);

sub load_modules : Test(startup => 1) {
    use_ok('Artemis::Actions::Move');
}

sub main : Test(1) {
    my $self = shift;

    my $got = Artemis::Actions::Move->execute({
        board_id => 1,
        piece_id => 1,
        dir     => 'explore',
    });

    ok($got, 'Execution returned true');
}

