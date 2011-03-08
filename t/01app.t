#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use lib 't/lib';
use App::Mimosa::Test;

BEGIN { use_ok 'Catalyst::Test', 'App::Mimosa' }

ok( request('/')->is_success, 'Request should succeed' );

done_testing();
