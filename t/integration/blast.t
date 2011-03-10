use strict;
use warnings;

use Test::More;

use aliased 'Test::WWW::Mechanize::Catalyst' => 'Mech';

my $mech = Mech->new( catalyst_app => 'App::Mimosa' );

$mech->get_ok('/');

$mech->submit_form_ok({
    form_name => 'main_input_form',
    fields => {
        sequence => 'ATGCTAGTCGTCGATAGTCGTAGTAGCTGA',
      },
},
'submit single sequence with defaults',
);

$mech->content_contains('Report');
$mech->content_contains('Altschul');

done_testing;
