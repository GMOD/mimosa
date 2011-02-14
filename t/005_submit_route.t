use Test::More tests => 2;
use strict;
use warnings;

use lib 't/lib';
use App::Mimosa::Test;

# the order is important
use App::Mimosa;
use Dancer::Test;
use File::Slurp qw/slurp/;

route_exists [ POST => '/submit'], 'a route handler is defined for /submit';

response_status_is([
        POST => '/submit',
        {
            params => {
                program  => 'blastp',
                sequence => slurp("t/data/blastdb_test.nucleotide.seq"),
            },
        }
], 200 );
