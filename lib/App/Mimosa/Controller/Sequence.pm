package App::Mimosa::Controller::Sequence;
use Moose;
use Bio::Chado::Schema;
use File::Spec::Functions;
use Bio::BLAST::Database;

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

    my $data = '';
    # Return a 200 OK, with the data in entity serialized in the body
    $self->status_ok( $c, entity => $data );
}

1;
