package App::Mimosa;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw/schema/;
use Dancer::Plugin::Database;
use Dancer::Plugin::SimpleCRUD;

use App::Mimosa::Job;
use Data::Dumper;
use File::Temp qw/tempfile/;
use File::Slurp qw/slurp/;
use Bio::SearchIO;
use Bio::SearchIO::Writer::HTMLResultWriter;
use Bio::Chado::Schema;

our $VERSION = '0.1';

simple_crud(
    record_title => 'Sequence Set',
    prefix => '/sequence_set',
    db_table => 'mimosa_sequence_set',
    field_labels => {
        # country => 'Country of Origin',
        # type    => 'Widget Type',
    },
    key_column => 'mimosa_sequence_set_id',
    validation => {
        # weight => qr/\d+/,
    },
    editable_columns => [
        qw(
           mimosa_sequence_set_id
           shortname alphabet title description is_public
           source_spec info_url update_interval lookup_spec
        ),
    ],
    deleteable => 1,
);


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
    my ($html_report_fh, $html_report) = tempfile( CLEANUP => 0 );

    print $input_fh params->{sequence};
    close $input_fh;

    my $j = App::Mimosa::Job->new(
        program        => params->{program},
        output_file    => $output_filename,
        input_file     => $input_filename,
              map { $_ => params->{$_} }
            qw/sequence_input
               maxhits output_graphs
               evalue matrix
              /,
    );
    my $error = $j->run;
    warning("error = $error");
    if ($error) {
        template 'error', {
            error => $error,
        };
    } else {
        my $in = Bio::SearchIO->new(
                # -format => $bioperl_formats{$params{outformat}},
                -file   => "< $output_filename",
        );
        my $writer = Bio::SearchIO::Writer::HTMLResultWriter->new;
        $writer->start_report(sub {''});
        $writer->end_report(sub {''});
        my $out = Bio::SearchIO->new(
            -writer => $writer,
            -file   => "> $html_report",
        );
        $out->write_result($in->next_result);

        template 'results', {
            output => join "", slurp($html_report),
        };
    }
};

42;
