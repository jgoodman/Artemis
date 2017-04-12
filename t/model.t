#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 8;
use Test::MockModule;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use_ok('Artemis::Model');
can_ok('Artemis::Model', qw(insert load update remove _storage _config));

my $m = Test::MockModule->new('Artemis::Model');
$m->mock('_config', sub {
        return +{ model => { driver=>'Mock', name => 'mock' } }
});

my $model = Artemis::Model->new;
ok($model, "Create model object");

isa_ok($model->_storage, 'Artemis::Storage::Mock', 'StorageDriver');

my $label = 'test';
my %info  = ( foo => 'bar' );
my $id    = 1;
ok($model->insert($label, %info), 'Insert record');
ok($model->load($label, $id),     'Load record');
ok($model->update($label, %info), 'Update record');
ok($model->remove($label, $id),   'Removed record');

