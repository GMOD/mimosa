use Test::More tests => 2;
use strict;
use warnings;

use lib 'lib';

BEGIN{ use_ok 'App::Mimosa::Aligner' }

my $aligner = App::Mimosa::Aligner->new;
isa_ok $aligner, 'App::Mimosa::Aligner';
