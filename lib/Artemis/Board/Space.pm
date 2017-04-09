package Artemis::Board::Space;

use strict;
use warnings;

use Carp qw(confess);
use parent 'Games::Board::Space';

sub new {
  my $class = shift;
  my %args  = @_;
  $args{'id'} = delete $args{'space_id'} if exists $args{'space_id'};
  if(my $self = $class->SUPER::new(%args)) {
        $self->{'post_id'}       = $args{'post_id'};
        $self->{'locatation_id'} = $args{'location_id'};
        return $self;
  }
  confess 'failed to init '.$class;
}
sub post_id { shift->{'post_id'} }
sub location_id { shift->{'location_id'} }

1;

__END__

=head1 NAME

Artemis::Board::Space - Subclaasses Games::Board::Space

=cut

=head1 METHODS

=head2 new

Extends constructor method from parent class

=cut

=head2 post_id

Accessor method

=head2 location_id

Accessor method

=cut

