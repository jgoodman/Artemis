#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Board::Test;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/../lib";

use base 'Artemis::TestBase::DB';

sub load_modules : Test(startup => 3) {
    use_ok('Artemis::Board::Piece');
    use_ok('Artemis::Board::Space');
    use_ok('Artemis::Board');
}

sub main : Test(4) {
    my $self = shift;

    my $board = $self->artemis(Artemis::Board->load(board_id => 1));
    isa_ok($board, 'Artemis::Board');

    my $p = $board->piece(1);
    ok($board->move_piece($p, dir => 'explore'), 'Moved piece');

    ok($board->space(2)->contains($p), 'Space contains game piece');

    is(
        $board->dbh->selectrow_hashref('SELECT space_id FROM pieces WHERE piece_id = ?', {}, $p->id)->{'space_id'},
        2,
        'Database has correct space_id for game piece'
    );
}

