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
    my $participants = $self->participants;
    my $initiatives = $self->symposium->initiative_check(@$participants);
    is(scalar keys %$initiatives, 5, 'Initiative check works');
}

