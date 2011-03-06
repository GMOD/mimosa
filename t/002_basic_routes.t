use Test::More tests => 1;
use strict;
use warnings;

use Catalyst::Test 'App::Mimosa';

use lib 't/lib';
use App::Mimosa::Test;

action_ok '/', 'a route handler is defined for /';
