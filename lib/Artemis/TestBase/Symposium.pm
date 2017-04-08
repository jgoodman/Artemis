package Artemis::TestBase::Symposium;

use strict;
use warnings;

use FindBin qw($Bin);
use File::Path qw(remove_tree);
use Test::More;
use Test::MockModule;

use base 'Artemis::TestBase::DB';

sub load_modules   : Test(startup => 1) {
    use_ok('Artemis::Symposium');
}

sub queue_dir     { "$Bin/../../.queue" }
sub pid_queue_dir { shift->queue_dir."/$$" }

sub entities {
    my $self = shift;
    return $self->{'entities'} ||= do {
        require Artemis::Symposium::Entity;
        [
            map { Artemis::Symposium::Entity->new($_) } (
                { id => 1, name => 'Gary',    DEX => 2 },
                { id => 2, name => 'Bob',     DEX => 2 },
                { id => 3, name => 'Sue',     DEX => 3 },
                { id => 4, name => 'Goblin1', DEX => 1 },
                { id => 5, name => 'Goblin2', DEX => 1 },
            )
        ]
    };
}

sub symposium {
    my $self = shift;
    $self->{'symposium'} ||= do {
        #require Artemis::Symposium;
        my $m = $self->{'mock_module'}->{'Artemis::Symposium'} = Test::MockModule->new('Artemis::Symposium');
        {
            no warnings 'once';
            $m->mock('config', sub { $Artemis::Symposium::config ||= require 'Artemis/config.test'});
        }
        Artemis::Symposium->new({
            queue_dir => $self->queue_dir,
            entity_timeout_limit => 20,
        })->insert;
    }
}

1;

__END__

=head1 NAME

Artemis::TestBase::Symposium - Base class for testing Artemis::Symposium

=cut

