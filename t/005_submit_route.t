use Test::Most tests => 3;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;

use Catalyst::Test 'App::Mimosa';
use File::Slurp qw/slurp/;
use HTTP::Request::Common;
use File::Spec::Functions;
use Test::DBIx::Class;

fixtures_ok 'basic';

my $seq = slurp(catfile(qw/t data blastdb_test.nucleotide seq.fasta/));
{
    my $response = request POST '/submit', [
                    program                => 'blastn',
                    sequence               => $seq,
                    maxhits                => 100,
                    matrix                 => 'BLOSUM62',
                    evalue                 => 0.1,
                    mimosa_sequence_set_id => 1,
                    alphabet               => 'nucleotide',
    ];
    is($response->code, 200, '/submit returns 200');
}

{
    my $f = sub {
        return request POST '/submit', [
                    program  => 'blastn',
                    sequence => $seq,
                    maxhits  => 100,
                    alphabet => 'nucleotide',
                    matrix   => 'BLOSUM62',
                    evalue   => 0.1,
       ];
    };
    my $res = $f->();
    is($res->code, 400, '/submit returns 400 without a mimosa_sequence_set_id');
}


