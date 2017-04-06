package Artemis::Board::Space;
use strict;
use warnings;
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
  die 'failed to init '.$class;
}

sub post_id { shift->{'post_id'} }
sub location_id { shift->{'location_id'} }


1;
