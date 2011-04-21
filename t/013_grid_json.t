use Test::Most tests => 2;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;

fixtures_ok 'basic_ss';

action_ok '/api/grid/json.json';
