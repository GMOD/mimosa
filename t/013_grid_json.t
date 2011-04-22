use Test::Most tests => 8;
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

my $r = request('/api/grid/json.json');
my $content = $r->content;

is_valid_json( $content, 'it returns valid JSON');
cmp_ok(length $content,'>', 3, 'got non-empty-looking content');

like($content, qr/mimosa_sequence_set_id/, 'mimosa_sequence_set_id appears in JSON');
like($content, qr/description/, 'description appears in JSON');

#diag $content;
