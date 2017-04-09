package Artemis::Symposium::Entity;

use strict;
use warnings;
use Carp qw(confess);

sub new {
    my $class = shift;
    my %args  = @_;
    bless \%args, $class;
}

sub id   { shift->{'id'}       || confess 'id missing' }
sub name { shift->{'name'}     || confess 'name missing' }
sub team { shift->{'team'}     ||= 2 }

sub DEX  { shift->{'DEX'}  || confess 'DEX missing' } # TODO

1;
