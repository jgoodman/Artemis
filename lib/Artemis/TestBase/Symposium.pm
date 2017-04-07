package Artemis::TestBase::Symposium;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;
use File::Path qw(remove_tree);

use Artemis::Symposium::Participant;

use base 'Test::Class';

sub queue_dir     { "$Bin/../../.queue" }
sub pid_queue_dir { shift->queue_dir."/$$" }

sub participants {
    return [
        map { Artemis::Symposium::Participant->new($_) } (
            { id => 1, name => 'Gary',    DEX => 2 },
            { id => 2, name => 'Bob',     DEX => 2 },
            { id => 3, name => 'Sue',     DEX => 3 },
            { id => 4, name => 'Goblin1', DEX => 1 },
            { id => 5, name => 'Goblin2', DEX => 1 },
        )
    ]
}

sub symposium {
    my $self = shift;
    $self->{'symposium'} ||= Artemis::Symposium->new({
        queue_dir => $self->queue_dir,
        participant_timeout_limit => 20,
    });
}

sub load_modules   : Test(startup => 1) {
    use_ok('Artemis::Symposium');
}

1;

__END__

=head1 NAME

Artemis::TestBase::Symposium - Base class for testing Artemis::Symposium

=cut

