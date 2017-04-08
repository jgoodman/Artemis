#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Test;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/../lib";
use base qw(Artemis::TestBase::DB);

sub enter_combat : Test(1) {
    my $self = shift;
    local $TODO = 'Code step';
    fail('Step completed: '.$self->current_method);
}

sub generate_pieces : Test(1) {
    my $self = shift;
    local $TODO = 'Code step';
    fail('Step completed: '.$self->current_method);
}

sub initiave_check : Test(1) {
    my $self = shift;
    local $TODO = 'Code step';
    fail('Step completed: '.$self->current_method);
}

sub move_player : Test(1) {
    my $self = shift;
    local $TODO = 'Code step';
    fail('Step completed: '.$self->current_method);
}

sub move_npc : Test(1) {
    my $self = shift;
    local $TODO = 'Code step';
    fail('Step completed: '.$self->current_method);
}

sub player_attacks_npc : Test(1) {
    my $self = shift;
    local $TODO = 'Code step';
    fail('Step completed: '.$self->current_method);
}

sub subtract_npc_hp : Test(1) {
    my $self = shift;
    local $TODO = 'Code step';
    fail('Step completed: '.$self->current_method);
}

sub end_combat : Test(1) {
    my $self = shift;
    local $TODO = 'Code step';
    fail('Step completed: '.$self->current_method);
}


