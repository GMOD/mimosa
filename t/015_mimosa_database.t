use Test::Most tests => 6;
use strict;
use warnings;
use Cwd;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;
use File::Spec::Functions;

fixtures_ok 'basic_ss';

BEGIN{ use_ok 'App::Mimosa::Database' }


my $cwd = getcwd;

chdir catdir(qw/t data/);

my $db = App::Mimosa::Database->new(
    db_basename => catfile(qw/blastdb_test.nucleotide/),
    alphabet    => 'protein'
);
isa_ok $db, 'App::Mimosa::Database';

lives_ok sub { $db->index }, 'index does not die';

is( $db->db->title, 'blastdb_test.nucleotide', 'title is correct');

can_ok $db, qw/db_basename alphabet index/;

chdir $cwd;
