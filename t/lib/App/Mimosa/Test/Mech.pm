package App::Mimosa::Test::Mech;
use Moose;

use App::Mimosa::Test ();
use Test::DBIx::Class;

extends 'Test::WWW::Mechanize::Catalyst';

has '+catalyst_app' => default => 'App::Mimosa';

1;

