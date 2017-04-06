package Artemis::Symposium::Actions::Test;

use strict;
use warnings;

use Role::Tiny::With;
with 'Artemis::Role::Debug';

sub test {
    my $class = shift;
    my $args  = shift;
    my $stash = shift;
    my $self = bless $stash, $class;
    $self->debug('Nohup action');
    return 1;
}

1;
