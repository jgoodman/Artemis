package Artemis::TestBase::DB;

use strict;
use warnings;
use Carp qw(confess);

use FindBin qw($Bin);
use Test::More;
use Test::MockModule;

use base 'Test::Class';

sub artemis { goto &board }
sub board {
    my $self = shift;
    $self->{'board'} = shift if scalar @_;
    $self->{'board'} ||= do {
        require Artemis::Board;
        Artemis::Board->new
    }
}

sub database_setup : Test(setup => 1) {
    my $self = shift;

    # override config to use test config
    my $m = $self->{'mock_module'}->{'Artemis::Board'} = Test::MockModule->new('Artemis::Board');
    {
        no warnings 'once';
        $m->mock('config', sub { $Artemis::Board::config ||= require 'Artemis/config.test' });
    }

    # create test database
    foreach my $sql (@{$self->sql_statements_create_tables}) {
        next unless $sql;
        if($sql =~ m|CREATE TABLE (\w+) |) {
            Artemis::Board->dbh->do("DROP TABLE IF EXISTS $1");
        }
        confess "Failed Database Setup!\n$sql" unless Artemis::Board->dbh->do($sql);
    }

    pass('Database setup complete');
}

sub sql_statements_create_tables {
    my $self = shift;
    $self->{'create_sql'} ||= do {
        my $file = $INC{'Artemis/Board.pm'};
        $file =~ s|lib/Artemis/Board\.pm$|docs/create.sql|;
        #(my $text = `cat $file`) =~ s/.*=head1 SQL\n(.+)=cut.*/$1/msg;
        my $text = `cat $file`;
        [ split(/\n\n/, $text) ];
    };
}

1;

__END__

=head1 NAME

Artemis::TestBase::DB - Base class for database setup and teardown for testing

=cut

