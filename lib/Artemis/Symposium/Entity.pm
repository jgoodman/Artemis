package Artemis::Symposium::Entity;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $args  = shift;
    bless $args, $class;
}

sub id   { shift->{'id'}       || die 'id missing' }
sub name { shift->{'name'}     || die 'name missing' }
sub team { shift->{'team'}     ||= 2 }

sub DEX  { shift->{'DEX'}  || die 'DEX missing' } # TODO

1;
