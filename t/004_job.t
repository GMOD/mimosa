use Test::More tests => 3;
use strict;
use warnings;

use lib 'lib';

BEGIN{ use_ok 'App::Mimosa::Job' }

my $job = App::Mimosa::Job->new;
isa_ok $job, 'App::Mimosa::Job';

can_ok $job, qw/program input_file output_file run/;
