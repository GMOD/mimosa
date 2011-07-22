package App::Mimosa::Auth::Schema::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("EncodedColumn");

=head1 NAME

App::Mimosa::Auth::Schema::Result::Role

=cut

__PACKAGE__->table("role");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 role

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "role",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("role_unique", ["role"]);

=head1 RELATIONS

=head2 user_roles

Type: has_many

Related object: L<App::Mimosa::Auth::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "App::Mimosa::Auth::Schema::Result::UserRole",
  { "foreign.roleid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-07-22 11:39:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qBcVjGHIVTQaMXMc7O17bw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
