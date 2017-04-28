package Artemis::Inventory;

use strict;
use warnings;
use JSON;

use Class::Method::Modifiers;
use Role::Tiny::With;
with qw(
    Artemis::Role::Domain
    Artemis::Role::Model
);

use Artemis::InventoryItem;

sub columns { qw(id entity_id) }

around 'new' => sub {
    my $orig  = shift;
    my $class = shift;
    my $args  = shift || { };
    $args->{'stash'} ||= { };
    return $orig->($class, $args, @_);
};

sub post_insert {
    my $self = shift;
    my $id   = shift;
    foreach my $item_id (sort { $a <=> $b } keys %{$self->list}) {
        foreach my $inventory_item (@{$self->list->{$item_id}}) {
            $self->add_item($item_id);
        }
    }
}

sub list {
    my $self = shift;
    return $self->{'stash'};
}

sub add_item {
    my $self = shift;
    my $item_id = shift || die 'inventory item undef';

    my $class = 'Artemis::InventoryItem';
    my $inv_item = $class->new({inventory_id => $self->id, item_id => $item_id});
    $inv_item->id;

    push @{$self->{'stash'}->{$inv_item->item_id} ||= []}, $inv_item;
}

sub remove_item {
    my $self     = shift;
    my $item_id  = shift || die 'item undef';
    my $inv_item = shift @{$self->list->{$item_id}};
    $inv_item->remove if $inv_item;
}

1;

__END__

=head1 NAME

Artemis::Inventory - Interface for entities having items

=cut

