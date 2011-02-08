package App::Mimosa;
use Dancer ':syntax';
use App::Mimosa::Job;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/results' => sub {
    template 'results';
};

get '/jobs' => sub {
    template 'jobs';
};

post '/submit' => sub {
    # parse posted info
    my $a = App::Mimosa::Job->new( command => 'foo' );
    die "job submitted";
};

true;
