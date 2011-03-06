package App::Mimosa::Schema::BCS;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
use Bio::Chado::Schema;

extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


__PACKAGE__->meta->make_immutable;
1;
