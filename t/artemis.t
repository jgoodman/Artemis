#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Test;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/../lib";

use base 'Artemis::TestBase::DB';

sub load_modules : Test(startup => 3) {
    use_ok('Artemis::Piece');
    use_ok('Artemis::Space');
    use_ok('Artemis');
}

sub main : Test(4) {
    my $self = shift;

    my $a = $self->artemis(Artemis->load(board_id => 1));
    isa_ok($a, 'Artemis');

    my $p = $a->piece(1);
    ok($a->move_piece($p, dir => 'explore'), 'Moved piece');

    ok($a->space(2)->contains($p), 'Space contains game piece');

    is(
        $a->dbh->selectrow_hashref('SELECT space_id FROM pieces WHERE piece_id = ?', {}, $p->id)->{'space_id'},
        2,
        'Database has correct space_id for game piece'
    );
}

