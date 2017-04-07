package Artemis::Location;

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
