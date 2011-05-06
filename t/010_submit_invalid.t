use Test::Most tests => 3;
use Modern::Perl;

use lib 't/lib';
use App::Mimosa::Test;
use Test::DBIx::Class;

use Catalyst::Test 'App::Mimosa';
use File::Slurp qw/slurp/;
use HTTP::Request::Common;
use File::Spec::Functions;

fixtures_ok 'basic_ss';

{
    local $TODO = 'validation still in progress';
    my $seq = <<SEQ;
> guano pie
ATIUSADHJKSHDJHSDFKJSDHFKJSDHFKJSDHFKJSDHFKJSDH
SEQ
    my $f = sub {
        return request POST '/submit', [
                    program                => 'blastn',
                    sequence               => $seq,
                    maxhits                => 100,
                    alphabet               => 'nucleotide',
                    matrix                 => 'BLOSUM62',
                    evalue                 => 0.1,
                    mimosa_sequence_set_id => 1,
       ];
    };
    my $res = $f->();
    is($res->code,400,'/submit with illegal chars') or diag $res->content;
    like($res->content,qr/contains illegal characters for blastn/, 'illegal character error');
}
