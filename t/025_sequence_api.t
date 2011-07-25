use Test::Most tests => 5;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;
use Test::JSON;

fixtures_ok 'basic_ss';

{
    my $r = request('/api/sequence/1/Solanum%20foobarium%20FAKE%20DNA%201.txt');
    my $content = $r->content;
    ok(length($content), 'got non-zero content length');
    is($r->code, 200, 'got a 200');
}
{
    my $r = request('/api/sequence/1/Solanum%20foobarium%20FAKE%20DNA%201.json');
    my $json = $r->content;
    is($r->code, 200, 'got a 200');

    is_valid_json( $json, 'it returns valid JSON') or diag $json;
}
