package Artemis::Board::Piece;
use strict;
use warnings;
use parent 'Games::Board::Piece';

sub new {
  my $class = shift;
  my %args  = @_;
  $args{'id'} = delete $args{'piece_id'} if exists $args{'piece_id'};
  if(my $self = $class->SUPER::new(%args)) {
        return $self;
  }
}

1;

=head1 NAME

Artemis::Board::Piece - Subclaasses Games::Board::Piece

=cut


