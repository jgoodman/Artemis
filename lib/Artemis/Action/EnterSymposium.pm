package Artemis::Action::EnterSymposium;

use strict;
use warnings;

use Artemis::Symposium;

use Role::Tiny::With;
with 'Artemis::Role::Debug';

sub execute {
    my $class = shift;
    my $args  = shift;

    my $self = bless $args, $class;

    $self->debug('Started Action: EnterSymposium');

    return unless $self->conditions;

    $self->symposium->add_entities(@{$args->{'entities'}});

    return 1;
}

sub symposium_id { shift->{'symposium_id'} }

sub symposium {
    my $self = shift;
    $self->{'symposium'} ||= $self->symposium_id ? Artemis::Symposium->load(symposium_id => $self->symposium_id) : do {
        my $s = Artemis::Symposium->insert();
        $self->{'symposium_id'} = $s->id;
        $s;
    }
}

sub conditions { 1 }

1;

__END__

=head1 NAME

Artemis::Action::Move - Action to move a piece on the board

=cut

