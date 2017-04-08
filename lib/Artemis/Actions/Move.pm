package Artemis::Actions::Move;

use strict;
use warnings;

use Artemis::Board;

use Role::Tiny::With;
with 'Artemis::Role::Debug';

sub execute {
    my $class = shift;
    my $args  = shift;

    my $self = bless $args, $class;

    $self->debug('Move action');
    
    for (qw(board_id piece_id)) {
        die "missing $_" unless exists $args->{$_};
    }
    die "needs dir or to" unless exists $args->{'dir'} || exists $args->{'to'};

    my $board = Artemis::Board->load(board_id => $args->{'board_id'});

    my $how = exists $args->{'dir'} ? 'dir' : 'to';
    $board->move_piece($args->{'piece_id'}, $how => $args->{$how});

    return 1;
}

1;

__END__

=head1 NAME

Artemis::Actions::Move - Action to move a piece on the board

=cut

