use Test::Most tests => 5;
use strict;
use warnings;

use lib 't/lib';
use aliased 'App::Mimosa::Test::Mech';
use Test::DBIx::Class;
use Test::JSON;

my $mech = Mech->new;

fixtures_ok 'basic_ss';

{
    $mech->get_ok('/api/sequence/1/Solanum%20foobarium%20FAKE%20DNA%201.txt');
    ok(length($mech->content), 'got non-zero content length');
}


exit;

{
    $mech->get_ok('/api/sequence/1/Solanum%20foobarium%20FAKE%20DNA%201.json');
    my $json = $mech->content;

    is_valid_json( $json, 'it returns valid JSON') or diag $json;
}
{
    $mech->get_ok('/api/sequence/99/Solanum%20foobarium%20FAKE%20DNA%201.txt');
}
