#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Symposium::Test::Destroy;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/../../lib";

use Artemis::Symposium;
use base qw(
    Artemis::TestBase::DB
    Artemis::TestBase::Symposium
);

sub main : Test(3) {
    my $self = shift;

    my $symposium = $self->symposium->insert();

    $symposium->DESTROY;

    my $state = 'DESTROY_COMPLETE';
    my $row = $symposium->dbh->selectrow_hashref(
        'SELECT * FROM symposiums WHERE symposium_id = ?', {Slice => { }}, $symposium->id
    );
    is($row->{'state'}, $state, 'Row has correct state');
    is($row->{'pid'},   0,      'Row no longer has pid');

    my $rows = $symposium->dbh->selectall_arrayref(
        'SELECT * FROM symposium_logs WHERE symposium_id = ?', {Slice => { }}, $symposium->id
    );

    ok(! -e $symposium->pid_queue_dir, 'Cleanned up queue dir');
}

