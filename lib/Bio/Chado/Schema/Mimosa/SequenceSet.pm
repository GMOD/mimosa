package Bio::Chado::Schema::Mimosa::SequenceSet;
use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Bio::Chado::Schema::Mimosa::SequenceSet - a set of sequences (like a
BLAST database)

=head1 COLUMNS

=cut

__PACKAGE__->table("mimosa_sequence_set");

=head2 mimosa_sequence_set_id

Auto-incrementing surrogate primary key.

=head2 shortname

B<Unique> short name for referring to this set.  For example,
C<ITAG2.2_cdnas>.

Not null, varchar(255).

=head2 title

User-visible title of the sequence set.

Not null.  Varchar(255).

=head2 description

Text description of the set, probably stored in Markdown or some
similar format.

Nullable.

=head2 alphabet

Sequence type, either 'protein' or 'nucleotide'.

Not null. Varchar(20).

=head2 source_spec

Specially-formatted text representing how to fetch new
copies of this sequence set.

This text will be interpreted by software for fetching new copies of
sequence sets.

Nullable.  Unlimited length.

=head2 lookup_spec

Specially-formatted text representing how to cross-reference
identifiers in this database with other databases.

Nullable.  Unlimited length.

=head2 info_url

URL pointing to a human-readable resource giving more information
about this sequence set.

Nullable.  Varchar(255).

=head2 update_interval

Desired interval (either in seconds, or 'monthly', 'weekly', or
'daily') between updates of this blast database.  a null value
means no automatic updating.

Nullable.  Varchar(30).

=head2 is_public

Whether this sequence set should be visible to all users.

Not nullable.  Default false.

=cut

__PACKAGE__->add_columns(

  "mimosa_sequence_set_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "mimosa_sequence_set_mimosa_sequence_set_id_seq",
  },

  'shortname',
  { data_type => "varchar", is_nullable => 0, size => 255 },

  'title',
  { data_type => "varchar", is_nullable => 0, size => 255 },

  'description',
  { data_type => "text", is_nullable => 1 },

  'alphabet',
  { data_type => "varchar", is_nullable => 0, size => 20 },

  'source_spec',
  { data_type => "text", is_nullable => 1 },

  'lookup_spec',
  { data_type => "text", is_nullable => 1 },

  'info_url',
  { data_type => "varchar", is_nullable => 0, size => 255 },

  'update_interval',
  { data_type => "varchar", is_nullable => 1, size => 30 },

  'is_public',
  { data_type => "boolean", is_nullable => 0, default_value => 0 },

);

__PACKAGE__->set_primary_key("mimosa_sequence_set_id");
__PACKAGE__->add_unique_constraint("mimosa_sequence_set_c1", ['shortname'] );

1;
