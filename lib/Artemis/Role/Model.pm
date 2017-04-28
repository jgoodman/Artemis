package Artemis::Role::Model;

use strict;
use warnings;

use Role::Tiny;

sub model {
    my $self = shift;
    return $self->{'role'}->{'model'} ||= do {
        require Artemis::Model;
        Artemis::Model->new;
    };
}

1;

__END__

=head1 NAME

Artemis::Role::Model - Provides model helper method

=cut


