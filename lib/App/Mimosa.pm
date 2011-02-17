package App::Mimosa;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw/schema/;

use App::Mimosa::Job;
use Data::Dumper;
use File::Temp qw/tempfile/;
use File::Slurp qw/slurp/;

use Bio::Chado::Schema;

our $VERSION = '0.1';

get '/' => sub {
    my @sets = schema('mimosa')->resultset('Mimosa::SequenceSet')->all;
    my @setinfo = map { [ $_->mimosa_sequence_set_id, $_->title ] } @sets;

    template 'index', {
        sequenceset_html =>
            map { "<option value='$_->[0]'> $_->[1] </option>" } @setinfo
    };
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

    my $j = App::Mimosa::Job->new(
        program        => params->{program},
        output_file    => $output_filename,
        input_file     => $input_filename,
        sequence_input => params->{sequence_input},
    )->run;

    template 'results', {
        output => join "", slurp($output_filename),
    };
};

42;
