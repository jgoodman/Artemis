package Artemis::Model;

=head1 NAME

Artemis::Model - Unified interface for storing and retrieving data

=cut

use strict;
use warnings;
use Carp qw(confess cluck);

=head1 METHODS

=head2 new

  my $model = Artemis::Model->new(
      driver => 'MySQL',
      name   => 'dbname',
      user   => 'dbuser',
      pass   => 'dbpass',
  );

Constructs a model object

=cut

sub new {
    my $class = shift;
    my %args  = @_;
    bless \%args, $class;
}

sub _storage {
    my $self = shift;
    return $self->{'storage'} ||= do {
        my $driver = $self->{'driver'} || confess('driver missing');
        my $file = "Artemis/Storage/$driver.pm";
        require $file;
        $file->new(
            name => $self->{'name'} || confess('missing name'),
            user => $self->{'user'} || '',
            pass => $self->{'pass'} || '',
        );
    };
}

sub _expand {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my %map = (
        board             => 'Artemis::Board',
        symposium         => 'Artemis::Symposium',
        symposium_request => 'Artemis::SymposiumRequest',
    );
    my $class = $map{$label} || confess('label does not exist');
    return($label, $class);
}

=head2 insert

  my $object = $model->insert($label, %info);

Creates underlying storage record and returns it as an the object

=cut

sub insert {
    my $self  = shift;
    my $label = shift || confess('label missing');
    $self->_storage->insert($self->_expand($label), @_);
}

=head2 load

  my $object = $model->load($label, $id);

Loads underlying storage record and returns it as an object

=cut

sub load {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my $id    = shift || confess('id missing');
    $self->_storage->load($self->_expand($label), $id);
}

=head2 update

  my $new = $model->update($label, %info);

Updates underlying storage record and returns the updated object

=cut

sub update {
    my $self  = shift;
    my $label = shift || confess('label missing');
    $self->_storage->update($self->_expand($label), @_);
}

=head2 remove

  $model->remove($label, $id);

Deletes the underlying storage record

=cut

sub remove {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my $id    = shift || confess('id missing');
    $self->_storage->remove($self->_expand($label), $id);
}

1;
