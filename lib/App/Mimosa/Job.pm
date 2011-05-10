package App::Mimosa::Job;
use Moose;
use namespace::autoclean;
use autodie ':all';

use Bio::SeqIO;
use Moose::Util::TypeConstraints;
use Bio::BLAST::Database;
use File::Spec::Functions;

use File::Slurp qw/slurp/;
use File::Temp qw/tempfile/;

use IPC::Run;

# Good breakdown of commandline flags
# http://www.molbiol.ox.ac.uk/analysis_tools/BLAST/BLAST_blastall.shtml
subtype 'Program'
             => as Str
             => where {
                    /^(blastn|tblastx|tblastn)$/;
                };
subtype 'SubstitutionMatrix'
             => as Str
             => where {
                    /^(BLOSUM|PAM)\d\d$/;
                };

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

enum 'Alphabet' => qw(protein nucleotide);

has alphabet => (
    isa     => 'Alphabet',
    is      => 'rw',
    required => 1,
);

has filtered => (
    isa     => 'BoolStr',
    is      => 'rw',
    default => 'T',
);

has db_basename => (
    isa     => 'Str',
    is      => 'rw',
    required => 1,
);

has config => (
    is      => 'rw',
);

has job_id => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
);

sub run {
    my ($self) = @_;

    my $db = Bio::BLAST::Database->open(
        full_file_basename => $self->db_basename,
        type               => $self->alphabet,
        write              => 1,
        create_dirs        => 1,
    );

    $db->format_from_file( seqfile => catfile($self->db_basename . '.seq') );

    # Consult our configuration to see if qsub should be used

    if( $self->config->{disable_qsub} ) {
        my @blast_cmd = (
            'blastall',
            -v => 1,
            -d => $self->db_basename,
            -M => $self->matrix,
            -b => $self->maxhits,
            -e => $self->evalue,
            -p => $self->program,
            -F => $self->filtered,
            -i => $self->input_file,
            -o => $self->output_file,
        );

        my $console_output = File::Temp->new;
        my $success = IPC::Run::run \@blast_cmd, \*STDIN, $console_output, $console_output;
        $console_output->close;
        unless( $success ) {
            return $self->_error_output( $console_output );
        }
        return;
    } else { # invoke qsub, if it was detected

    }
}

sub _error_output {
    my ( $self, $tempfile ) = @_;
    my $max_lines    = 50;
    my $error_output = '';
    open my $f, "$tempfile";
    while( $max_lines-- and my $line = <$f> ) {
        $error_output .= $line;
    }
    return $error_output;
}

1;
