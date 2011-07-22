package App::Mimosa::Auth::Schema::Result::UserRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("EncodedColumn");

=head1 NAME

App::Mimosa::Auth::Schema::Result::UserRole

=cut

__PACKAGE__->table("user_role");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 roleid

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "roleid",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 roleid

Type: belongs_to

Related object: L<App::Mimosa::Auth::Schema::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "roleid",
  "App::Mimosa::Auth::Schema::Result::Role",
  { id => "roleid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 user

Type: belongs_to

Related object: L<App::Mimosa::Auth::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "App::Mimosa::Auth::Schema::Result::User",
  { id => "user" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-07-22 11:39:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kxdXN+rA1nW1b9vBkkDcUQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
