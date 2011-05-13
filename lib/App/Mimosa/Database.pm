package App::Mimosa::Database;
use Moose;
use namespace::autoclean;
use Moose::Util::TypeConstraints;

use File::Spec::Functions;
use autodie ':all';

use Bio::BLAST::Database;

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

    $self->db( Bio::BLAST::Database->open(
        full_file_basename => $self->db_basename,
        type               => $self->alphabet,
        write              => 1,
        create_dirs        => 1,
    ));

    $self->db->format_from_file( seqfile => catfile($self->db_basename . '.seq') );
    return $self;
}

1;
