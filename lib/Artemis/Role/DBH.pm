package Artemis::Role::DBH;

=head1 NAME

Artemis::Role::DBH

=cut

use strict;
use warnings;

use Role::Tiny;

our $config;
our $dbh;

=head2 config

Returns the config hash which stores settings such as connecting to the database

=cut

sub config { $config ||= require 'Artemis/config' }

=head2 dbh

The database handle

=cut

sub dbh {
    my $board = shift;
    $dbh ||= do {
        my $db = $board->config->{'db'};
        DBI->connect('dbi:mysql:'.$db->{'name'}, $db->{'user'}, $db->{'pass'}) or die "Could not connect";
    };
}

1;

__END__

=head1 NAME

Artemis::Role::DBH - Provides database handle

=cut

