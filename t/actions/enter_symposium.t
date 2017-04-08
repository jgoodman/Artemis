#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Actions::EnterSymposium::Test;

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
    use_ok('Artemis::Actions::EnterSymposium');
}

sub create : Test(1) {
    my $self = shift;
    local $TODO = 'Finish coding this';
    ok(
        Artemis::Actions::EnterSymposium->execute({participants => $self->participants}),
        'Execution returned true'
    );
}

sub load : Test(1) {
    my $self = shift;

    local $TODO = 'Finish coding this';
    ok(
        Artemis::Actions::EnterSymposium->execute({participants => $self->participants}),
        'Execution returned true'
    );
}

