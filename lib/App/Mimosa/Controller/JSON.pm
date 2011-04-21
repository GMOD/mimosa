package App::Mimosa::Controller::JSON;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(default => 'application/json');

sub grid_json :Path("/api/grid/json.json") :ActionClass('REST') :Local { }

# Answer GET requests to "thing"
sub grid_json_GET {
    my ( $self, $c ) = @_;

    my @sets = $c->model('BCS')->resultset('Mimosa::SequenceSet')->all;

    my $data = [ map { +{
                            mimosa_sequence_set_id => $_->mimosa_sequence_set_id,
                            description            => $_->description,
                            organism_name          => 'fixme',
                        }
                      } @sets ];

    # Return a 200 OK, with the data in entity serialized in the body
    $self->status_ok( $c, entity => $data );
}


1;
