package Artemis::Role::Domain;

use strict;
use warnings;

use Carp qw(confess cluck);
use Role::Tiny;

sub _classmap {
    return {
        'Artemis::Action::EnterSymposium' => 'action__enter_symposium',
        'Artemis::Action::Move'           => 'action__move',
        'Artemis::Action::Null'           => 'action__null',
        'Artemis::Board'                  => 'board',
        'Artemis::Board::Location'        => 'board__location',
        'Artemis::Board::Piece'           => 'board__piece',
        'Artemis::Board::Space'           => 'board__space',
        'Artemis::Entity'                 => 'entity',
        'Artemis::Entity::Character'      => 'entity__character',
        'Artemis::Entity::Merchant'       => 'entity__merchant',
        'Artemis::Inventory'              => 'inventory',
        'Artemis::InventoryItem'          => 'inventory_item',
        'Artemis::Item'                   => 'item',
        'Artemis::Matriarch'              => 'matriarch',
        'Artemis::Purse'                  => 'purse',
        'Artemis::Symposium'              => 'symposium',
        'Artemis::SymposiumEntity'        => 'symposium_entity',
        'Artemis::SymposiumRequest'       => 'symposium_request',
        'Artemis::Transaction'            => 'transaction',
    }
}

sub new {
    my $class = shift;
    my $args  = shift || { };
    my $self = bless({%$args}, $class);
    if(my $id = $args->{'id'}) {
        $self = bless($self->model->load($self->class2label, $id), $class);
    }
    return $self;
}

sub label2class {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my %labelmap = reverse %{$self->_classmap};
    $labelmap{$label} || confess('label does not exist');
}

sub class2label {
    my $self  = shift;
    my $class = shift || (ref($self) || $self);
    $self->_classmap->{$class} || confess('class does not exist');
}

sub id {
    my $self = shift;
    $self->{'id'} ||= shift if scalar @_;
    $self->{'id'} ||= do {
        my $id = $self->model->insert($self->class2label, $self->info);
        $self->post_insert($id) if $self->can('post_insert');
        $id;
    }
}

sub info {
    my $self = shift;
    my %info;
    $info{'id'} = $self->{'id'} if $self->{'id'};
    foreach ($self->columns) {
        next if $_ eq 'id';
        $info{$_} = $self->{$_};
    }
    return %info;
}

sub remove {
    my $self = shift;
    $self->model->remove($self->class2label, $self->id);
}

sub search {
    my $self = shift;
    $self->model->search($self->class2label, @_);
}

1;

__END__

=head1 NAME

Artemis::Role::Domain - Provides Domain related functions

=cut


