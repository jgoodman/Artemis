package Artemis::Board::Location;

use strict;
use warnings;

sub new {
    my $class = shift;    
    my $args  = { @_ };
    $args->{'id'} = delete($args->{'location_id'}) || $args->{'id'};
    bless $args, $class;
}

sub id { shift->{'id'} }
sub board { shift->{'board'} }
sub name { shift->{'name'} }

1;

__END__

=head1 NAME

Artemis::Board::Location - Data Model for Location

=head1 SYNOPSIS

This object represents a location. How this differs from Artemis::Board::Space?
Well, there's a 1 to many relationship between locations and spaces. Think
of space as a I<state> that location is in.

=head1 METHODS

=head2 new

=head2 id

=head2 board

=head2 name

=cut


