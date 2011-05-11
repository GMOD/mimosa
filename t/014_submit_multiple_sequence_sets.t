use Test::Most tests => 2;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;

use Catalyst::Test 'App::Mimosa';
use File::Slurp qw/slurp/;
use HTTP::Request::Common;
use File::Spec::Functions;

fixtures_ok 'basic_ss';

my $seq = slurp(catfile(qw/t data blastdb_test.nucleotide.seq/));
{
    my $response = request POST '/submit', [
                    program                => 'blastn',
                    sequence               => $seq,
                    maxhits                => 100,
                    matrix                 => 'BLOSUM62',
                    evalue                 => 0.1,
                    mimosa_sequence_set_ids=> "1,2",
                    alphabet               => 'nucleotide',
    ];
    is($response->code, 200, '/submit returns 200');
    diag($response->content) if $response->code != 200;
    like($response->content,qr!Download Raw Report.*/api/report/raw/\d+!, 'download raw report link')
}
