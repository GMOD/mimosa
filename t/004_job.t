use Test::More tests => 3;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;

BEGIN{ use_ok 'App::Mimosa::Job' }

my $job = App::Mimosa::Job->new( db_basename => "foo" );
isa_ok $job, 'App::Mimosa::Job';

can_ok $job, qw/program input_file output_file run db_basename/;
