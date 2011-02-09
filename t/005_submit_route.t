use Test::More tests => 2;
use strict;
use warnings;

# the order is important
use App::Mimosa;
use Dancer::Test;

route_exists [ POST => '/submit'], 'a route handler is defined for /submit';

my $response = dancer_response POST => '/submit', { params => { program => 'blastp'} };
is $response->{status}, 200, "response for POST /widgets is 200";
is $response->{content}, "stuff";
