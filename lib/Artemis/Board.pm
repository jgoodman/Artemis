package Artemis::Board;

=head1 NAME

Artemis::Board - A game engine for "choose your adventure" type stories

=cut

use strict;
use warnings;
use Carp qw(confess);

use JSON;
use Artemis::Board::Location;
use Artemis::Board::Space;
use Artemis::Board::Piece;

use parent 'Games::Board';

use Role::Tiny::With;
with 'Artemis::Role::Model';

=head1 METHODS

=head2 piececlass

SEE Games::Board

=cut

sub piececlass { 'Artemis::Board::Piece' }

=head2 spaceclass

SEE Games::Board

=cut

sub spaceclass { 'Artemis::Board::Space' }

=head2 insert

  my $board = Artemis::Board->insert;

Contructor method that inserts an object then inserts into underlying data storage

=cut

sub insert {
    my $class = shift;
    my %args  = @_;
    my $board = $class->new(%args);

    my $id = $board->model->insert('board', $board);
    $board->board_id($id);

    return $board;
}

=head2 load

  my $artemis = Artemis::Board->load($id);

Contructor method that inserts an object then loads in database information

=cut

sub load {
    my $class = shift;
    my $id    = shift;

    my $self = $class->new->model->load(board => $id);

    my %pieces;
    foreach my $space (@{$self->spaces}) {
        my $space = $self->add_space(%$space, _no_insert => 1);
        confess 'board failed to add_space' unless $space;
        my $pieces = $self->dbh->selectall_arrayref('SELECT * FROM pieces WHERE space_id = ?', { Slice => { }}, $space->id);
        foreach my $r (@$pieces) {
            my $piece = $self->add_piece(id => $r->{'piece_id'}, _no_insert => 1);
            $space->receive($piece) || confess 'space failed to receive';
            $pieces{ $piece->id } = $piece;
        }
    }

    $self->{'pieces'} = \%pieces;

    return $self;
}

=head2 spaces

  my @locations = $board->spaces;

Returns a list of Artemis::Board::Spaces objects belonging to the board

=cut

sub spaces {
    my $self = shift;
    $self->{'spaces'} ||= [ map {
        my $location = $_;
        map {
            my $space = $_;
            $space->{'dir'} = decode_json($space->{'dir'}) if $space->{'dir'};
            Artemis::Board::Space->new($space)
        } @{$self->model->search(board_space => location_id => $location->id)}
    } @{$self->locations} ];
}

=head2 locations

  my @locations = $board->locations;

Returns a list of Artemis::Board::Location objects belonging to the board

=cut

sub locations {
    my $self = shift;
    $self->{'locations'} ||=[  map {
        Artemis::Board::Location->new($_)
    } @{$self->model->load(board_location => board_id => $self->id)} ];
}

=head2 piece

Returns a Piece object from given piece_id

=cut

sub piece { my ($b, $id) = @_; $b->{'pieces'}{$id} || confess 'board failed to lookup game piece' }

=head2 add_space

SEE Games::Board

Extends parent function to insert a space record unless _no_insert is supplied as true.

=cut

sub add_space {
    my ($board, %args) = @_;
    my $insert = delete $args{'_no_insert'} ? 0 : 1;
    my $space = $board->SUPER::add_space(%args);
    if($insert) {
        $space->{'dir'} = encode_json($space->{'dir'}) if ref $space->{'dir'} eq 'HASH';
        $board->dbh->do(
            'INSERT INTO spaces (post_id, location_id, dir) VALUES (?, ?, ?)',
            { }, $space->post_id, $space->location_id, $space->{'dir'}
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
        confess 'Bad ref passed in for piece' unless eval { $piece_obj_or_id->isa('Games::Board::Piece') };
        $piece = $piece_obj_or_id;
    }
    else {
        $piece = $board->piece($piece_obj_or_id)
    }

    confess 'Failed to move piece' unless $piece->move($how, $which);
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
