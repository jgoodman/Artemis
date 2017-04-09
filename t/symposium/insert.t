#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Symposium::Test::Insert;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/../../lib";

use base qw(
    Artemis::TestBase::DB
    Artemis::TestBase::Symposium
);

sub main : Test(9) {
    my $self = shift;
    my $symposium = $self->symposium->insert();
    ok($symposium, 'Insert function returned true');

    my $state = 'INSERT_COMPLETE';
    my $row = $symposium->dbh->selectrow_hashref(
        'SELECT * FROM symposiums WHERE symposium_id = ?', {Slice => { }}, $symposium->id
    );
    ok($row, 'Function inserted database record');
    is($row->{'state'}, $state, 'Row has correct state');
    is($row->{'pid'},   $$,     'Row has matching pid');

    my $rows = $symposium->dbh->selectall_arrayref(
        'SELECT * FROM symposium_logs WHERE symposium_id = ?', {Slice => { }}, $symposium->id
    );
    is(scalar @$rows, 1, 'Function logged correct number rows to database') or do {
        return 'no records returned' unless scalar @$rows > 0;
    };

    $row = $rows->[0];
    ok($row->{'entry_date'},                        'Row has entry_date [log record]');
    like($row->{'meta'},       qr/^{"pid":"\d+"}$/, 'Row has correct meta [log record]');
    is($row->{'state'},        $state,              'Row has correct state [log record]');
    is($row->{'symposium_id'}, $symposium->id,      'Row has correct symposium_id [log record]');
}

