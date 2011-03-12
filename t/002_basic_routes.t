use Test::More tests => 6;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;

fixtures_ok 'basic';

action_ok '/', 'a route handler is defined for /';
action_ok '/poweredby', 'a route handler is defined for /poweredby';
action_ok '/autocrud';
action_ok '/autocrud/bcs';
action_ok '/autocrud/bcs/organism';
