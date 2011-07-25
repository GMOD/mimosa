package App::Mimosa::Controller::Sequence;
use Moose;
use Bio::Chado::Schema;
use File::Spec::Functions;
use App::Mimosa::Database;

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

sub sequence :Path("/api/sequence/") :Args(2) :ActionClass('REST') :Local { }

# Answer GET requests to the above Path
sub sequence_GET {
    my ( $self, $c, $mimosa_sequence_set_id, $name ) = @_;
    my $bcs = $c->model('BCS');

    # Mimosa resultsets
    my $rs   = $bcs->resultset('Mimosa::SequenceSet')->find( { mimosa_sequence_set_id => $mimosa_sequence_set_id } );
    unless ($rs) {
        $c->stash->{error} = 'Sorry, that sequence set id is invalid';
        $c->detach('/input_error');
    }

    my $seq_data_dir = $c->config->{sequence_data_dir};
    my $dbname       = catfile($seq_data_dir, $rs->shortname);

    my $db = App::Mimosa::Database->new(
        db_basename => $dbname,
        alphabet    => $rs->alphabet,
    );

    # this will only index if indices don't already exist
    $db->index;

    my $data = $db->db->get_sequence($name);
    # Return a 200 OK, with the data in entity serialized in the body
    $self->status_ok( $c, entity => $data );
}

1;
