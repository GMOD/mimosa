use Test::Most tests => 3;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;
use Test::JSON;

fixtures_ok 'basic_ss';

action_ok '/api/grid/json.json';

my $r = request('/api/grid/json.json');

is_valid_json( $r->content, 'it returns valid JSON');
