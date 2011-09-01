use Test::Most tests => 65;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;
use aliased 'App::Mimosa::Test::Mech';
use Test::DBIx::Class;

use Catalyst::Test 'App::Mimosa';
use File::Slurp qw/slurp/;
use HTTP::Request::Common;
use File::Spec::Functions;
#use Carp::Always;
use Data::Dumper;

fixtures_ok 'basic_ss';

BEGIN {
    # This is the SHA1 of the composition of the FASTA for mimosa_sequence_set_id's 1 and 2
    # We unconditionally remove these so that we always test the creation of them
    unlink glob(catfile( app->config->{sequence_data_dir}, ".mimosa_cache_fbe21c6749e08ae8eef1b203a53fd385c52238a4*" ));

}

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
    like($response->content, qr!/api/report/raw/\d+!, 'got a download raw report link');
    like($response->content, qr!/api/report/html/\d+!, 'got a download html report link');
    like($response->content, qr!Database:.*fbe21c6749e08ae8eef1b203a53fd385c52238a4!, 'got the correct database file');
    like($response->content, qr!5 sequences; 2796 total letters!, 'got the correct number of sequences and letters');

    my $mech = Mech->new;
    # Now submit against the same sequence sets, but with a different sequence
    # Even if we do not get any hits, this shouldn't blow up
    $mech->post_ok( '/submit', {
                    program                => 'blastn',
                    sequence               => $seq . "A",
                    maxhits                => 100,
                    matrix                 => 'BLOSUM62',
                    evalue                 => 0.1,
                    mimosa_sequence_set_ids=> "1,2",
                    alphabet               => 'nucleotide',
                    alignment_view         => 8,
    }, '/submit returns 200 on the same sets with a different input sequence');
    my @links = $mech->find_all_links( url_regex => qr!/api/! );
    ok(@links,'found /api links');
    my ($report_link) = $mech->find_all_links( url_regex => qr!/api/report/html! );
    $mech->get_ok($report_link);

    my @report_links = $mech->find_all_links( url_regex => qr!/api/sequence/! );

    my $id;
    for my $link (@report_links) {
        $mech->get_ok($link);

        if ($link->url =~ m!/api/sequence/sha1/.*?/(.*?)\.fasta!) {
            $id = $1;
        }
        $mech->content_like(qr/$id/);
    }
}
