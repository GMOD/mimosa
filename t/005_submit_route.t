use Test::Most tests => 2;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;

use Catalyst::Test 'App::Mimosa';
use File::Slurp qw/slurp/;
use HTTP::Request::Common;

my $seq = slurp("t/data/blastdb_test.nucleotide.seq");
{
    my $response = request POST '/submit', [
                    program                => 'blastn',
                    sequence               => $seq,
                    maxhits                => 100,
                    matrix                 => 'BLOSUM62',
                    evalue                 => 0.1,
                    mimosa_sequence_set_id => 42,
    ];
    is($response->code, 200, '/submit returns 200');
}

{
    local $TODO = "this no worky";
    my $f = sub {
        return request POST '/submit', [
                    program                => 'blastn',
                    sequence               => $seq,
                    maxhits                => 100,
                    matrix                 => 'BLOSUM62',
                    evalue                 => 0.1,
       ];
    };
    dies_ok sub { $f->() }, 'submitting without mimosa_sequence_set_id explodes';
}


