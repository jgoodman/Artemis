package Artemis::Role::Debug;

use strict;
use warnings;

use Role::Tiny;

our $DEBUG = exists $ENV{'DEBUG'} ? $ENV{'DEBUG'} : 0;

sub debug {
    my $self = shift;
    my $msg  = shift;
    my $level = shift || 1;

    return unless $DEBUG >= $level;

    my $i = 0;
    my ($pkg, $sub);
    while(! $sub || $sub =~ m/^(?:.+::)?(?:debug|status)$/) {
        $i++;
        ($pkg, $sub) = ((caller($i))[0,3] =~ m/^(.+)::([^:]+)$/);
    }

    my $line = '['.time."] $pkg - $sub - $msg\n";
    $line = "# $line" if $0 =~ m/\.t$/; # comment for t scripts
    print $line;
}

1;

__END__

=head1 NAME

Artemis::Role::Debug - Provide debug helper method

=cut


