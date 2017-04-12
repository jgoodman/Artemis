package Artemis::Storage::MySQL;

=head1 NAME

Artemis::Storage::MySQL - Storage driver for file system

=cut

use strict;
use warnings;

use Carp qw(confess);

use File::Slurp;
use JSON;

=head1 METHODS

=head2 new

  my $storage = Artemis::Storage::MySQL->new(name => 'dbname', user => 'dbuser', pass => 'dbpass');

Constructs a storage object

=cut

sub new {
    my $class = shift;
    my %args  = @_;
    bless \%args, $class;
}

our $DBH;
sub _dbh {
    my $self = shift;
    $DBH ||= do {
        DBI->connect(
            ($self->{'dbd'}  || 'dbi:mysql:'.$self->{'name'}),
            ($self->{'user'} || ''),
            ($self->{'pass'} || ''),
        ) or confess("Could not connect");
    };
}

=head2 name

Accessor method

=cut

sub name { shift->{'name'} }

=head2 insert

  my $object = $storage->insert($class, %info);

Create record and return it as an the object

=cut

sub insert {
    my $self  = shift;
    my $class = shift || confess('class missing');
    my %info  = @_;

    my $object = $class->new(%info);

    return $object;
}

=head2 load

  my $object = $storage->load($class, $id);

Load record and return it as an object

=cut

sub load {
    my $self  = shift;
    my $class = shift || confess('class missing');
    my $id    = shift || confess('id missing');

    return $class->new(%$hash);
}

=head2 update

  my $new = $storage->update($class, %info);

Updates record and return the updated object

=cut

sub update {
    my $self  = shift;
    my $class = shift || confess('class missing');
    my %info  = @_;

    my $id     = $info{'id'};
    my $object = $class->new(%info);

    return $object;
}

=head2 remove

  $storage->remove($class, $id);

Deletes the record

=cut

sub remove {
    my $self  = shift;
    my $class = shift || confess('class missing');
    my $id    = shift || confess('id missing');

}

1;
