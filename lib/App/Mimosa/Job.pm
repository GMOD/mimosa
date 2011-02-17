package App::Mimosa::Job;
use Moose;
use Bio::SeqIO;
#use autodie qw/:all/;

# Good breakdown of commandline flags
# http://www.molbiol.ox.ac.uk/analysis_tools/BLAST/BLAST_blastall.shtml

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
    my $program = $self->program;
    my $input = $self->input_file;
    my $output = $self->output_file;
    my $cmd = <<CMD;
blastall -d $ENV{PWD}/t/data/solanum_peruvianum_mRNA.seq -e 0.01 -v 1 -p $program -i $input -o $output
CMD
    system($cmd);

}

1;
