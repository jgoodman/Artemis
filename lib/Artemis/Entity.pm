package Artemis::Entity;

use strict;
use warnings;

use Class::Method::Modifiers;
use Role::Tiny::With;

with qw(
    Artemis::Role::Domain
    Artemis::Role::Model
    Artemis::Role::Inventory
    Artemis::Role::Purse
);

sub columns { qw(id name class) }

around 'new' => sub {
    my $orig = shift;
    my $class = shift;
    my $args  = shift || { };
    $class = ref($class) || $class;
    if(my $subclass = $args->{'class'}) {
        $class .= "::$subclass";
        (my $file = "$class.pm") =~ s{/}{::}g;
        require $file;
    }
    $orig->($class, $args, @_);
};

sub has {
    my $self  = shift;
    my $thing = shift || die 'thing undef';
    scalar(grep { $_ eq $thing } @{$self->{'has'} ||= []});
}

sub link_by {
    my $self = shift;
    return entity_id => $self->id
}

around 'inventory' => sub {
    my $orig = shift;
    my $self = shift;
    die 'Entity does not have inventory' unless $self->has('inventory');
    $orig->($self, @_);
};

around 'purse' => sub {
    my $orig = shift;
    my $self = shift;
    die 'Entity does not have purse' unless $self->has('purse');
    $orig->($self, @_);
};


1;

__END__

=head1 NAME

Artemis::Entity - Base class for entities

=cut


