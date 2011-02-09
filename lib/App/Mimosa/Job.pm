package App::Mimosa::Job;
use Moose;
use Bio::Tools::Run::StandAloneBlast;
use Bio::SeqIO;
use autodie qw/:all/;

has aligner => (
    isa     => 'Bio::Tools::Run::StandAloneBlast',
    default => sub {
        Bio::Tools::Run::StandAloneBlast->new
    },
    is      => 'rw',
);

has program => (
    isa     => 'Str',
    is      => 'rw',
    default => 'blastall',
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
    my $seq = Bio::SeqIO->new(
        -file   => $self->input_file,
        -format => 'Fasta'
    );
    my $input_seq = $seq->next_seq();
    my $a = $self->aligner;

    $a->outfile($self->output_file);

    $a->blastall($input_seq);
}

1;
