use strict;
use warnings;
use YAML qw/LoadFile/;
use Bio::Chado::Schema;
use Test::More;

my $config = shift;
die "need configuration file" unless $config;

my $dancer_conf = LoadFile($config);

my $conf = $dancer_conf->{plugins}->{DBIC}->{mimosa};
my $schema = Bio::Chado::Schema->connect( $conf->{dsn} );
diag "Deploying Mimosa Schema";
$schema->deploy;

diag "Populating default Mimosa Schema";
$schema->populate('Mimosa::SequenceSet', [
    [qw/shortname title description alphabet source_spec lookup_spec info_url update_interval is_public/],
    ['solanum_peruvianum_mrna', 'Solanum peruvianum SGN mRNA sequences', 'mRNA sequences for S. peruvianum', 'nucleotide', '', '', ,'', 30, 1    ],
]);
