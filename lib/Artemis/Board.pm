package Artemis::Board;

=head1 NAME

Artemis::Board - A game engine for "choose your adventure" type stories

=cut

use strict;
use warnings;

use DBI;
use JSON;
use Artemis::Board::Location;
use Artemis::Board::Space;
use Artemis::Board::Piece;

use parent 'Games::Board';

use Role::Tiny::With;
with 'Artemis::Role::DBH';

=head1 METHODS

=head2 piececlass

SEE Games::Board

=cut

sub piececlass { 'Artemis::Board::Piece' }

=head2 spaceclass

SEE Games::Board

=cut

sub spaceclass { 'Artemis::Board::Space' }

=head2 create

  my $board_id = Artemis::Board->create;

Contructor method that creates an object then inserts into database

=cut

sub create {
    my $class = shift;
    my %args  = @_;
    my $board = $class->new;

    die 'Failed to insert record' unless $board->dbh->do('INSERT INTO boards (name) VALUES (?)', { }, $args{'name'});

    $board->board_id($board->dbh->last_insert_id(undef, undef, 'boards', undef));
    return $board;
}

=head2 load

  my $artemis = Artemis::Board->load(board_id => $id);

Contructor method that creates an object then loads in database information

=cut

sub load {
    my $class = shift;
    my %args  = @_;
    my $board = $class->new;
    $board->board_id($args{'board_id'});

    my %pieces;
    my $spaces = $board->dbh->selectall_arrayref(
        'SELECT spaces.*, locations.name AS location_name FROM spaces JOIN locations USING (location_id) WHERE locations.board_id = ?',
        { Slice => { } }, $board->board_id
    );
    foreach my $row (@$spaces) {
        $row->{'dir'} = decode_json($row->{'dir'}) if $row->{'dir'};
        my $space = $board->add_space(%$row, _no_insert => 1);
        die 'board failed to add_space' unless $space;
        my $pieces = $board->dbh->selectall_arrayref('SELECT * FROM pieces WHERE space_id = ?', { Slice => { }}, $space->id);
        foreach my $r (@$pieces) {
            my $piece = $board->add_piece(id => $r->{'piece_id'}, _no_insert => 1);
            $space->receive($piece) || die 'space failed to receive';
            $pieces{ $piece->id } = $piece;
        }
    }

    $board->{'pieces'} = \%pieces;

    return $board;
}

=head2 piece

Returns a Piece object from given piece_id

=cut

sub piece { my ($b, $id) = @_; $b->{'pieces'}{$id} || die 'board failed to lookup game piece' }

=head2 board_id

Returns board_id.

=cut

sub board_id {
    my $board = shift;
    $board->{'board_id'} = shift if scalar @_;
    return $board->{'board_id'} || die 'board_id missing';
}

=head2 add_space

SEE Games::Board

Extends parent function to insert a space record unless _no_insert is supplied as true.

=cut

sub add_space {
    my ($board, %args) = @_;
    my $insert = delete $args{'_no_insert'} ? 0 : 1;
    my $space = $board->SUPER::add_space(%args);
    if($insert) {
        my $dir = $space->{'dir'};
        $dir = encode_json($dir) if ref $dir eq 'HASH';
        $board->dbh->do(
            'INSERT INTO spaces (post_id, location_id, dir) VALUES (?, ?, ?)',
            { }, $space->post_id, $space->location_id, $dir
        );
    }
    return $space;
}

=head2 add_piece

SEE Games::Board

Extends parent function to insert a piece record unless _no_insert is supplied as true.

=cut

sub add_piece {
    my ($board, %args) = @_;
    my $insert = delete $args{'_no_insert'} ? 0 : 1;
    my $piece = $board->SUPER::add_piece(%args);
    if($insert) {
        $board->dbh->do(
            'INSERT INTO pieces (space_id) VALUES (?)',
            { }, $piece->current_space_id || 1
        );
    }
    return $piece;
}

=head2 add_location

=cut

sub add_location {
    my ($board, %args) = @_;
    my $insert = delete $args{'_no_insert'} ? 0 : 1;
    my $loc = Artemis::Board::Location->new(%args);
    if($insert) {
        $board->dbh->do(
            'INSERT INTO locations (board_id, name) VALUES (?, ?)',
            { }, $board->board_id, $loc->name
        );
        $loc->{'id'} = $board->dbh->last_insert_id(undef, undef, 'locations', undef);
    }
    return $loc;
}

=head2 move_piece

  $artemis->move_piece($piece_obj_or_id, dir => 'north');

Move a piece on the board

=cut

sub move_piece {
    my ($board, $piece_obj_or_id, $how, $which) = @_;

    my $piece;
    if(ref $piece_obj_or_id) {
        die 'Bad ref passed in for piece' unless eval { $piece_obj_or_id->isa('Games::Board::Piece') };
        $piece = $piece_obj_or_id;
    }
    else {
        $piece = $board->piece($piece_obj_or_id)
    }

    die 'Failed to move piece' unless $piece->move($how, $which);
    $board->dbh->do('UPDATE pieces SET space_id = ? WHERE piece_id = ?', { }, $piece->current_space_id, $piece->id);

    return $piece;
}

=head2 first_character_id

  my $character_id = $artemis->first_character_id($user_id);

Returns the first character_id for the given user;

=cut

sub first_character_id {
    my ($board, $user_id) = @_;
    # TODO have this take character_id and make the client supply that to us instead.
    return 1; # XD
}

1;
