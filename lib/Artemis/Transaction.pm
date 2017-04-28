package Artemis::Transaction;

use strict;
use warnings;

use Role::Tiny::With;
with 'Artemis::Role::Model';

sub new {
    my $class = shift;
    my $self  = shift || { };
    bless $self, $class;
}

sub item {
    my $self = shift;
    $self->{'item'} = shift if scalar @_;
    return $self->{'item'} || die 'item undef';
}

sub buyer {
    my $self = shift;
    $self->{'buyer'} = shift if scalar @_;
    return $self->{'buyer'} || die 'buyer undef';
}

sub seller {
    my $self = shift;
    $self->{'seller'} = shift if scalar @_;
    return $self->{'seller'} || die 'seller undef';
}

sub error {
    my $self = shift;
    if(scalar @_) {
        push @{$self->{'error'} ||= [ ]}, shift;
    }
    return $self->{'error'} ||= [ ];
}

sub purchase {
    my $self = shift;
    my ($a, $cur) = split(' ', $self->item->cost);

    my $b = $self->buyer;
    $b->purse->subtract($cur, $a);
    $b->inventory->add_item($self->item->id);

    my $s = $self->seller;
    $s->purse->add($cur, $a);
    $s->inventory->remove_item($self->item->id);

    return 1;
}

1;
