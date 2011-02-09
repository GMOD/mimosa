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
    my ($input_fh, $input_filename) = tempfile();
    my ($output_fh, $output_filename) = tempfile();

    print $input_fh params->{sequence_input};
    close $input_fh;

    my $j = App::Mimosa::Job->new(
        program     => params->{program},
        output_file => $output_filename,
        input_file  => $input_filename,
    )->run;
    print "submitted!";
};

true;
