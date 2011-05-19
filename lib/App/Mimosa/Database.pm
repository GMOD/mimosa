package App::Mimosa::Database;
use Moose;
use namespace::autoclean;
use Moose::Util::TypeConstraints;
use Cwd;

use File::Spec::Functions;
use File::Basename;
use autodie ':all';

use Bio::BLAST::Database;
#use Carp::Always;

# TODO: store this in a shared place, because App::Mimosa::Job has it too
enum 'Alphabet' => qw(protein nucleotide);

has alphabet => (
    isa     => 'Alphabet',
    is      => 'rw',
    required => 1,
);

has db_basename => (
    isa     => 'Str',
    is      => 'rw',
    required => 1,
);

has db => (
    isa => 'Bio::BLAST::Database',
    is  => 'rw',
);

sub index {
    my ($self, %opts) = @_;
    my $dir = dirname($self->db_basename);
    my $cwd = getcwd;
    chdir $dir;

    my $basename = $self->db_basename;
    my $alphabet = $self->alphabet;
    my $db = Bio::BLAST::Database->open(
        # force stringification to avoid arcane broken magic at a distance
        full_file_basename => "$basename",
        type               => "$alphabet",
        write              => 1,
        create_dirs        => 1,
    );
    $self->db($db);

    my $seqfile = catfile($self->db_basename . '.seq');
    $self->db->format_from_file( seqfile =>  $seqfile );

    chdir $cwd;
    return $self;
}

1;
