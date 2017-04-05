package Artemis::Plugin::Pathfinder::Combat::Turn;

use strict;
use warnings;

use File::Slurp;
use JSON;

use base 'Artemis::Role::Debug';

sub new {
    my $class = shift;
    my $args  = shift || { };
    bless $args, $class;
}

sub load {
    my $class = shift;
    my $self = $class->new(@_);
    $self->debug('Load from '.$self->queue_file);
    my $json = decode_json(read_file($self->queue_file));
    return $class->new({ %$self, %$json });
}

sub queue {
    my $self = shift;
    $self->debug('Save to '.$self->queue_file);
    my $touch = 'touch '.$self->queue_file;
    `$touch`;
    write_file($self->queue_file, { overwrite_file => 1 }, encode_json({%$self}));
}

sub queue_file {
    my $self = shift;
    $self->{'queue_file'} = shift if scalar @_;
    return $self->{'queue_file'} || die 'queue_file missing';
}

sub actions {
    my $self = shift;
    $self->{'actions'} = [ @_ ] if scalar @_;
    $self->{'actions'};
}


1;
