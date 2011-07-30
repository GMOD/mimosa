use Test::Most tests => 4;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use aliased 'App::Mimosa::Test::Mech';
use Test::DBIx::Class;
use Test::JSON;

my $mech = Mech->new;

fixtures_ok 'basic_ss';

{
    $mech->get_ok('/api/sequence/1/SGN-E741072.txt');# or diag $mech->content;
    ok(length($mech->content), 'got non-zero content length');
}

{
    $mech->get('/api/sequence/99/Solanum%20foobarium%20FAKE%20DNA%201.txt');
    is($mech->status, 400, 'invalid sequence set id gives a 400');
}

exit;

{
    $mech->get_ok('/api/sequence/1/Solanum%20foobarium%20FAKE%20DNA%201.json');
    my $json = $mech->content;

    is_valid_json( $json, 'it returns valid JSON') or diag $json;
}
