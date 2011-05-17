use strict;
use warnings;
use Test::Most tests => 9;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;

use File::Slurp qw/slurp/;
use HTTP::Request::Common;
use File::Spec::Functions;
#use Carp::Always;

fixtures_ok 'basic_ss';

my $seq = slurp(catfile(qw/t data blastdb_test.nucleotide.seq/));
{
    my $response = request POST '/submit', [
                    program                => 'blastn',
                    sequence               => $seq,
                    maxhits                => 100,
                    matrix                 => 'BLOSUM62',
                    evalue                 => 0.1,
                    mimosa_sequence_set_ids=> 1,
                    alphabet               => 'nucleotide',
    ];
    is($response->code, 200, '/submit returns 200');
    like($response->content,qr!Download Raw Report.*/api/report/raw/\d+!, 'download raw report link');
}
{
    my $response = request POST '/submit', [
                    program                => 'blastn',
                    sequence               => "small",
                    maxhits                => 100,
                    matrix                 => 'BLOSUM62',
                    evalue                 => 0.1,
                    mimosa_sequence_set_ids => 42,
                    alphabet               => 'nucleotide',
    ];
    is($response->code, 400, "/submit with too small input sequence returns 400");
    like($response->content,qr/Sequence input too short\. Must have a length of at least 6/, "error explains the min length");
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
    is($res->code, 400, '/submit returns 400 without a mimosa_sequence_set_ids');
}

{
    my $seq = <<SEQ;
>foo
ATATATATATAT
SEQ
    my $f = sub {
        return request POST '/submit', [
                    program                => 'blastn',
                    sequence               => $seq,
                    maxhits                => 100,
                    alphabet               => 'nucleotide',
                    matrix                 => 'BLOSUM62',
                    evalue                 => 0.1,
                    mimosa_sequence_set_ids => 1,
       ];
    };
    my $res = $f->();
    is($res->code,400,'/submit gives an ungapped error');
    like($res->content,qr/Could not calculate ungapped Karlin-Altschul parameters/);
    ok($res->content !~ qr/catalyst_detach/, "We don't get the error Invalid input: catalyst_detach");
}

