use strict;
use warnings;
use Config::JFDI;
use Test::More;
use Data::Dumper;
use Getopt::Long;
use App::Mimosa::Schema::BCS;

# default to app_mimosa.conf and not deploying to chado
my $conf  = '';
my $chado = 0;
my $result = GetOptions(
                "conf=s", \$conf,
                "chado=i", \$chado,
            );
my $config_file = Config::JFDI->new(file => $conf || "app_mimosa.conf");
my $config = $config_file->get;

my $schema = App::Mimosa::Schema::BCS->connect( $config->{'Model::BCS'}{connect_info}->{dsn} );


if ($chado) {
    diag "Deploying Mimosa Schema into a Chado schema";
    $schema->deploy({
             sources => [
                'Mimosa::Job',
                'Mimosa::SequenceSet',
                'Mimosa::SequenceSetOrganism',
                ]})
} else {
    diag "Deploying fresh Mimosa Schema";
    $schema->deploy;
}

my @seq_set_keys = qw/shortname title description alphabet source_spec lookup_spec info_url update_interval is_public/;

diag "Populating Mimosa Schema";
$schema->populate('Mimosa::SequenceSet', [
    [ @seq_set_keys ],
    [ map { $config->{'Schema::SequenceSet'}{$_} } (@seq_set_keys) ],
    # ['petunia', 'Petunia inflata', 'Petunia inflata scaffolds', 'nucleotide', '', '', ,'', 30, 1    ],
]);

my @sso_keys = qw/organism_id mimosa_sequence_set_id/;
$schema->populate('Mimosa::SequenceSetOrganism', [
    [ @sso_keys ],
    [ map { $config->{'Schema::SequenceSetOrganism'}{$_} } (@sso_keys) ],
    # [1, 1],
]);

my @organism_keys = qw/organism_id genus species common_name/;
$schema->populate('Organism', [
    [ @organism_keys ],
    [ map { $config->{'Schema::Organism'}{$_} } (@organism_keys) ],
    #[qw/organism_id genus species common_name/],
    #[1, "Petunia", "Petunia inflata", "Petunia"],
]);
