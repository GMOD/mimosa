use Test::Most tests => 7;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;
use Test::JSON;

fixtures_ok 'basic_ss';

{
    my $seq = 'AATTATTTTATTTGGTTTATTGTAGTCCTTAAGACAGTTAGGATACCTGAGTTATGTATC';

    my $r = request '/api/sequence/1/LE_HBa0001A15_T7_30.txt';
    is($r->code, 200 );
    ok($r->content !~ m/Bio::BLAST::Database::Seq/);
    like($r->content, qr/^>LE_HBa0001A15_T7_30 Chromat_file:Le-HBa001_A15-T7\.ab1 SGN_GSS_ID:30 \(vector and quality trimmed\)/, 'got the correct desc line back');
    like($r->content, qr/$seq/, 'looks like the same FASTA');

    is(length($r->content),596, 'got non-zero content length') or diag $r->content;
}

{
    my $r = request '/api/sequence/99/blarg.txt';
    is($r->code, 400, 'asking for the sequence of a non-existent mimosa_sequence_set_id borks' );
}

