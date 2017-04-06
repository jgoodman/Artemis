package Artemis::TestBase::DB;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;
use Test::MockModule;

use base 'Test::Class';

sub artemis {
    my $self = shift;
    $self->{'artemis'} = shift if scalar @_;
    $self->{'artemis'} ||= do { require Artemis; Artemis->new }
}

sub database_setup : Test(setup => 1) {
    my $self = shift;

    # override config to use test config
    my $m = $self->{'mock_module'}->{'Artemis'} = Test::MockModule->new('Artemis');
    {
        no warnings 'once';
        $m->mock('config', sub { $Artemis::config ||= require "$Bin/../test.artemis.conf" });
    }

    # create test database
    foreach my $sql (@{$self->sql_statements_create_tables}) {
        next unless $sql;
        if($sql =~ m|CREATE TABLE (\w+) |) {
            Artemis->dbh->do("DROP TABLE IF EXISTS $1");
        }
        die "Failed Database Setup!\n$sql" unless Artemis->dbh->do($sql);
    }

    pass('Database setup complete');
}

sub sql_statements_create_tables {
    my $self = shift;
    $self->{'create_sql'} ||= do {
        (my $text = `cat $Bin/../lib/Artemis.pm`) =~ s/.*=head1 SQL\n(.+)=cut.*/$1/msg;
        $text;
        [ split(/;|\n\n/, $text) ];
    };
}

1;
