package App::Mimosa::Job;
use Moose;
use Bio::SeqIO;
use autodie qw/:all/;
use Moose::Util::TypeConstraints;

# Good breakdown of commandline flags
# http://www.molbiol.ox.ac.uk/analysis_tools/BLAST/BLAST_blastall.shtml
subtype 'Program'
             => as Str
             => where {
                    /^blast(n|p|all)$/;
                };
subtype 'SubstitutionMatrix'
             => as Str
             => where {
                    /^(BLOSUM|PAM)\d\d$/;
                };

# validate!
has program => (
    isa     => 'Program',
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

has evalue => (
    isa => 'Num',
    is  => 'rw',
    default => 0.01,
);

has maxhits => (
    isa => 'Int',
    is  => 'rw',
    default => 100,
);

has matrix => (
    isa => 'SubstitutionMatrix',
    is  => 'rw',
    default => 'BLOSUM62',
);

sub run {
    my ($self) = @_;
    my $program = $self->program;
    my $input   = $self->input_file;
    my $output  = $self->output_file;
    my $evalue  = $self->evalue;
    my $maxhits = $self->maxhits;
    my $matrix  = $self->matrix;


    my $cmd = <<CMD;
blastall -d $ENV{PWD}/t/data/solanum_peruvianum_mRNA.seq -M $matrix -b $maxhits -e $evalue -v 1 -p $program -i $input -o $output
CMD
    warn "running $cmd";
    system($cmd);

}

1;
