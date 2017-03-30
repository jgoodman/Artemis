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

sub new {
    my $class = shift;
    my %args  = @_;
    my $board = $class->SUPER::new;
    $board->board_id($args{'board_id'});

    my $spaces = $board->dbh->selectall_arrayref(
        'SELECT spaces.*, locations.name AS location_name FROM spaces JOIN locations USING (location_id) WHERE locations.board_id = ?',
        { Slice => { } }, $board->board_id
    );
    foreach my $space (@$spaces) {
        $space->{'dir'} = decode_json($space->{'dir'}) if $space->{'dir'};
        die 'failed to add_space' unless $board->add_space(%$space, _no_insert => 1);
    }

    return $board;
}

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

  INSERT INTO spaces (post_id, location_id) VALUES (302, 1);
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
