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

  my $id = $storage->insert($label, %info);

Create db record

=cut

sub insert {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my %info  = @_;

    my @cols = sort keys %info;
    my $columns = join ', ', @cols;
    my $holders = join ', ', map { '?' } @cols;
    my @values  = map { $info{$_} } @cols;
    $self->_dbh->do("INSERT INTO $label ($columns) VALUES ($holders)", { }, @values)
        || confess("Failed to insert row [$label]");

    return $self->_dbh->last_insert_id(undef, undef, $label, undef)
}

=head2 load

  my $row = $storage->load($label, $id);

Load record and return it as a hashref

=cut

sub load {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my $id    = shift || confess('id missing');
    return $self->_dbh->selectrow_hashref("SELECT * FROM $label WHERE id = ?", {}, $id);
}

=head2 update

  my $new = $storage->update($label, %info);

Updates record

=cut

sub update {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my %info  = @_;

    my $id     = $info{'id'};

    my @cols   = sort keys %info;
    my $bind   = join ', ', map { $_.' = ?' } @cols;
    my @values = map { $info{$_} } @cols;

    return $self->_dbh->do("UPDATE $label SET $bind", { }, @values);
}

=head2 remove

  $storage->remove($label, $id);

Deletes the record

=cut

sub remove {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my $id    = shift || confess('id missing');

    return $self->_dbh->do("DELETE FROM $label WHERE id = ?", {}, $id) || confess("Failed to delete row [$label]");
}

1;
