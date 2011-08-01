use Test::Most tests => 4;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;
use Test::JSON;

fixtures_ok 'basic_ss';

{
    my $r = request '/api/sequence/1/SGN-E741072.txt';
    is($r->code, 200 );
    ok(length($r->content), 'got non-zero content length');
}

{
    my $r = request '/api/sequence/99/Solanum%20foobarium%20FAKE%20DNA%201.txt';
    is($r->code, 400 );
}

