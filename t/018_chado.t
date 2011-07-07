use Test::Most tests => 1;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;

use Catalyst::Test 'App::Mimosa';
use Bio::Chado::Schema::Test;

my $schema = Bio::Chado::Schema::Test->init_schema(
    deploy            => 1,
    populate          => 1,
);

isa_ok($schema, 'Bio::Chado::Schema');

my $bcs_db = "t/var/BCS.db";

# Now deploy the mimosa schema

