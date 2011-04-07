use Test::Most tests => 2;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;

use Catalyst::Test 'App::Mimosa';
use File::Slurp qw/slurp/;
use HTTP::Request::Common;
use File::Spec::Functions;
use Test::DBIx::Class;

fixtures_ok 'basic';

my $response = request GET '/api/report/raw/42', [
];
is($response->code, 400, 'Downloading the raw report of an invalid Job id should fail');
diag($response->content) if $response->code != 400;
