use Test::More tests => 4;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;

fixtures_ok 'basic';

BEGIN{ use_ok 'App::Mimosa::Job' }

my $job = App::Mimosa::Job->new( db_basename => "foo", alphabet => 'protein' );
isa_ok $job, 'App::Mimosa::Job';

can_ok $job, qw/program input_file output_file run db_basename alphabet/;
