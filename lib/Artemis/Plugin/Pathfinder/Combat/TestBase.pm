package Artemis::Plugin::Pathfinder::Combat::TestBase;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;
use File::Path qw(remove_tree);

use Artemis::Plugin::Pathfinder::Combat::Participant;

use base 'Test::Class';

sub queue_dir     { "$Bin/../../../.queue" }
sub pid_queue_dir { shift->queue_dir."/$$" }

sub participants {
    return [
        map { Artemis::Plugin::Pathfinder::Combat::Participant->new($_) } (
            { id => 1, name => 'Gary',    DEX => 2 },
            { id => 2, name => 'Bob',     DEX => 2 },
            { id => 3, name => 'Sue',     DEX => 3 },
            { id => 4, name => 'Goblin1', DEX => 1 },
            { id => 5, name => 'Goblin2', DEX => 1 },
        )
    ]
}

sub combat {
    my $self = shift;
    $self->{'combat'} ||= Artemis::Plugin::Pathfinder::Combat->new({
        queue_dir => $self->queue_dir,
        participant_timeout_limit => 20,
    });
}

sub load_modules   : Test(startup => 1) {
    use_ok('Artemis::Plugin::Pathfinder::Combat');
}

1;
