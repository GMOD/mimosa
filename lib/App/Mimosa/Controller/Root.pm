package App::Mimosa::Controller::Root;
use Moose;
use namespace::autoclean;

use File::Temp qw/tempfile/;
use IO::String;
use File::Spec::Functions;
use File::Slurp qw/write_file slurp/;

use Storable 'freeze';
use Digest::SHA1 'sha1_hex';
use Path::Class;

use Bio::SearchIO;
use Bio::SearchIO::Writer::HTMLResultWriter;
use File::Spec::Functions;
use Bio::GMOD::Blast::Graph;

use App::Mimosa::Job;
use Try::Tiny;
use DateTime;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller' }
with 'Catalyst::Component::ApplicationAttribute';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

App::Mimosa::Controller::Root - Mimosa Root Controller

=head1 DESCRIPTION

This is the root controller of Mimosa. It defines all the URL's which
Mimosa responds to.

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my @sets = $c->model('BCS')->resultset('Mimosa::SequenceSet')->all;
    my @setinfo = map { [ $_->mimosa_sequence_set_id, $_->title ] } @sets;

    $c->stash->{sequenceset_html} = join '',
            map { "<option value='$_->[0]'> $_->[1] </option>" } @setinfo;

    $c->stash->{template}       = 'index.mason';
    $c->stash->{schema}         = $c->model('Model::BCS');

    # Must encode HTML entities here to prevent XSS attack
    $c->stash->{sequence_input} = encode_entities($c->req->param('sequence_input')) || '';
}

sub download_raw :Path("/api/report/raw") :Args(1) {
    my ( $self, $c, $job_id ) = @_;

    my $jobs = $c->model('BCS')->resultset('Mimosa::Job');
    my $rs   = $jobs->search({ mimosa_job_id => $job_id });
    if ($rs->count) {
        my $job = $rs->single;
        $c->stash->{job} = $job;
        my $output_file = $self->_temp_file( "$job_id.out.blast" );
        $c->serve_static_file( $output_file );
    } else {
        $c->stash->{error} = 'That job does not exist';
        $c->detach('/input_error');
    }
}

sub graphics :Path("/graphics") :Args(1) {
    my ($self, $c, $filename) = @_;

    my $graphic = catfile($self->_app->config->{tmp_dir},$filename);
    if (-e $graphic) {
        $c->serve_static_file($graphic);
    } else {
        $c->stash->{error} = 'That graphic does not exist';
        $c->detach('/input_error');
    }
}

sub poweredby :Path("/poweredby") :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{schema}   = $c->model('Model::BCS');
    $c->stash->{template} = 'poweredby.mason';
}

sub _temp_file {
    my $self = shift;
    my $tmp_base = dir( File::Spec->tmpdir, lc $self->_app->config->{name} );
    $tmp_base->mkpath unless -d $tmp_base;
    return $tmp_base->file( @_ );
}

sub validate : Private {
    my ( $self, $c ) = @_;

    unless ($self->_app->config->{allow_anonymous}) {
        $c->stash->{error} = 'Anonymous users are not allowed to submit BLAST jobs. Please log in.';
        $c->detach('/input_error');
    }

    if( $c->req->param('program') eq 'none' ) {
        $c->stash->{error} = "You must select a BLAST program to generate your report with.";
        $c->detach('/input_error');
    }

    my $min_length = $self->_app->config->{min_sequence_input_length};
    my $program    = $c->req->param('program')  || '';
    my $sequence   = $c->req->param('sequence') || '';

    unless (length($sequence) >= $min_length) {
        $c->stash->{error} = "Sequence input too short. Must have a length of at least $min_length";
        $c->detach('/input_error');
    }


    my $i = Bio::SeqIO->new(
        -format   => 'fasta',
        -file     => $c->stash->{input_file},
    );
    while ( my $s = $i->next_seq ) {
        # _validate_sequence( $c, $s, $program );
    }
}

sub _validate_sequence {
    my ($c, $sequence, $program) = @_;

    try {
        $sequence->validate_seq();
    } catch {
        $c->stash->{error} = "Sequence is frowned upon by BioPerl";
        $c->detach('/input_error');
    }
    my %validate   = (
        blastn  => qr/^([ACGTURYKMSWBDHVN]+)$/i,
        tblastx => qr/^([GAVLIPFYCMHKRWSTDENQBZ\.X\*]+)$/i,
        tblastn => qr/^([GAVLIPFYCMHKRWSTDENQBZ\.X\*]+)$/i,
    );
    my $seq = $sequence->seq();
    unless ($seq =~ $validate{$program}){
        $c->stash->{error} = "Sequence $seq contains illegal characters for $program";
        $c->detach('/input_error');
    }

}

sub submit :Path('/submit') :Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('make_job_id');

    my $input_file  = $self->_temp_file( $c->stash->{job_id}.'.in.fasta'  );
    my $output_file = $self->_temp_file( $c->stash->{job_id}.'.out.blast' );

    $c->stash->{input_file} = $input_file;

    $c->forward('validate');

    # If we accepted a POSTed sequence as input, it will be HTML encoded
    my $sequence = decode_entities($c->req->param('sequence'));

    # if there is no defline, create one
    unless ($sequence =~ m/^>/) {
        $sequence = ">web user sequence\n$sequence";
    }

    $input_file->openw->print( $sequence );

    my $ss_id = $c->req->param('mimosa_sequence_set_id');

    my @ss = $c->model('BCS')->resultset('Mimosa::SequenceSet')
                    ->search({ 'mimosa_sequence_set_id' =>  $ss_id });
    unless (@ss) {
        $c->stash->{error} = "Invalid mimosa_sequence_set_id";
        $c->detach('/input_error');
    }
    # TODO: support multiple sequence sets in the future
    my $ss_name     = $ss[0]->shortname();
    my $seq_root    = $self->_app->config->{sequence_data_dir} || catdir(qw/examples data/);
    my $db_basename = catfile($seq_root,$ss_name);

    my $j = App::Mimosa::Job->new(
        job_id                 => $c->stash->{job_id},
        config                 => $self->_app->config,
        db_basename            => $db_basename,
        mimosa_sequence_set_id => $ss_id,
        alphabet               => $ss[0]->alphabet,
        output_file            => "$output_file",
        input_file             => "$input_file",
            map { $_ => $c->req->param($_) || '' }
            qw/
            program maxhits output_graphs
            evalue matrix
            /,
    );

    # Regardless of it working, the job is now complete
    my $rs   = $c->model('BCS')->resultset('Mimosa::Job');
    $rs->search( { mimosa_job_id => $j->job_id } )->update( { end_time => DateTime->now } );

    my $error = $j->run;
    if ($error) {
        ( $c->stash->{error} = $error ) =~ s!\n!<br />!g;
        $c->detach( $error =~ /Could not calculate ungapped/i ? '/input_error' : '/error' );
    } else {

        # stat the output file before opening it in hopes of avoiding
        # some kind of bizarre race condition i've been seeing in
        # which the file doesn't appear to be visible yet to the web
        # process after blast exits.
        $output_file->stat;

        my $in = Bio::SearchIO->new(
                -format => 'blast',
                -file   => "$output_file",
        );
        my $writer = Bio::SearchIO::Writer::HTMLResultWriter->new;
        $writer->start_report(sub {''});
        $writer->end_report(sub {''});
        my $report = '';
        my $out = Bio::SearchIO->new(
            -writer => $writer,
            -fh     => IO::String->new( \$report ),
        );
        $out->write_result($in->next_result);

        # TODO: Fix this stuff upstream
        $report =~ s!\Q<CENTER><H1><a href="http://bioperl.org">Bioperl</a> Reformatted HTML of BLASTN Search Report<br> for </H1></CENTER>\E!!g;
        $report =~ s!<p><p><hr><h5>Produced by Bioperl .*\$</h5>!!gs;

        my $cached_report_file = $self->_temp_file( $c->stash->{job_id}.'.html' );
        my $report_html;

        if( $report =~ m/Sbjct: / ){
            my $graph_html = '';
            my $graph = Bio::GMOD::Blast::Graph->new(
                                            -outputfile => $output_file,
                                            -format     => 'blast',
                                            -fh         => IO::String->new( \$graph_html ),
                                            -dstDir     => $self->_app->config->{tmp_dir} || "/tmp/mimosa",
                                            -dstURL     => "/graphics/",
                                            -imgName    => $c->stash->{job_id} . '.png',
                                            );
            $graph->showGraph;

            $report_html        = $graph_html . $report;
            $c->stash->{report} = $report_html;
        } else {
            # Don't show a report if there were no hits.
            # The user can always download the raw report if they want.
            # This is why we don't assign to $c->stash->{report}

            $report_html  = $report;
        }
        $c->stash->{template} = 'report.mason';

        write_file( $cached_report_file, $report_html );
    }
    #} catch {
    #    $c->stash->{error} = "Invalid input: $_",
    #    $c->forward('input_error');
    #};


}

sub show_cached_report :Private {
    my ( $self, $c ) = @_;

    $c->stash->{report}   = slurp( $self->_temp_file( $c->stash->{job_id} . '.html' ) );
    $c->stash->{template} = 'report.mason';

}

sub make_job_id :Private {
    my ( $self, $c ) = @_;

    my $sha1 =  sha1_hex freeze {
        params  => $c->req->parameters,
        uploads => $c->req->uploads,
        #TODO: add the user - user   => $c->user,
    };

    my $rs = $c->model('BCS')->resultset('Mimosa::Job');
    my $jobs = $rs->search( { sha1 => $sha1 } );
    if ($jobs->count == 0) { # not a duplicate job, proceed
        my $job = $rs->create({
            sha1       => $sha1,
            user       => $c->user_exists ? $c->user->get('username') : 'anonymous',
            start_time => DateTime->now(),
        });
        $c->stash->{job_id} = $job->mimosa_job_id();
    } else { # this is a duplicate, check if it is still running and notify user appropriately
        my $job = $jobs->single;
        my ($start,$end) = ($job->start_time, $job->end_time);
        my $jid          = $job->mimosa_job_id;
        my $user         = $job->user;
        # TODO: add more info to the error message
        if( $end ) { # already finished
            $c->stash->{job_id} = $jid;
            $c->detach('/show_cached_report');
        } else {
            $c->stash->{error} = <<ERROR;
This job (# $jid) was started at $start by $user and is still running.
ERROR
        }
        $c->detach('/input_error');
    }

}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Nothing to see here' );
    $c->response->status(404);
}

=head2 input_error

Standard page for user-input errors.

=cut

sub input_error :Private {
    my ( $self, $c ) = @_;
    $c->res->status( 400 );
    $c->forward('error');
}
sub error :Private {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'error.mason';
    $c->res->status( 500 ) if ! $c->res->status || $c->res->status == 200;
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Jonathan "Duke" Leto <jonathan@leto.net>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
