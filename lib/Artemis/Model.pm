package Artemis::Model;

=head1 NAME

Artemis::Model - Unified interface for storing and retrieving data

=cut

use strict;
use warnings;
use Carp qw(confess cluck);

our $CONFIG;

=head1 METHODS

=head1 SYNOPSIS

  # In Artemis/config file...
  {
      model => {
          driver => 'MySQL',
          name   => 'dbname',
          user   => 'dbuser',
          pass   => 'dbpass',
      }
  }

  my $model = Artemis::Model->new;;

  # Create
  my $id = $model->insert($label, %info);

  # Retrieve
  my $hash = $model->load($label, $id);
  my @rows = $model->search($label, $field, $id);

  # Update
  $model->update($label, %info);

  # Delete
  $model->remove($label, $id);

=head2 new

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
        my $opt = $self->_config->{'model'};

        my $driver = $opt->{'driver'} || confess('driver missing');
        my $file = "Artemis/Storage/$driver.pm";
        require $file;

        my $class = "Artemis::Storage::$driver";
        $class->new(
            name => $opt->{'name'} || confess('missing name'),
            user => $opt->{'user'} || '',
            pass => $opt->{'pass'} || '',
        );
    };
}

sub _config { $CONFIG ||= require 'Artemis/config' }

=head2 insert

Creates underlying storage record

=cut

sub insert {
    my $self  = shift;
    my $label = shift || confess('label missing');
    $self->_storage->insert($label, @_);
}

=head2 load

Loads underlying storage record

=cut

sub load {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my $id    = shift || confess('id missing');
    $self->_storage->load($label, $id);
}

=head2 search

Search for underlying storage record

=cut

sub search {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my $field = shift || confess('field missing');
    my $id    = shift || confess('id missing');
    $self->_storage->search($label, $field, $id);
}

=head2 update

Updates underlying storage record

=cut

sub update {
    my $self  = shift;
    my $label = shift || confess('label missing');
    $self->_storage->update($label, @_);
}

=head2 remove

Deletes the underlying storage record

=cut

sub remove {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my $id    = shift || confess('id missing');
    $self->_storage->remove($label, $id);
}

1;
