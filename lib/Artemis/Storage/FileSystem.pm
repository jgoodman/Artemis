package Artemis::Storage::FileSystem;

=head1 NAME

Artemis::Storage::FileSystem - Storage driver for file system

=cut

use strict;
use warnings;

use Carp qw(confess);

use File::Slurp;
use JSON;

=head1 METHODS

=head2 new

  my $storage = Artemis::Storage::FileSystem->new(name => 'file_path');

Constructs a storage object

=cut

sub new {
    my $class = shift;
    my %args  = @_;
    my $name  = $args{'name'};
    mkdir $name unless -d $name;
    bless \%args, $class;
}

=head2 name

Accessor method

=cut

sub name { shift->{'name'} }

=head2 insert

  $storage->insert($label, %info);

Create record

=cut

sub insert {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my %info  = @_;

    my $dir = $self->name."/$label";
    mkdir $dir unless -e $dir;

    my $inc = "$dir/.inc";
    my $id  = -e $inc ? read_file($inc) : 0;
    $info{'id'} = ++$id;

    write_file("$dir/$id", encode_json(\%info)) || confess('failed to write file');
    write_file($inc, $id);

    return 1;
}

=head2 load

  my $hashref = $storage->load($label, $id);

Load record and return it as an hashref

=cut

sub load {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my $id    = shift || confess('id missing');

    my $file = $self->name."/$label/$id";
    confess("id [$id] not found for label [$label]") unless -e $file;
    my $hash = decode_json read_file($file);
    $hash->{'id'} = $id;

    return $hash;
}

=head2 update

  $storage->update($label, %info);

Updates record

=cut

sub update {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my %info  = @_;

    my $id     = $info{'id'};
    my $file = $self->name."/$label/$id";
    confess("id [$id] not found for label [$label]") unless -e $file;
    unlink $file;

    write_file($file, encode_json \%info) || confess('failed to write file');
}

=head2 remove

  $storage->remove($label, $id);

Deletes the record

=cut

sub remove {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my $id    = shift || confess('id missing');

    my $file = $self->name."/$label/$id";
    confess("id [$id] not found for label [$label]") unless -e $file;
    unlink $file;
}

1;
