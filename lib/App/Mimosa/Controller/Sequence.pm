package App::Mimosa::Controller::Sequence;
use Moose;
use Bio::Chado::Schema;
use File::Spec::Functions;
use App::Mimosa::Database;
use JSON::Any;

use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' };

sub sequence :Path("/api/sequence/") :Args(2) {
    my ( $self, $c, $mimosa_sequence_set_id, $name ) = @_;
    my $bcs = $c->model('BCS');

    my $return_json = ( $name =~ m/\.json$/ );

    $name =~ s/\.txt$//g;
    $name =~ s/\.fasta$//g;

    # Mimosa resultsets
    my $rs   = $bcs->resultset('Mimosa::SequenceSet')->find( { mimosa_sequence_set_id => $mimosa_sequence_set_id } );
    unless ($rs) {
        $c->stash->{error} = 'Sorry, that sequence set id is invalid';
        $c->detach('/input_error');
    }

    my $seq_data_dir = $c->config->{sequence_data_dir};
    my $mimosa_root  = $c->config->{mimosa_root};
    my $dbname       = catfile($mimosa_root, $seq_data_dir, $rs->shortname);
    #warn "dbname=$dbname, alphabet=" . $rs->alphabet;

    my $db = App::Mimosa::Database->new(
        db_basename => $dbname,
        alphabet    => $rs->alphabet,
        write       => 1,
    );

    my $seq   = $db->get_sequence($name);

    $c->stash->{sequences} = [ $seq ];
    $c->forward( 'View::SeqIO' );

}

1;
