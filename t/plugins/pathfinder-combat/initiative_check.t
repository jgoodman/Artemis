#!/usr/bin/env perl

Test::Class->runtests;

package Artemis::Plugin::Pathfinder::Combat::Test::InitiativeCheck;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/../../../lib";

use base qw(Artemis::Plugin::Pathfinder::Combat::TestBase);

sub main : Test(1) {
    my $self = shift;
    my $participants = $self->participants;
    my $initiatives = $self->combat->initiative_check(@$participants);
    is(scalar keys %$initiatives, 5, 'Initiative check works');
}

