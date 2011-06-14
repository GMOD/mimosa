#!/usr/bin/env perl
use strict;
use warnings;
use Test::Most;

use lib 't/lib';
use App::Mimosa::Test;
use aliased 'App::Mimosa::Test::Mech';

my $mech = Mech->new;
$mech->get('/');
$mech->html_lint_ok('/ is valid HTML');

done_testing();
