#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Symposium::Test::InitiativeCheck;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/../../lib";

use base qw(Artemis::TestBase::Symposium);

sub main : Test(1) {
    my $self = shift;
    $self->symposium->add_entities(@{$self->entities});
    my $initiatives = $self->symposium->initiative_check();
    is(scalar keys %$initiatives, 5, 'Initiative check works');
}

