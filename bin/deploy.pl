use strict;
use warnings;
use YAML qw/LoadFile/;
use Bio::Chado::Schema;

my $config = shift;
die "need configuration file" unless $config;

my $dancer_conf = LoadFile($config);

my $conf = $dancer_conf->{plugins}->{DBIC}->{mimosa};
my $schema = Bio::Chado::Schema->connect( $conf->{dsn} );
$schema->deploy;
print "done!\n";
