#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Action::EnterSymposium::Test;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/../../lib";

use base qw(
    Artemis::TestBase::DB
    Artemis::TestBase::Symposium
);

sub load_modules : Test(startup => +1) {
    shift->SUPER::load_modules;
    use_ok('Artemis::Action::EnterSymposium');
}

sub insert : Test(1) {
    my $self = shift;
    local $TODO = 'Code Artemis::Symposium->insert method';
    ok(
        eval { Artemis::Action::EnterSymposium->execute({entities => $self->entities}) },
        'Execution returned true'
    );
}

sub load : Test(1) {
    my $self = shift;

    local $TODO = 'Setup existing symposium then pass in id';
    ok(
        eval { Artemis::Action::EnterSymposium->execute({entities => $self->entities}) },
        'Execution returned true'
    );
}

