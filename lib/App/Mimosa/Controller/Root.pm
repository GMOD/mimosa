package App::Mimosa::Controller::Root;
use Moose;
use namespace::autoclean;

use File::Temp qw/tempfile/;
use IO::String;
use File::Spec::Functions;

use Storable 'freeze';
use Digest::SHA1 'sha1_hex';
use Path::Class;

use Bio::SearchIO;
use Bio::SearchIO::Writer::HTMLResultWriter;
use File::Spec::Functions;

use App::Mimosa::Job;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller' }
with 'Catalyst::Component::ApplicationAttribute';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

App::Mimosa::Controller::Root - Root Controller for App::Mimosa

=head1 DESCRIPTION

Stuff.

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

    $c->stash->{template} = 'index.mason';
    $c->stash->{schema}   = $c->model('Model::BCS');
}

sub download_raw :Path("/api/report/raw") :Args(1) {
    my ( $self, $c, $job_id ) = @_;

    my $jobs = $c->model('BCS')->resultset('Mimosa::Job');
    my $rs   = $jobs->search({ mimosa_job_id => $job_id });
    if ($rs->count) {
    } else {
        $c->stash->{error} = 'That job does not exist';
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

sub submit :Path('/submit') :Args(0) {
    my ( $self, $c ) = @_;
    $c->forward('make_job_id');

    my $min_length = $self->_app->config->{min_sequence_input_length};
    # validate input
    unless( length( $c->req->param('sequence') || '' ) >= $min_length ) {
        $c->stash->{error} = 'Sequence input too short';
        $c->detach('/input_error');
    }

    # parse posted info
    my $input_file  = $self->_temp_file( $c->stash->{job_id}.'.in.fasta'  );
    my $output_file = $self->_temp_file( $c->stash->{job_id}.'.out.fasta' );
    $input_file->openw->print( $c->req->param('sequence') );

    my $ss_id = $c->req->param('mimosa_sequence_set_id');

    my @ss = $c->model('BCS')->resultset('Mimosa::SequenceSet')
                    ->search({ 'mimosa_sequence_set_id' =>  $ss_id });

    unless (@ss) {
        $c->stash->{error} = 'Invalid mimosa_sequence_set_id';
        $c->detach('/input_error');
    }
    # TODO: support multiple sequence sets in the future
    my $ss_name     = $ss[0]->shortname();
    my $seq_root    = $self->_app->config->{sequence_data_dir} || catdir(qw/examples data/);
    my $db_basename = catfile($seq_root,$ss_name);

    my $j;
    try {
        $j = App::Mimosa::Job->new(
            db_basename            => $db_basename,
            mimosa_sequence_set_id => $ss_id,
            alphabet               => $ss[0]->alphabet,
            output_file            => "$output_file",
            input_file             => "$input_file",
                map { $_ => $c->req->param($_) || '' }
                qw/
                sequence_input program
                maxhits output_graphs
                evalue matrix
                /,
        );
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
                -fh   => IO::String->new( \$report ),
            );
            $out->write_result($in->next_result);

            # TODO: Fix this stuff upstream
            $report =~ s!\Q<CENTER><H1><a href="http://bioperl.org">Bioperl</a> Reformatted HTML of BLASTN Search Report<br> for </H1></CENTER>\E!!g;
            $report =~ s!<p><p><hr><h5>Produced by Bioperl .*\$</h5>!!gs;

            if( $report =~ m/Hits_to_DB/ ){
                $c->stash->{template} = 'report.mason';
                $c->stash->{report}   = $report;
            } else {
                $c->stash->{template} = 'report.mason';
            }
        }
    } catch {
        $c->stash->{error} = "Invalid input: $_",
        $c->forward('input_error');
    };


}

sub make_job_id :Private {
    my ( $self, $c ) = @_;

    my $sha1 =  sha1_hex freeze {
        params  => $c->req->parameters,
        uploads => $c->req->uploads,
        #TODO: add the user - user   => $c->user,
    };

    my $rs = $c->model('BCS')->resultset('Mimosa::Job');
    if ($rs->search( { sha1 => $sha1 })->count == 0) { # not a duplicate job, proceed
        my $job = $rs->create({
            sha1 => $sha1,
            user => 'foo',
            start_time => '42',
            # end_time =>
        });
        $c->stash->{job_id} = $job->mimosa_job_id();
    } else { # this is a duplicate, notify user that it is already running
        # TODO: add more info to the error message
        $c->stash->{error} = 'This job is already running';
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
