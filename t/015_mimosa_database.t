use Test::Most tests => 4;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;

fixtures_ok 'basic_ss';

BEGIN{ use_ok 'App::Mimosa::Database' }

my $job = App::Mimosa::Database->new( db_basename => "foo", alphabet => 'protein');
isa_ok $job, 'App::Mimosa::Database';

can_ok $job, qw/db_basename alphabet index/;

