package Artemis::Symposium::Participant;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $args  = shift;
    bless $args, $class;
}

sub id       { shift->{'id'}       || die 'id missing' }
sub name     { shift->{'name'}     || die 'name missing' }
sub role     { shift->{'role'}     ||= 'npc' }
sub behavior { shift->{'behavior'} ||= 'aggressive' }
sub team     { shift->{'team'}     ||= 2 }

sub DEX  { shift->{'DEX'}  || die 'DEX missing' } # TODO

1;
