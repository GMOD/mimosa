use strict;
use warnings;

use Test::More;

use lib 't/lib';
use aliased 'App::Mimosa::Test::Mech';
use Test::DBIx::Class;

fixtures_ok('basic_ss');

my $mech = Mech->new;

$mech->get_ok('/');

$mech->submit_form_ok({
    form_name => 'main_input_form',
    fields => {
        sequence               => 'ATGCTAGTCGTCGATAGTCGTAGTAGCTGA',
        mimosa_sequence_set_id => 1,
        program                => "blastn",
      },
},
'submit single sequence with defaults',
);
diag($mech->content) if $mech->status != 200;

$mech->content_contains('No hits found') or diag $mech->content;

# now try a spammy submission
$mech->get_ok('/');
$mech->submit_form_ok({
    form_name => 'main_input_form',
    fields => {
        sequence               => '<a href="spammy.html">Spammy McSpammerson!</a>',
        mimosa_sequence_set_id => 1,
        program                => 'blastn',
    },
});
$mech->content_like( qr!No hits found!i )
  or diag $mech->content;

# now try a spammy submission
$mech->get_ok('/');
$mech->submit_form(
    form_name => 'main_input_form',
    fields => {
        sequence               => '',
        mimosa_sequence_set_id => 1,
    },
);
$mech->content_like( qr/error/i );
is $mech->status, 400, 'input error for empty sequence';

#try an submission that will be sure to get us an ungapped error
$mech->get_ok('/');
$mech->submit_form(
    form_name => 'main_input_form',
    fields => {
        filtered               => 'T',
        sequence               => 'A'x40,
        mimosa_sequence_set_id => 1,
        program                => "blastn",
    },
);
$mech->content_like( qr/error/i );
is $mech->status, 400, 'input error for ungapped stuff';

$mech->get_ok('/');
$mech->submit_form(
    form_name => 'main_input_form',
    fields => {
        filtered               => 'T',
        mimosa_sequence_set_id => 1,
        sequence               => 'ATGCTAGTCGTCGATAGTCGTAGTAGCTGA',
    },
);
$mech->content_like( qr/Error!/i);
is $mech->status, 400, 'input error if no program is selected';

{

    my $fasta = <<FASTA;
>foo
TCTGCGAGATGCAGAAACTAAAATAGTTCCAATTCCAATATCTCACAAAGCCACTACCCC
CCACCCCCACTCCCCCAAAAAAAAGGCTGCCACACTAAGATATAGTAAGGCTCAACCATC
TAATAAATAAAGAATGAAAATCATTACTGCCTGATTGAGAACTTATTTTGCTAAATAAAA
FASTA

sub test_blast_hits() {
    $mech->get_ok('/');
    $mech->submit_form_ok({
        form_name => 'main_input_form',
        fields => {
            mimosa_sequence_set_id => 1,
            filtered               => 'T',
            sequence               => $fasta,
            program                => "blastn",
        },
    });
    diag($mech->content) if $mech->status != 200;
    $mech->content_like( qr/Sbjct: /, 'got a blast hit');

    my @links = $mech->find_all_links( url_regex => qr!/api/! );
    $mech->links_ok( \@links, "All /api links work");

    for my $img ($mech->find_all_images()) {
        $mech->get_ok($img->url, $img->url . " works");
    }

}
    test_blast_hits();

    # We do this again to verify that already-generated
    # reports are cached and the user is redirected to them

    test_blast_hits();

}

done_testing;
