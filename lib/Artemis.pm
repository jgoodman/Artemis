package Artemis;
use strict;
use warnings;
use DBI;
use JSON;
use Artemis::Space;
use Artemis::Piece;
use parent 'Games::Board';

our $config;
our $dbh;

sub config { $config ||= require 'Artemis/config' }
sub dbh {
    my $board = shift;
    $dbh ||= do {
        my $db = $board->config->{'db'};
        DBI->connect('dbi:mysql:'.$db->{'name'}, $db->{'user'}, $db->{'pass'}) or die "Could not connect";
    };
}

sub piececlass { 'Artemis::Piece' }
sub spaceclass { 'Artemis::Space' }

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

sub piece { my ($b, $id) = @_; $b->{'pieces'}{$id} || die 'board failed to lookup game piece' }

sub board_id {
    my $board = shift;
    $board->{'board_id'} = shift if scalar @_;
    return $board->{'board_id'} || die 'board_id missing';
}

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

sub add_piece {
    my ($board, %args) = @_;
    my $insert = delete $args{'_no_insert'} ? 0 : 1;
    my $piece = $board->SUPER::add_piece(%args);
    if($insert) {
        $board->dbh->do(
            'INSERT INTO pieces (space_id) VALUES (?)',
            { }, $piece->space_id || 1
        );
    }
    return $piece;
}

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

1;

__END__

=head1 SQL
  CREATE TABLE boards (
    board_id  INT NOT NULL AUTO_INCREMENT,
    name      VARCHAR(255),
    PRIMARY KEY (board_id)
  );

  INSERT INTO boards (name) VALUES ('Oddyscape-World');

  CREATE TABLE locations (
    location_id  INT NOT NULL AUTO_INCREMENT,
    board_id     INT NOT NULL,
    name         VARCHAR(255),
    PRIMARY KEY (location_id),
    FOREIGN KEY (board_id) REFERENCES boards(board_id)
  );

  INSERT INTO locations (board_id, name) VALUES (1, 'The Beach');

  /* Think of this table as a "state" that a location may have */
  CREATE TABLE spaces (
    space_id     INT NOT NULL AUTO_INCREMENT,
    post_id      INT NOT NULL,
    location_id  INT NOT NULL,
    dir          VARCHAR(255),
    PRIMARY KEY (space_id),
    UNIQUE      (post_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
  );

  INSERT INTO spaces (post_id, location_id, dir) VALUES (302, 1, '{"explore":2}');
  INSERT INTO spaces (post_id, location_id) VALUES (363, 1);

  CREATE TABLE pieces (
    piece_id  INT NOT NULL AUTO_INCREMENT,
    space_id  INT NULL,
    PRIMARY KEY (piece_id),
    FOREIGN KEY (space_id) REFERENCES spaces(space_id)
  );

  INSERT INTO pieces (space_id) VALUES (1);

  CREATE TABLE characters (
    character_id  INT NOT NULL AUTO_INCREMENT,
    user_id       INT,
    name          VARCHAR(255),
    piece_id      INT NOT NULL,
    PRIMARY KEY (character_id),
    FOREIGN KEY (piece_id) REFERENCES pieces(piece_id)
  );

  INSERT INTO characters (user_id, name, piece_id) VALUES (1, 'Arian', 1);

=cut
