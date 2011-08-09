use Test::Most tests => 8;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;

use Catalyst::Test 'App::Mimosa';
use File::Slurp qw/slurp/;
use HTTP::Request::Common;
use File::Spec::Functions;
use Test::DBIx::Class;

fixtures_ok 'basic_job';
fixtures_ok 'basic_ss';

{
    my $response = request GET '/api/report/raw/42', [
    ];
    is($response->code, 400, 'Downloading the raw report of an invalid Job id should fail');
    like($response->content,qr/does not exist/);
}

{
    my $response = request GET '/api/report/html/42', [
    ];
    is($response->code, 400, 'Downloading the html report of an invalid Job id should fail');
    like($response->content,qr/does not exist/);
}


{
    # make sure there is at least one report
    generate_report();

    my $response = request GET '/api/report/html/1';
    is($response->code, 200, 'get an html report');
    like($response->content,qr/Altschul, Stephen F/);

}

sub generate_report {
    my ($view) = @_;
    $view ||= 0;
    my $seq = slurp(catfile(qw/t data blastdb_test.nucleotide.seq/));
    my $response = request POST '/submit', [
                    alignment_view		   => $view,
                    program                => 'blastn',
                    sequence               => $seq,
                    maxhits                => 100,
                    matrix                 => 'BLOSUM62',
                    evalue                 => 0.1,
                    mimosa_sequence_set_ids=> 1,
                    alphabet               => 'nucleotide',
    ];
}
