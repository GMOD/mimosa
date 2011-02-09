package App::Mimosa;
use Dancer ':syntax';
use App::Mimosa::Job;
use Data::Dumper;
use File::Temp qw/tempfile/;

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
    # TODO: VALIDATION!
    # parse posted info
    my ($program) = ( map { params->{$_} } qw/program/);
    my $a = App::Mimosa::Job->new;
    $a->run(
        program     => $program,
        output_file => tempfile(),
    );
    print "submitted!";
};

true;
