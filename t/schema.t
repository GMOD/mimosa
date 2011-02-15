use strict;
use warnings;

use Test::More;

use Bio::Chado::Schema;

my $schema = Bio::Chado::Schema->connect( "dbi:SQLite::memory:");

isa_ok $schema, 'DBIx::Class::Schema', 'schema object';

$schema->deploy;
ok 1, 'deploy did not die';

isa_ok $schema->resultset('Mimosa::SequenceSet'), 'DBIx::Class::ResultSet', 'we have a Mimosa::SequenceSet resultset';

is $schema->resultset('Mimosa::SequenceSet')->count, 0,
   'no rows in the sequenceset table right now';

is $schema->resultset('Mimosa::SequenceSet')->search_related('sequence_set_organisms')->count, 0,
   'SequenceSet has sequence_set_organisms rel';

is $schema->resultset('Mimosa::SequenceSetOrganism')->count, 0,
   'no rows in the sequenceset_organism table right now';

is $schema->resultset('Organism::Organism')->search_related('mimosa_sequence_sets')->count, 0,
   'organism has mimosa_sequence_sets rel';

done_testing;
