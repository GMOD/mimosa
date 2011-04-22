use Test::Most tests => 12;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;
use Test::JSON;
use JSON::Any;

fixtures_ok 'basic_ss';
fixtures_ok 'basic_ss_organism';
fixtures_ok 'basic_organism';

action_ok '/api/grid/json.json';

my $r    = request('/api/grid/json.json');
my $json = $r->content;
my $j    = JSON::Any->new;

is_valid_json( $json, 'it returns valid JSON') or diag $json;
cmp_ok(length $json,'>', 3, 'got non-empty-looking json');

like($json, qr/mimosa_sequence_set_id/, 'mimosa_sequence_set_id appears in JSON');
like($json, qr/description/, 'description appears in JSON');
like($json, qr/blargwart/, 'blargwart common_name appears');

my $obj = $j->from_json($json);

map { like($_->{common_name},qr/(NA|blargwart)/, "common name " . $_->{common_name} . " looks reasonable") } @$obj;
