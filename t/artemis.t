#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More tests => 7;
use Test::MockModule;

use_ok('Artemis::Piece');
use_ok('Artemis::Space');
use_ok('Artemis');

#------------------------- SETUP -------------------------#

# override config to use test config
my $m = Test::MockModule->new('Artemis');
{
    no warnings 'once';
    $m->mock('config', sub { $Artemis::config ||= require "$Bin/../test.artemis.conf" });
}

# create test database
(my $text = `cat $Bin/../lib/Artemis.pm`) =~ s/.*=head1 SQL\n(.+)=cut.*/$1/msg;
foreach my $sql (split(/;|\n\n/, $text)) {
    next unless $sql;
    if($sql =~ m|CREATE TABLE (\w+) |) {
        Artemis->dbh->do("DROP TABLE IF EXISTS $1");
    }
    die "Failed Database Setup!\n$sql" unless Artemis->dbh->do($sql);
}

#-------------------- MAIN ASSERTIONS --------------------#

my $a = Artemis->load(board_id => 1);
isa_ok($a, 'Artemis');

my $p = $a->piece(1);
ok($a->move_piece($p, dir => 'explore'), 'Moved piece');

ok($a->space(2)->contains($p), 'Space contains game piece');

is(
    $a->dbh->selectrow_hashref('SELECT space_id FROM pieces WHERE piece_id = ?', {}, $p->id)->{'space_id'},
    2,
    'Database has correct space_id for game piece'
);
