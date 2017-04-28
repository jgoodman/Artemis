package Artemis::InventoryItem;

use strict;
use warnings;
use Carp qw(confess cluck);

use Role::Tiny::With;
with qw(
    Artemis::Role::Domain
    Artemis::Role::Model
);

sub columns { qw(id inventory_id item_id) }

sub inventory_id {
    my $self = shift;
    $self->{'inventory_id'} = shift if scalar @_;
    $self->{'inventory_id'} || confess('missing inventory_id')
}

sub item_id {
    my $self = shift;
    $self->{'item_id'} = shift if scalar @_;
    $self->{'item_id'} || confess('missing item_id')
}

1;

__END__

=head1 NAME

Artemis::InventoryItem - Links an Item to an Inventory

=cut

