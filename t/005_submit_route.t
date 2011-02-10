use Test::More tests => 2;
use strict;
use warnings;

# the order is important
use App::Mimosa;
use Dancer::Test;
use File::Slurp qw/slurp/;

route_exists [ POST => '/submit'], 'a route handler is defined for /submit';

my $response = dancer_response POST => '/submit', {
    params => {
        program        => 'blastp',
        sequence_input => slurp("t/data/blastdb_test.nucleotide.seq"),
    },
};
is $response->{status}, 200, "response for POST /submit is 200";
