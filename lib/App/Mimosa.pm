package App::Mimosa;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw/schema/;

use App::Mimosa::Job;
use Data::Dumper;
use File::Temp qw/tempfile/;

use Bio::Chado::Schema;

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
    my ($input_fh, $input_filename) = tempfile( CLEANUP => 0 );
    my ($output_fh, $output_filename) = tempfile( CLEANUP => 0 );

    print $input_fh params->{sequence};
    close $input_fh;

    my $ss = schema('mimosa')->resultset('Bio::Chado::Schema::Mimosa::SequenceSet')->all;

    my $j = App::Mimosa::Job->new(
        program     => params->{program},
        output_file => $output_filename,
        input_file  => $input_filename,
        sequence_input => params->{sequence_input},
    )->run;
    template 'wait';
};

42;
