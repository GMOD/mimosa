use strict;
use warnings;

use Test::More;

use Bio::Chado::Schema;

my $test_db_file = 't/var/schema.t.db';
unlink $test_db_file;
my $schema = Bio::Chado::Schema->connect( "dbi:SQLite:dbname=$test_db_file" );

isa_ok $schema, 'DBIx::Class::Schema', 'schema object';

$schema->deploy;
ok 1, 'deploy did not die';

isa_ok $schema->resultset('Mimosa::SequenceSet'), 'DBIx::Class::ResultSet', 'we have a Mimosa::SequenceSet resultset';

is $schema->resultset('Mimosa::SequenceSet')->count, 0, 'no rows in the sequenceset table right now';

done_testing;
