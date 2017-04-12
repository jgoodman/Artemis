#!/usr/bin/env perl

use strict;
use warnings;
use File::Path qw(remove_tree);
use Test::More tests => 12;
use FindBin qw($Bin);
use lib "$Bin/../../lib";

my $name = "$Bin/../../.storage/artemis_test";
mkdir $name unless -d $name;

use_ok('Artemis::Storage::FileSystem');
can_ok('Artemis::Storage::FileSystem', qw(insert load update remove));

my $storage = Artemis::Storage::FileSystem->new(name => $name);
ok($storage, "Create storage object");

my $label = 'test';
my %info  = ( foo => 'bar' );
my $id    = 1;
my $file  = "$name/$label/$id";
ok($storage->insert($label, %info), 'Insert storage record');
ok(-e $file, 'File exists');

my $hash = $storage->load($label, $id);
ok($hash, 'Load storage record');
is($hash->{'id'},  $id,   'Loaded object has id');
is($hash->{'foo'}, 'bar', 'Loaded object has foo');

$info{'id'}  = $id;
$info{'foo'} = 'baz';
ok($storage->update($label, %info), 'Update storage record');
is($storage->load($label, $id)->{'foo'}, 'baz', 'Updated object has new foo value');

ok($storage->remove($label, $id), 'Removed file');
ok(!-e $file, 'File no longer exists');

END { remove_tree($name) };

