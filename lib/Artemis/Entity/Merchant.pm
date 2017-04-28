package Artemis::Entity::Merchant;

use strict;
use warnings;
use base 'Artemis::Entity';

use Class::Method::Modifiers;

around 'new' => sub {
    my $orig = shift;
    my $self = shift;
    my $args = shift || { };
    push(@{$args->{'has'} ||= [ ]}, qw(inventory purse));
    $orig->($self, $args, @_);
};

1;
