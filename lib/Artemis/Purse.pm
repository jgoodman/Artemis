package Artemis::Purse;

use strict;
use warnings;

use Role::Tiny::With;
with 'Artemis::Role::Model';

sub new {
    my $class = shift;
    my $args  = shift || { };
    $args->{'money'} ||= 0;
    my $self = bless $args, $class;
    if(my $id = $args->{'id'}) {
        $self = bless $self->model->load(entity_purse => $id), $class;
    }
    return $self;
}

sub id {
    my $self = shift;
    $self->{'id'} ||= shift if scalar @_;
    $self->{'id'} ||= $self->model->insert(entity_purse => $self->info);
}

sub info {
    my $self = shift;
    my %info = (
        money     => $self->{'money'},
        entity_id => $self->{'entity_id'},
    );
    $info{'id'} = $self->{'id'} if $self->{'id'};
    return %info;
}

sub list {
    my $self = shift;
    return $self->{'money'};
}

sub add {
    my $self = shift;
    my $m = $self->{'money'} += $self->_calc(@_);
    $self->id;
    $self->model->update(entity_purse => $self->info);
    return $m;
}

sub subtract {
    my $self = shift;
    my $amnt = $self->_calc(@_);
    die 'Insufficent funds' unless $self->{'money'} >= $amnt;
    my $m = $self->{'money'} -= $amnt;
    $self->id;
    $self->model->update(entity_purse => $self->info);
    return $m;
}

sub _calc {
    my $self = shift;
    my $cur  = shift || die 'currency undef';
    my $amnt = shift || die 'amount undef';

    my %calc = (
        cp => sub { $amnt },
        sp => sub { $amnt * 10 },
        gp => sub { $amnt * 10 * 10 },
        pp => sub { $amnt * 10 * 10 * 10 },
    );

    my $code = $calc{$cur};
    die "Unknown currency [$cur]" unless $code;
    $code->();
}

1;

__END__

=head1 NAME

Artemis::Money - Interface for entities having items

=cut

