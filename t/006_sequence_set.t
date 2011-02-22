use Test::More tests => 2;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;

# the order is important
use App::Mimosa;
use Dancer::Test;
use File::Slurp qw/slurp/;

route_exists [ GET => '/sequence_set'], 'a route handler is defined for /sequence_set';
route_exists [ GET => '/sequence_set/add'], 'a route handler is defined for /sequence_set/add';
route_exists [ GET => '/sequence_set/edit'], 'a route handler is defined for /sequence_set/edit';
