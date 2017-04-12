package Artemis::Storage::Mock;

use strict;
use warnings;

sub new {
    my $class = shift;
    my %args  = @_;
    bless \%args, $class;
}

sub insert { 1 }
sub load   { return { id => 1, foo => 'bar' } }
sub update { 1 }
sub remove { 1 }

1;

__END__

=head1 NAME

Artemis::Storage::Mock - A storage driver used as a mock interface for testing

=cut
