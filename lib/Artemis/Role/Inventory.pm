package Artemis::Role::Inventory;

use strict;
use warnings;

use Role::Tiny;

sub inventory {
    my $self = shift;
    return $self->{'role'}->{'inventory'} ||= do {
        require Artemis::Inventory;
        my $class = 'Artemis::Inventory';
        my $args  = { };
        if($self->can('link_by')) {
            $args = $self->model->search($self->class2label($class), $self->link_by($class))->[0] || { };
        }
        $class->new($args);
    };
}

1;

__END__

=head1 NAME

Artemis::Role::Inventory - Provides inventory helper method

=cut


