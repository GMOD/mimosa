package App::Mimosa::Controller::Sequence;
use Moose;
use Bio::Chado::Schema;
use File::Spec::Functions;
use App::Mimosa::Database;
use JSON::Any;

use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

sub sequence :Path("/api/sequence/") :Args(2) {
    my ( $self, $c, $mimosa_sequence_set_id, $name ) = @_;
    my $bcs = $c->model('BCS');

    $name =~ s/\.txt$//g;

    # Mimosa resultsets
    my $rs   = $bcs->resultset('Mimosa::SequenceSet')->find( { mimosa_sequence_set_id => $mimosa_sequence_set_id } );
    unless ($rs) {
        $c->stash->{error} = 'Sorry, that sequence set id is invalid';
        $c->detach('/input_error');
    }
    use Cwd;
    my $cwd = getcwd;

    my $seq_data_dir = $c->config->{sequence_data_dir};
    my $dbname       = catfile($cwd, $seq_data_dir, $rs->shortname);
    warn "dbname=$dbname";

    my $db = App::Mimosa::Database->new(
        db_basename => $dbname,
        alphabet    => $rs->alphabet,
    );

    my $data = $db->get_sequence($name);
    warn "Data= $data";
    # Return a 200 OK, with the data in entity serialized in the body
    $self->status_ok( $c, entity => $data );
}

1;
