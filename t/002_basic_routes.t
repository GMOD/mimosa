use Test::More tests => 6;
use strict;
use warnings;

# the order is important
use App::Mimosa;
use Dancer::Test;

use lib 't/lib';
use App::Mimosa::Test;

route_exists [GET => '/'], 'a route handler is defined for /';
response_status_is ['GET' => '/'], 200, 'response status is 200 for /';

route_exists [GET => '/jobs'], 'a route handler is defined for /jobs';
response_status_is ['GET' => '/jobs'], 200, 'response status is 200 for /jobs';

route_exists [GET => '/results'], 'a route handler is defined for /jobs';
response_status_is ['GET' => '/results'], 200, 'response status is 200 for /jobs';
