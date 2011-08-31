use Test::Most tests => 19;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;
use HTTP::Request::Common;
use File::Spec::Functions;
use File::Slurp qw/slurp/;
use Test::JSON;

fixtures_ok 'basic_ss';

# we need to generate a report first, so our db gets indexed

my $seq = slurp(catfile(qw/t data blastdb_test.nucleotide.seq/));
my $response = request POST '/submit', [
                program                => 'blastn',
                sequence_input_file    => '',
                sequence               => $seq,
                maxhits                => 100,
                matrix                 => 'BLOSUM62',
                evalue                 => 0.1,
                mimosa_sequence_set_ids=> 1,
                alphabet               => 'nucleotide',
];


sub basic_test {
    my $url = shift;
    my $seq = 'AATTATTTTATTTGGTTTATTGTAGTCCTTAAGACAGTTAGGATACCTGAGTTATGTATC';

    my $r = request $url;
    is($r->code, 200, "200 GET $url" );
    ok($r->content !~ m/Bio::BLAST::Database::Seq/);
    like($r->content, qr/^>LE_HBa0001A15_T7_30 Chromat_file:Le-HBa001_A15-T7\.ab1 SGN_GSS_ID:30 \(vector and quality trimmed\)/, 'got the correct desc line back');
    like($r->content, qr/$seq/, 'looks like the same FASTA');

    is(length($r->content),596, 'got non-zero content length') or diag $r->content;
}
{
    basic_test('/api/sequence/id/1/LE_HBa0001A15_T7_30.txt');
    basic_test('/api/sequence/id/1/LE_HBa0001A15_T7_30.fasta');
    basic_test('/api/sequence/id/1/LE_HBa0001A15_T7_30');

    # TODO
    # basic_test('/api/sequence/1/LE_HBa0001A15_T7_30.json');
}

{
    my $r = request '/api/sequence/id/99/blarg.txt';
    is($r->code, 400, 'asking for the sequence of a non-existent mimosa_sequence_set_id borks' );
}

{

    # make sure the composite seq set exists
    my $response = request POST '/submit', [
                    program                => 'blastn',
                    sequence_input_file    => '',
                    sequence               => $seq,
                    maxhits                => 100,
                    matrix                 => 'BLOSUM62',
                    evalue                 => 0.1,
                    mimosa_sequence_set_ids=> "1,2",
                    alphabet               => 'nucleotide',
    ];

    # the sha1 of the composite seq set of mimosa_sequence_set's 1 and 2
    my $sha1 = "fbe21c6749e08ae8eef1b203a53fd385c52238a4";

    # the following sequence is in the blastdb_test.nucleotide.seq file
    my $r = request "/api/sequence/sha1/$sha1/LE_HBa0001A17_SP6_33.txt";
    is($r->code, 200, 'asking for a sequence from a composite seq set works');
    my $content = $r->content;
    my $expected_seq =<<SEQ;
>LE_HBa0001A17_SP6_33 Chromat_file:Le-HBa001_A17-SP6.ab1 SGN_GSS_ID:33 (vector and quality trimmed)
TCTGCGAGATGCAGAAACTAAAATAGTTCCAATTCCAATATCTCACAAAGCCACTACCCCCCACCCCCACTCCCCCAAAA
AAAAGGCTGCCACACTAAGATATAGTAAGGCTCAACCATCTAATAAATAAAGAATGAAAATCATTACTGCCTGATTGAGA
ACTTATTTTGCTAAATAAAAGAGTGGTTTAAATTTGGGAAATTTTGGGTGATCATTGGCTTCTAAGAATGACAGAGAGGG
GCAACTATGTCAAAAACTCTCTGAATCCAGTAGACTTAGACTTAAACAAATGAGATTTTTTCCATTTTCATTTCACCTTC
TGCTTCATATTTATAGTGCCTAAATTGTTTTGGACCTCAACAATGGTTCACTCAACTGATGGGGTTAACAAACTGGGGCA
CTGAAGACAATACAACCCGTATCTTGGCCAGGCAAATCCCAAGATGACCTGCAATGGAGGCTCTCTTTTTTGCATGCAAC
CAGTGATCTTACAGCCATGGCGTGGTTGCCTTCTCCTTTGTGAGCTGAGGGTCAATCGGAAACAGCTTATCTACCCCAAA
AAGGTAAAGTAAGGTCCACCTACACTCCACCCGCCCCATACCCCGCTTTTGGGATTACACTAGGTTGTTGTTGTTGTATA
ATCTCTTTTGACCTCCCAAAATTAAGGGCCTCATGTCGAAGATCTTATATGT
SEQ
    is($content, $expected_seq, 'got the expected seq for LE_HBa0001A17_SP6_33');

}
