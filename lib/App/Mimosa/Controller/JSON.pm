package App::Mimosa::Controller::JSON;
use Moose;
use Bio::Chado::Schema;

use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    'map' => {
        # Work around an ExtJS bug that sends the wrong content-type
        'text/html'        => 'JSON',
    }

);

sub grid_json :Path("/api/grid/json.json") :ActionClass('REST') :Local { }

# Answer GET requests to the above Path
sub grid_json_GET {
    my ( $self, $c ) = @_;

    my $data = _grid_json_data($c);
    # Return a 200 OK, with the data in entity serialized in the body
    $self->status_ok( $c, entity => $data );
}

sub autodetect :Private {
    my ($self, $c) = @_;
    my $config    = $self->_app->config;
    my $seq_dir   = $config->{sequence_data_dir};
    my @seq_files = glob($seq_dir. '/*');

    for my $f (@seq_files) {
    }
}

sub _grid_json_data {
    my ($c) = @_;

    $c->forward('autodetect');

    my $bcs = $c->model('BCS');

    # Mimosa resultsets
    my @sets   = $bcs->resultset('Mimosa::SequenceSet')->all;
    my $sso_rs = $bcs->resultset('Mimosa::SequenceSetOrganism');

    # Chado resultsets
    my $org_rs = $bcs->resultset('Organism');
    my ($common_name, $binomial, $name);

    return { total => $#sets, rows => [ map {  my $rs = $sso_rs->search( { mimosa_sequence_set_id => $_->mimosa_sequence_set_id });
                        if ($rs->count) {
                            my $org      = $org_rs->find( { organism_id => $rs->single->organism_id });
                            $common_name = $org->common_name;
                            $binomial    = $org->species;
                            $name        = $binomial;
                            $name       .= " ($common_name)" if $common_name;
                        } else {
                            $name = 'NA';
                        }

                        +{
                            mimosa_sequence_set_id => $_->mimosa_sequence_set_id,
                            description            => $_->description,
                            name                   => $name,
                            alphabet               => $_->alphabet,
                        };
    } @sets ] };

}

1;
