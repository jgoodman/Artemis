#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More tests => 5;
use Test::MockModule;

use_ok('Artemis::Piece');
use_ok('Artemis::Space');
use_ok('Artemis');

my $m = Test::MockModule->new('Artemis');
$m->mock('config', sub { $Artemis::config ||= require 'test.artemis.conf' });

# Setup Testing Database
(my $text = `cat $Bin/../lib/Artemis.pm`) =~ s/.*=head1 SQL\n(.+)=cut.*/$1/msg;
foreach my $sql (split(/;|\n\n/, $text)) {
    next unless $sql;
    if($sql =~ m|CREATE TABLE (\w+) |) {
        Artemis->dbh->do("DROP TABLE IF EXISTS $1");
    }
    die "Failed Database Setup!\n$sql" unless Artemis->dbh->do($sql);
}

my $a = Artemis->new(board_id => 1);
isa_ok($a, 'Artemis');

ok($a->space(1), 'Get space_id 1');

