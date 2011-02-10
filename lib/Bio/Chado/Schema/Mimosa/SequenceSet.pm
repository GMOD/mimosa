package Bio::Chado::Schema::Mimosa::SequenceSet;
use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Bio::Chado::Schema::Mimosa::SequenceSet - a set of sequences (like a
BLAST database)

=cut

__PACKAGE__->table("mimosa_sequence_set");

__PACKAGE__->add_columns(

  # surrogate key
  "mimosa_sequence_set_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "mimosa_sequence_set_mimosa_sequence_set_id_seq",
  },

  # unique short name for referring to this set
  'shortname',
  { data_type => "varchar", is_nullable => 0, size => 255 },

  # user-visible title of the sequence set
  'title',
  { data_type => "varchar", is_nullable => 0, size => 255 },

  # text description of the set, in markdown format
  'description',
  { data_type => "text", is_nullable => 1 },

  # type, either 'protein' or 'nucleotide'
  'alphabet',
  { data_type => "varchar", is_nullable => 0, size => 20 },

  # specially-formatted text representing how to fetch new
  # copies of this sequence set
  'source_spec',
  { data_type => "text", is_nullable => 1 },

   # specially-formatted text representing how to
  # cross-reference identifiers in this database with
  # other databases
  'lookup_spec',
  { data_type => "text", is_nullable => 1 },

  # URL that gives more information about this sequence set
  'info_url',
  { data_type => "varchar", is_nullable => 0, size => 255 },

  # desired interval (either in seconds, or 'monthly', 'weekly', or
  # 'daily') between updates of this blast database.  a null value
  # means no automatic updating.
  'update_interval',
  { data_type => "integer", is_nullable => 1 },

  # whether this sequence set should be visible to everyone
  'is_public',
  { data_type => "boolean", is_nullable => 0 },

);

__PACKAGE__->set_primary_key("mimosa_sequence_set_id");
__PACKAGE__->add_unique_constraint("mimosa_sequence_set_c1", ['shortname'] );

1;
