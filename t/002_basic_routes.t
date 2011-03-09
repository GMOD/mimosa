use Test::More tests => 2;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;

fixtures_ok 'basic';

action_ok '/', 'a route handler is defined for /';
