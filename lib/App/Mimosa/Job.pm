package App::Mimosa::Job;
use Moose;
use Bio::Tools::Run::StandAloneBlast;
use Bio::SeqIO;
use autodie qw/:all/;

has blaster => (
    isa => 'Bio::Tools::Run::StandAloneBlast',
    default => sub {
        Bio::Tools::Run::StandAloneBlast->new
    },
);

has program => (
    isa => 'Str',
);



sub run {
    my ($self) = @_;
    my $seq = Bio::SeqIO->new(
        -file   => 't/amino.fa',
        -format => 'Fasta'
    );
    my $input_seq = $seq->next_seq();
    $self->blaster()->blastall($input_seq);
}


1;
