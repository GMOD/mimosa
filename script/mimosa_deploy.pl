use strict;
use warnings;
use Config::JFDI;
use Test::More;
use Data::Dumper;
use App::Mimosa::Schema::BCS;

my $config_file = Config::JFDI->new(file => shift || "app_mimosa.conf");
my $config = $config_file->get;

my $schema = App::Mimosa::Schema::BCS->connect( $config->{'Model::BCS'}{connect_info}->{dsn} );
diag "Deploying Mimosa Schema";
$schema->deploy;

diag "Populating default Mimosa Schema";
$schema->populate('Mimosa::SequenceSet', [
    [qw/shortname title description alphabet source_spec lookup_spec info_url update_interval is_public/],
    ['solanum_peruvianum_mrna', 'Solanum peruvianum SGN mRNA sequences', 'mRNA sequences for S. peruvianum', 'nucleotide', '', '', ,'', 30, 1    ],
]);
