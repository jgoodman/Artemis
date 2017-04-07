package Artemis::Actions::Null;

use strict;
use warnings;

use Role::Tiny::With;
with 'Artemis::Role::Debug';

sub execute {
    my $class = shift;
    my $args  = shift;
    my $stash = shift;
    my $self = bless $stash, $class;
    $self->debug('Null action');
    return 1;
}

1;

__END__

=head1 NAME

Artemis::Actions::Null - A "do nothing" action

=cut

