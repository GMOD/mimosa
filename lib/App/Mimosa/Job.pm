package App::Mimosa::Job;
use Moose;
use Bio::SeqIO;
use Moose::Util::TypeConstraints;
use Try::Tiny;
use File::Slurp qw/slurp/;
use File::Temp qw/tempfile/;

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
    isa     => 'SubstitutionMatrix',
    is      => 'rw',
    default => 'BLOSUM62',
);

enum 'BoolStr' => qw(T F);

has filtered => (
    isa     => 'BoolStr',
    is      => 'rw',
    default => 'T',
);


sub run {
    my ($self) = @_;
    my $program  = $self->program;
    my $input    = $self->input_file;
    my $output   = $self->output_file;
    my $evalue   = $self->evalue;
    my $maxhits  = $self->maxhits;
    my $matrix   = $self->matrix;
    my $filtered = $self->filtered;

    my ($run_fh, $run_file) = tempfile( CLEANUP => 0 );

    my $cmd = <<CMD;
blastall -d $ENV{PWD}/t/data/solanum_peruvianum_mRNA.seq -M $matrix -b $maxhits -e $evalue -v 1 -p $program -F $filtered -i $input -o $output &> $run_file
CMD
    # warning("running $cmd");
    try {
        system($cmd);
    } catch {
        return join "", slurp($run_file);
    };

}

1;
