package App::Mimosa::Aligner;
use Moose;

has program => (
    isa     => 'Str',
    default => 'blast',
);

has evalue => (
    isa     => 'Num',
    default => '1e-10',
);

has substitution_matrix => (
    isa     => 'Str',
    default => 'BLOSUM62',
);

has sequence_database => (
    isa     => 'Str',
);

1;
