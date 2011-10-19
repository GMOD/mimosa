use Test::Most tests => 6;
use strict;
use warnings;
use Cwd;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;
use File::Spec::Functions;

fixtures_ok 'basic_ss';

sub clean_up_indices {
    my ($dir, $name) = @_;
    for my $f (map { "$name.$_" } qw/nsi nhr nin nsd nsq/) {
        diag "unlink $dir/$f" if $ENV{DEBUG};
        unlink catfile($dir,$f);
    }
}

my ($tdir, $file);

BEGIN {
    use_ok 'App::Mimosa::Database';

    $file = 'blastdb_test.nucleotide.seq';
    $tdir = catdir(qw/t data/);
    clean_up_indices( $tdir, $file);
}

my $cwd  = getcwd;
chdir $tdir;
my $db = App::Mimosa::Database->new(
    db_basename => $file,
    alphabet    => 'nucleotide',
    context     => app(),
);
isa_ok $db, 'App::Mimosa::Database';

lives_ok sub { $db->index }, 'index does not die';

is( $db->db->title, $file, 'title is correct');

can_ok $db, qw/db_basename alphabet index/;

END {
    chdir $cwd;
    clean_up_indices( $tdir, $file );
}
