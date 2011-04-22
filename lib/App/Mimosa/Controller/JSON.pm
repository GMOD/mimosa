package App::Mimosa::Controller::JSON;
use Moose;
use Bio::Chado::Schema;

use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(default => 'application/json');

sub grid_json :Path("/api/grid/json.json") :ActionClass('REST') :Local { }

# Answer GET requests to the above Path
sub grid_json_GET {
    my ( $self, $c ) = @_;
    my $bcs = $c->model('BCS');

    # Mimosa resultsets
    my @sets   = $bcs->resultset('Mimosa::SequenceSet')->all;
    my $sso_rs = $bcs->resultset('Mimosa::SequenceSetOrganism');

    # Chado resultsets
    my $org_rs = $bcs->resultset('Organism');

    my $data = [ map {  my $rs = $sso_rs->search( { mimosa_sequence_set_id => $_->mimosa_sequence_set_id });
                        my $common_name = $rs->count ? $org_rs->find( { organism_id => $rs->single->organism_id })->common_name : 'NA';
                        +{
                            mimosa_sequence_set_id => $_->mimosa_sequence_set_id,
                            description            => $_->description,
                            common_name            => $common_name,
                        };
                      } @sets ];

    # Return a 200 OK, with the data in entity serialized in the body
    $self->status_ok( $c, entity => $data );
}


1;
