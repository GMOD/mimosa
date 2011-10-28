use Test::Most tests => 6;
use strict;
use warnings;
use Cwd;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;
use File::Spec::Functions;

fixtures_ok 'basic_ss';

my ($tdir, $file, $dbname);

BEGIN {
    use_ok 'App::Mimosa::Database';
    use App::Mimosa::Util qw/clean_up_indices/;
    $dbname = 'blastdb_test.nucleotide';
    $file   = "$dbname.seq";
    $tdir   = catdir(qw/t data/);
    clean_up_indices( $tdir, $dbname);
}

my $cwd  = getcwd;
chdir $tdir;
my $db = App::Mimosa::Database->new(
    db_basename => 'blastdb_test.nucleotide.seq',
    alphabet    => 'nucleotide',
    context     => app(),
);
isa_ok $db, 'App::Mimosa::Database';

lives_ok sub { $db->index }, 'index does not die';

is( $db->db->title, $file, 'title is correct');

can_ok $db, qw/db_basename alphabet index/;
