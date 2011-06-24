#!/usr/bin/env perl
use strict;
use warnings;
use Test::Most;

use lib 't/lib';
use App::Mimosa::Test;
use aliased 'App::Mimosa::Test::Mech';

my $mech = Mech->new( autolint => 1 );

my @urls = qw{/ /submit};

for my $url (@urls) {
    $mech->get_ok($url);
}

done_testing();
