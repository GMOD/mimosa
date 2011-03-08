use strict;
use warnings;
use Config::JFDI;
use Bio::Chado::Schema;
use Test::More;
use Data::Dumper;

my $config_file = Config::JFDI->new(file => shift || "app_mimosa.conf");
my $config = $config_file->get;

my $schema = Bio::Chado::Schema->connect( $config->{'Model::BCS'}{connect_info}->{dsn} );
diag "Deploying Mimosa Schema";
$schema->deploy;

diag "Populating default Mimosa Schema";
$schema->populate('Mimosa::SequenceSet', [
    [qw/shortname title description alphabet source_spec lookup_spec info_url update_interval is_public/],
    ['solanum_peruvianum_mrna', 'Solanum peruvianum SGN mRNA sequences', 'mRNA sequences for S. peruvianum', 'nucleotide', '', '', ,'', 30, 1    ],
]);
