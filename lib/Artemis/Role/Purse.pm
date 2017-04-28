package Artemis::Role::Purse;

use strict;
use warnings;

use Role::Tiny;

sub purse {
    my $self = shift;
    return $self->{'role'}->{'purse'} ||= do {
        require Artemis::Purse;
        my $class = 'Artemis::Purse';
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

Artemis::Role::Purse - Provides purse helper method

=cut


