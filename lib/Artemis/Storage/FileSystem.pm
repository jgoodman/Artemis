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

  my $object = $storage->insert($label, $class, %info);

Create record and return it as an the object

=cut

sub insert {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my $class = shift || confess('class missing');
    my %info  = @_;

    my $dir = $self->name."/$class";
    mkdir $dir unless -e $dir;

    my $inc = "$dir/.inc";
    my $id  = -e $inc ? read_file($inc) : 0;
    $info{'id'} = ++$id;

    my $object = $class->new(%info);

    write_file("$dir/$id", encode_json(\%info)) || confess('failed to write file');
    write_file($inc, $id);

    return $object;
}

=head2 load

  my $object = $storage->load($label, $class, $id);

Load record and return it as an object

=cut

sub load {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my $class = shift || confess('class missing');
    my $id    = shift || confess('id missing');

    my $file = $self->name."/$class/$id";
    confess("id [$id] not found for class [$class]") unless -e $file;
    my $hash = decode_json read_file($file);
    $hash->{'id'} = $id;

    return $class->new(%$hash);
}

=head2 update

  my $new = $storage->update($label, $class, %info);

Updates record and return the updated object

=cut

sub update {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my $class = shift || confess('class missing');
    my %info  = @_;

    my $id     = $info{'id'};
    my $object = $class->new(%info);

    my $file = $self->name."/$class/$id";
    confess("id [$id] not found for class [$class]") unless -e $file;
    unlink $file;

    write_file($file, encode_json \%info) || confess('failed to write file');

    return $object;
}

=head2 remove

  $storage->remove($label, $class, $id);

Deletes the record

=cut

sub remove {
    my $self  = shift;
    my $label = shift || confess('label missing');
    my $class = shift || confess('class missing');
    my $id    = shift || confess('id missing');

    my $file = $self->name."/$class/$id";
    confess("id [$id] not found for class [$class]") unless -e $file;
    unlink $file;
}

1;
