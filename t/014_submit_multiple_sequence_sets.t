use Test::Most tests => 5;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;

use Catalyst::Test 'App::Mimosa';
use File::Slurp qw/slurp/;
use HTTP::Request::Common;
use File::Spec::Functions;
#use Carp::Always;
use Data::Dumper;

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
    like($response->content, qr!Download Raw Report.*/api/report/raw/\d+!, 'got a download raw report link');
    like($response->content, qr!Database:.*ebe9f24f7c4bd899d31a058a703045ed4d9678c8-blast-db-new!, 'got the correct database file');
    like($response->content, qr!5 sequences; 2,796 total letters!, 'got the correct number of sequences and letters');

}
