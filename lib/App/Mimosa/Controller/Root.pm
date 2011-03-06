package App::Mimosa::Controller::Root;
use Moose;
use Bio::Chado::Schema;
use App::Mimosa::Job;
use Catalyst::Model::DBIC::Schema;

use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

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

    my @sets = $c->model('BCS')->resultset('SequenceSet');
    my @setinfo = map { [ $_->mimosa_sequence_set_id, $_->title ] } @sets;

    $c->stash->{sequenceset_html} =
            map { "<option value='$_->[0]'> $_->[1] </option>" } @setinfo;

    $c->stash->{template} = 'index.mason';
    $c->stash->{schema}   = $c->model('Model::BCS');
}


sub submit :Path('/submit') :Args(0) {
    my ( $self, $c ) = @_;
    # TODO: VALIDATION!
    # parse posted info
    my ($input_fh, $input_filename) = tempfile( CLEANUP => 0 );
    my ($output_fh, $output_filename) = tempfile( CLEANUP => 0 );
    my ($html_report_fh, $html_report) = tempfile( CLEANUP => 0 );

    print $input_fh $c->req->param('sequence');
    close $input_fh;

    my $j = App::Mimosa::Job->new(
        program        => $c->req->param('program'),
        output_file    => $output_filename,
        input_file     => $input_filename,
              map { $_ => $c->req($_) }
            qw/sequence_input
               maxhits output_graphs
               evalue matrix
              /,
    );
    my $error = $j->run;
    warning("error = $error");
    if ($error) {
        $c->stash->{template} = 'error.mason';
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

        $c->stash->{template} = join "", slurpl($html_report);
    }

}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
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
