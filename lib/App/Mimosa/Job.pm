package App::Mimosa::Job;
use Moose;
use Bio::Tools::Run::StandAloneBlast;
use Bio::SeqIO;
use autodie qw/:all/;

has aligner => (
    isa     => 'Bio::Tools::Run::StandAloneBlast',
    default => sub {
        my $self = shift;
        Bio::Tools::Run::StandAloneBlast->new(
            -database => 't/data/blastdb_test.protein',
            -expect   => 0.01,
            -verbose  => 1,
            -p        => $self->program(),
        )
    },
    is      => 'rw',
    lazy    => 1,
);

has program => (
    isa     => 'Str',
    is      => 'rw',
    default => 'blastn',
);

has input_file => (
    isa => 'Str',
    is  => 'rw',
);

has output_file => (
    isa => 'Str',
    is  => 'rw',
);


sub run {
    my ($self) = @_;
    my $a = $self->aligner;

    $a->outfile($self->output_file);

    $a->blastall($self->input_file);
}

1;
