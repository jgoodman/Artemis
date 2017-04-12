#!/usr/bin/env perl

use strict;
use warnings;
use File::Path qw(remove_tree);
use Test::More tests => 14;
use FindBin qw($Bin);
use lib "$Bin/../lib";

my $name = "$Bin/../.storage/artemis_test";
mkdir $name unless -d $name;

use_ok('Artemis::Storage::FileSystem');

my $storage = Artemis::Storage::FileSystem->new(name => $name);
ok($storage, "Create storage object");

my $label = 'test';
my $class = 'Artemis::Test';
my %info  = ( foo => 'bar' );
my $id    = 1;
my $file  = "$name/$class/$id";
ok($storage->insert($label, $class, %info), 'Insert storage record');
ok(-e $file, 'File exists');

my $object = $storage->load($label, $class, $id);
ok($object, 'Load storage record');
isa_ok($object, $class);
is($object->{'id'},  $id,   'Loaded object has id');
is($object->{'foo'}, 'bar', 'Loaded object has foo');

$info{'id'}  = $id;
$info{'foo'} = 'baz';
my $new = $storage->update($label, $class, %info);
ok($new, 'Update storage record');
isa_ok($new, $class);
is($new->{'id'},  $id,   'Updated object has id');
is($new->{'foo'}, 'baz', 'Updated object has foo');

ok($storage->remove($label, $class, $id), 'Removed file');
ok(!-e $file, 'File no longer exists');

END { remove_tree($name) };

package Artemis::Test;
use strict;
use warnings;
use Carp;
sub new {
    my $class = shift;
    my %info  = @_;
    bless(\%info, $class);
}
