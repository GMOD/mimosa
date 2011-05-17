use Test::Most tests => 10;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;
use Test::JSON;

fixtures_ok 'basic_ss';
fixtures_ok 'basic_ss_organism';
fixtures_ok 'basic_organism';

action_ok '/api/grid/json.json';

my $r    = request('/api/grid/json.json');
my $json = $r->content;

is_valid_json( $json, 'it returns valid JSON') or diag $json;

# 3 = length("{ }")
cmp_ok(length $json,'>', 3, 'got non-empty-looking json');

like($json, qr/mimosa_sequence_set_id/, 'mimosa_sequence_set_id appears in JSON');
like($json, qr/description/, 'description appears in JSON');
like($json, qr/blargwart/, 'blargwart common_name appears');

# This test depends on the data in t/etc/schema.pl and which data the JSON controller returns
is_json($json, <<JSON, 'got the JSON we expected');
{"rows":[{"mimosa_sequence_set_id":1,"name":"NA","description":"test db","alphabet":"nucleotide"},{"mimosa_sequence_set_id":2,"name":"NA","description":"DNA sequences for S. foobarium","alphabet":"nucleotide"},{"mimosa_sequence_set_id":3,"name":"Blargopod foobarium (blargwart)","description":"Protein sequences for B. foobarium","alphabet":"protein"}],"total":2}
JSON

#diag $json;

