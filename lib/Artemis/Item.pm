package Artemis::Item;

use strict;
use warnings;
use Carp qw(confess cluck);

use Class::Method::Modifiers;
use Role::Tiny::With;
with qw(
    Artemis::Role::Domain
    Artemis::Role::Model
);

sub columns { qw(id type subtype name cost) }

sub cost {
    my $self = shift;
    $self->{'cost'} ||= '0 gp';
}

1;

__END__

=head1 NAME

Artemis::Item - Base class for items

=cut

