package App::Mimosa::Controller::Root;
use Moose;
use namespace::autoclean;
use autodie qw/:all/;

use File::Temp qw/tempfile/;
use IO::String;
use File::Spec::Functions;
use File::Slurp qw/write_file slurp/;

use Storable 'freeze';
use Digest::SHA1 'sha1_hex';
use Path::Class;

use Bio::SearchIO;
use Bio::SearchIO::FastHitEventBuilder;
use Bio::SearchIO::Writer::HTMLResultWriter;
use File::Spec::Functions;
use Bio::GMOD::Blast::Graph;

use App::Mimosa::Job;
use App::Mimosa::Database;
use Try::Tiny;
use DateTime;
use HTML::Entities;
use Digest::SHA1 qw/sha1_hex/;
use List::Util 'max';
use List::MoreUtils 'minmax';
#use Carp::Always;
use Cwd;

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

    $c->forward('login');
    $c->forward('show_grid');

}

sub show_grid :Local {
    my ($self, $c) = @_;

    my @sets = $c->model('BCS')->resultset('Mimosa::SequenceSet')->all;
    my @setinfo = map { [ $_->mimosa_sequence_set_id, $_->title ] } @sets;

    $c->stash->{sequenceset_html} = join '',
            map { "<option value='$_->[0]'> $_->[1] </option>" } @setinfo;

    $c->stash->{template}       = 'index.mason';
    $c->stash->{schema}         = $c->model('Model::BCS');

    # currently, any logged-in user has admin rights
    $c->stash->{admin} = 1 if $c->user_exists;

    # Must encode HTML entities here to prevent XSS attack
    $c->stash->{sequence_input} = encode_entities($c->req->param('sequence_input')) || '';
}

sub login :Local {
    my ($self, $c) = @_;

    if($c->user_exists || $self->_app->config->{allow_anonymous}) {
        # keep on forwardin'
    } else {
        $c->stash->{template} = 'login.mason';
        $c->detach;
    }

}

sub download_raw :Path("/api/report/raw") :Args(1) {
    my ( $self, $c, $job_id ) = @_;

    $c->forward('login');

    my $jobs = $c->model('BCS')->resultset('Mimosa::Job');
    my $rs   = $jobs->search({ mimosa_job_id => $job_id });
    if ($rs->count) {
        my $job = $rs->single;
        $c->stash->{job} = $job;
        my $output_file = $self->_temp_file( "$job_id.out.blast" );
        $c->serve_static_file( $output_file );
    } else {
        $c->stash->{error} = 'Sorry, that raw report does not exist';
        $c->detach('/input_error');
    }
}

sub download_report :Path("/api/report/html") :Args(1) {
    my ( $self, $c, $job_id ) = @_;

    $c->forward('login');

    my $jobs = $c->model('BCS')->resultset('Mimosa::Job');
    my $rs   = $jobs->search({ mimosa_job_id => $job_id });
    if ($rs->count) {
        my $job = $rs->single;
        $c->stash->{job} = $job;
        my $cached_report = $self->_temp_file( "$job_id.html" );
        if ( !-e $cached_report ) {
            warn "Cached file not found!";
        }
        $c->stash->{job_id} = $job_id;
        $c->stash->{report} = slurp($cached_report);
        $c->stash->{template} = 'report.mason';
    } else {
        $c->stash->{error} = 'Sorry, that HTML report does not exist';
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

sub _temp_file {
    my $self = shift;
    my $tmp_base = dir( $self->_app->config->{tmp_dir} );
    $tmp_base->mkpath unless -d $tmp_base;
    my $file = $tmp_base->file( @_ );

    return "$file";
}

sub validate : Private {
    my ( $self, $c ) = @_;

    if( $c->req->param('program') eq 'none' ) {
        $c->stash->{error} = "You must select a BLAST program to generate your report with.";
        $c->detach('/input_error');
    }

    my $min_length = $self->_app->config->{min_sequence_input_length};
    my $program    = $c->req->param('program');

    my $cwd               = getcwd;
    my $seq_root          = $self->_app->config->{sequence_data_dir} || catdir(qw/examples data/);
    $c->stash->{seq_root} = catfile($cwd, $seq_root);

    # a job hasn't been created yet, so we can't yet read from stash->{input_file}
    my $sequence = $c->stash->{sequence};

    my $i = Bio::SeqIO->new(
        -format   => 'fasta',
        -fh       => IO::String->new( \$sequence ),
    );
    my $sequence_count = 0;
    while ( my $s = $i->next_seq ) {
        unless (length($s->seq()) >= $min_length) {
            $c->stash->{error} = "Sequence input too short. Must have a length of at least $min_length";
            $c->detach('/input_error');
        }
        $c->stash->{sequence} = $s;
        $c->stash->{program}  = $program;
        $c->forward('validate_sequence');
        $sequence_count++;
    }
    $c->stash->{sequence_count} = $sequence_count;
}

sub validate_sequence : Private {
    my ($self, $c) = @_;
    my $sequence = $c->stash->{sequence};
    my $program  = $c->stash->{program};

    try {
        $sequence->validate_seq();
    } catch {
        $c->stash->{error} = "Sequence is not a valid BioPerl sequence";
        $c->detach('/input_error');
    };

    unless ($program && $program ne 'none') {
        $c->stash->{error} = "Invalid program";
        $c->detach('/input_error');
    }

    my %validate   = (
        blastn  => qr/^([ACGTURYKMSWBDHVN]+)$/i,
        tblastx => qr/^([GAVLIPFYCMHKRWSTDENQBZ\.X\*]+)$/i,
        tblastn => qr/^([GAVLIPFYCMHKRWSTDENQBZ\.X\*]+)$/i,
    );
    my $seq = $sequence->seq();
    unless ($seq =~ $validate{$program}){
        my $encseq = encode_entities($seq);
        $c->stash->{error} = "Sequence $encseq contains illegal characters for $program";
        $c->detach('/input_error');
    }

}

sub compose_sequence_sets : Private {
    my ( $self, $c) = @_;
    my (@ss_ids)       = sort @{ $c->stash->{sequence_set_ids} };
    my $rs             = $c->model('BCS')->resultset('Mimosa::SequenceSet');
    my $seq_root       = $c->stash->{seq_root};
    my $composite_sha1 = "";
    my $composite_fasta= '';
    my $alphabet;

    # TODO: error if any one of the ids is not valid
    for my $ss_id (grep { $_ } @ss_ids) {
        my $search = $rs->search({ 'mimosa_sequence_set_id' =>  $ss_id });

        # we are guaranteed by unique constraints to only get one
        my $ss = $search->single;
        unless ($ss) {
            $c->stash->{error} = "Invalid mimosa_sequence_set_id";
            $c->detach('/input_error');
        }
        my $ss_name     = $ss->shortname();
        $alphabet       = $ss->alphabet();

        die "Can't read sequence set FASTA $seq_root/$ss_name.seq : $!" unless -e "$seq_root/$ss_name.seq";
        $c->log->debug("reading in $seq_root/$ss_name.seq");
        my $fasta = '';
        open( my $fh, '<', "$seq_root/$ss_name.seq");
        while (<$fh>) { $fasta .= $_ };
        close $fh;
        $composite_fasta  .= $fasta;

        # SHA1's are null until the first time we are asked to align against
        # the sequence set. If files on disk are changed without names changing,
        # we will need to refresh sha1's
        my $sha1 = $ss->sha1;
        if ($sha1) {
            $c->log->debug("Found cached sha1 $sha1");
            # TODO: If files on disk are changed without names changing,
            # we will need to refresh sha1's
        } else {
            #warn "computing sha1 of $ss_name";
            $sha1              = sha1_hex($fasta);
        }
        $composite_sha1   .= $sha1;
        $c->log->debug("updating $ss_id to $sha1");

        $search->update({ sha1 => $sha1 });

        $c->log->debug("found $ss_id with sha1 $sha1");
    }
    $composite_sha1 = sha1_hex($composite_sha1);
    $c->log->debug("computed composite sha1 $composite_sha1");
    my $db_basename = catfile($seq_root, '.mimosa_cache_' . $composite_sha1);

    unless (-e "$db_basename.seq" ) {
        my $len = length($composite_fasta);
        $c->log->debug("Cached database of multi sequence set $composite_sha1 not found, creating $db_basename.seq, length = $len");
        unless( $len ) {
            $c->stash->{error} = "Mimosa attempted to write a zero-size cache file $db_basename.seq . Some file permissions are probably incorrect.";
            $c->detach('/error');
        }
        $c->log->debug("writing composite fasta $db_basename.seq");
        open( my $fh, '>', "$db_basename.seq" );
        print $fh $composite_fasta;
        close $fh;

        $c->log->debug("creating mimosa db with db_basename=$db_basename");
        App::Mimosa::Database->new(
            alphabet    => $alphabet,
            db_basename => $db_basename,
        )->index;
    }
    $c->stash->{composite_sha1}    = $composite_sha1;
    $c->stash->{composite_db_name} = ".mimosa_cache_$composite_sha1";
    $c->stash->{alphabet}          = $alphabet;
}

sub submit :Path('/submit') :Args(0) {
    my ( $self, $c ) = @_;

    my $ids            = $c->req->param('mimosa_sequence_set_ids') || '';
    my $alignment_view = $c->req->param('alignment_view') || '0';

    $c->stash->{alignment_view} = $alignment_view;

    unless( $ids ) {
        $c->stash->{error} = "You must select at least one Mimosa sequence set.";
        $c->detach('/input_error');
    }

    # If we accepted a POSTed sequence as input, it will be HTML encoded
    my $sequence = decode_entities($c->req->param('sequence'));

    # if the user specified a file as their sequence input, read it in
    if( $c->req->param('sequence_input_file') ) {
        my ($upload) = $c->req->upload('sequence_input_file');
        $sequence  = $upload->slurp if $upload;
    }

    # if there is no defline, create one
    unless ($sequence =~ m/^>/) {
        $sequence = ">web user sequence\n$sequence";
    }
    $c->stash->{sequence} = $sequence;

    # we must validate before creating jobs, so we don't get the dumb message
    # that an invalid job submission is "still running"
    $c->forward('validate');

    $c->forward('make_job_id');

    die "job_id not set!" unless $c->stash->{job_id};

    my $input_file  = $self->_temp_file( $c->stash->{job_id}.'.in.fasta'  );
    my $output_file = $self->_temp_file( $c->stash->{job_id}.'.out.blast' );

    $c->stash->{input_file} = $input_file;
    $c->stash->{output_file}= $output_file;

    write_file $input_file, $sequence;


    # we create a file to keep track of what kind raw report format is being generated,
    # so later on we can tell Bio::SearchIO which format to parse

    $c->stash->{report_format} = $alignment_view;

    # prevent race conditions
    stat $input_file;


    my @ss_ids;

    if ($ids =~ m/,/){
        (@ss_ids) = split /,/, $ids;
    } else {
        @ss_ids = ($ids);
    }
    $c->stash->{sequence_set_ids} = [ @ss_ids ];
    my $db_basename;

    if( @ss_ids > 1 ) {
        $c->forward('compose_sequence_sets');
        $db_basename = catfile($c->stash->{seq_root}, $c->stash->{composite_db_name});
    } elsif( @ss_ids == 1) {
        my $rs       = $c->model('BCS')->resultset('Mimosa::SequenceSet');
        my ($ss)     = $rs->search({ 'mimosa_sequence_set_id' =>  $ss_ids[0] })->single;
        die "No mimosa_sequence_set_id $ss_ids[0] !" unless $ss;
        $db_basename = catfile($c->stash->{seq_root}, $ss->shortname);
    } else {
        $c->stash->{error} = "The value " . encode_entities($ids) . " does not match any sequence sets";
        $c->detach('/input_error');
    }

    my $j = App::Mimosa::Job->new(
        context                => $c,
        timeout                => $self->_app->config->{job_runtime_max} || 5,
        job_id                 => $c->stash->{job_id},
        config                 => $self->_app->config,
        # force stringification to avoid arcane broken magic at a distance
        db_basename            => "$db_basename",
        # TODO: fix this properly
        alphabet               => $c->stash->{alphabet} || 'nucleotide',
        output_file            => "$output_file",
        input_file             => "$input_file",
        alignment_view         => $alignment_view,
            map { $_ => $c->req->param($_) || '' }
            qw/ program maxhits output_graphs evalue matrix /,
    );

    # Regardless of it working, the job is now complete
    my $rs   = $c->model('BCS')->resultset('Mimosa::Job');
    $rs->search( { mimosa_job_id => $j->job_id } )->update( { end_time => DateTime->now } );

    my $error = $j->run;
    if ($error) {
        ( $c->stash->{error} = $error ) =~ s!\n!<br />!g;
        $c->detach( $error =~ /Could not calculate ungapped/i ? '/input_error' : '/error' );
    } else {
        $c->forward('report');
    }
}

sub report :Local {
    my ( $self, $c ) = @_;

    my $output_file = $c->stash->{output_file};
    my @ss_ids      = @{ $c->stash->{sequence_set_ids} };

    # stat the output file before opening it in hopes of avoiding
    # some kind of bizarre race condition i've been seeing in
    # which the file doesn't appear to be visible yet to the web
    # process after blast exits.
    stat $output_file;

    # these are the only formats we can parse and generate an HTML report for
    my $format_num_to_name = {
        0 => 'blast',
        7 => 'blastxml',
        8 => 'blasttable',
        9 => 'blasttable',
    };
    my $format = $format_num_to_name->{$c->stash->{report_format}} || '';

    mkdir $self->_app->config->{tmp_dir} unless -e $self->_app->config->{tmp_dir};

    my $report = '';
    my $report_fh = IO::String->new( \$report );
    my $cached_report_file = $self->_temp_file( $c->stash->{job_id}.'.html' );
    my $report_html;

    # we only use bioperl to write the html report if is a single sequence and the default view
    if ( $c->stash->{sequence_count} == 1 && $c->stash->{alignment_view} == 0) {
        my $in = Bio::SearchIO->new(
                -format => $format,
                -file   => "$output_file",
        );

        die "Bio::SearchIO->new could not read $output_file" unless $in;

        my $hit_link = sub {
            my ($self, $hit) = @_;
            my $name = $hit->name;
            my $id   = $ss_ids[0] || 1;

            return qq{<a href="/api/sequence/id/$id/$name.fasta">$name</a>};
        };
        my $writer = Bio::SearchIO::Writer::HTMLResultWriter->new;
        $writer->start_report(sub {''});
        $writer->end_report(sub {''});
        $writer->hit_link_desc( $hit_link );
        $writer->hit_link_align( $hit_link );
        my $out = Bio::SearchIO->new(
            -writer => $writer,
            -fh     => $report_fh,
        );
        $out->attach_EventHandler(Bio::SearchIO::FastHitEventBuilder->new);
        $out->write_result($in->next_result);
    } else { # we have to build the HTML report ourselves
        $report = $report_html  = _generate_html_report($c);
        $c->stash->{report} = $report_html;
    }
    # Bio::GMOD::Blast::Graph can only deal with plain blast reports
    if( $format eq 'blast' && $report =~ m/Sbjct: / ){
        my $graph_html = '';
        my $graph = Bio::GMOD::Blast::Graph->new(
                        -outputfile => "$output_file",
                        -format     => $format,
                        -fh         => IO::String->new( \$graph_html ),
                        -dstDir     => $self->_app->config->{tmp_dir} || "/tmp/mimosa",
                        -dstURL     => "/graphics/",
                        -imgName    => $c->stash->{job_id} . '.png',
        );
        $graph->showGraph;

        $report_html        = $graph_html . $report;
        $c->stash->{report} = $report_html;
    } elsif ($format eq 'blast') {
        # Don't show a report if there were no hits.
        # The user can always download the raw report if they want.
        # This is why we don't assign to $c->stash->{report}

        $report_html  = $report;
    } else {
        # The report format is not a plain blast, so just render
        # the HTML report with no images
        $report_html        = $report;
        $c->stash->{report} = $report_html;

    }
    $c->stash->{template} = 'report.mason';

    write_file( $cached_report_file, $report_html );

}

sub linkit {
    my ($c,$id) = @_;
    my (@ss) = @{ $c->stash->{sequence_set_ids} };

    return '' unless $id;

    # if we have a composite db name, we are dealing with a composite sequence set
    # and need to look stuff up by sha1
    if (my $sha1 = $c->stash->{composite_sha1}) {
        return qq{<a href="/api/sequence/sha1/$sha1/$id.fasta">$id</a>};
    } else { # we can look stuff up by id
        return qq{<a href="/api/sequence/id/$ss[0]/$id.fasta">$id</a>};
    }
}

# forgive me, for this function is a sin
sub _generate_html_report {
    my ($c) = @_;
    my $report = '';
    my $fmt = IO::String->new( \$report );

    # the raw report
    open my $raw, $c->stash->{output_file};

    my %custom_formatters = (
        0 => sub {  # default formatter
            print $fmt qq|<pre>|;
            while (my $line = <$raw>) {
                $line = encode_entities($line);
                # $line =~ s/(?<=Query[=:]\s)(\S+)/linkit($c,$1)/eg;
                print $fmt $line;
            }
            print $fmt qq|</pre>\n|;
        },
        7 => sub {  ### XML
            print $fmt qq|<pre>|;
            while (my $line = <$raw>) {
                $line = encode_entities($line);
                # $line =~ s/(?<=&lt;BlastOutput_query-def&gt;)[^&\s]+/linkit($c,$1)/e;
                $line =~ s/(?<=&lt;Hit_accession&gt;)[^&\s]+/linkit($c,$1)/e;
                print $fmt $line;
            }
            print $fmt qq|</pre>\n|;
        },

        8 => sub { ## TABULAR, NO COMMENTS
            my @data;
            while (my $line = <$raw>) {
                chomp $line;
                $line = encode_entities($line);
                my @fields = split /\t/,$line;
                @fields[0,1] = map {linkit($c,$_)} @fields[0,1];
                push @data, \@fields;
            }
            print $fmt columnar_table_html( data => \@data );
        },

        9 => sub { ## TABULAR WITH COMMENTS
            print $fmt qq|<pre>|;
            while (my $line = <$raw>) {
                $line = encode_entities($line);
                if( $line =~ /^\s*#/ ) {
                    # $line =~ s/(?<=Query: )\S+/linkit($c,$1)/e;
                } else {
                    my @fields = split /\t/,$line;
                    @fields[0,1] = map linkit($c,$_),@fields[0,1];
                    $line = join "\t",@fields;
                }
                print $fmt $line;
            }
            print $fmt qq|</pre>\n|;
        },
    );
    my $default_formatter = sub {
            print $fmt qq{<pre>};
            while (my $line = <$raw>) {
                print $fmt $line;
            }
            print $fmt qq{</pre};
    };

    # these formats just get a <pre> tag wrapped around them for now
    for ((1 .. 6,10 .. 12)) {
        $custom_formatters{ $_ } = $default_formatter;
    }

    my $formatter = $custom_formatters{ $c->stash->{alignment_view} };
    $formatter->() if $formatter;
    return $report;
}

sub show_cached_report :Private {
    my ( $self, $c ) = @_;

    my $cached_report_file = $self->_temp_file( $c->stash->{job_id} . '.html' );
    if (-e $cached_report_file) {
        my $cached_report     = slurp($cached_report_file);
        $c->stash->{report}   = $cached_report;
        $c->stash->{template} = 'report.mason';
    } else {
            $c->stash->{error} = <<ERROR;
Could not find cached report file $cached_report_file !
ERROR
        $c->detach('/error');
    }

}

sub make_job_id :Private {
    my ( $self, $c ) = @_;

    # Storable cannot serialize filehandles, which are GLOBs,
    # so we can't pass in $c->req->uploads
    my $sha1 =  sha1_hex freeze {
        params   => $c->req->parameters,
        # the sequence key takes into account the file content of uploads
        sequence => $c->stash->{sequence},
        #TODO: add the user - user   => $c->user,
    };

    my $rs   = $c->model('BCS')->resultset('Mimosa::Job');
    my $jobs = $rs->search( { sha1 => $sha1 } );

    if ($jobs->count == 0) { # not a duplicate job, proceed
        my $job = $rs->create({
            sha1       => $sha1,
            user       => $c->user_exists ? $c->user->get('username') : 'anonymous',
            start_time => DateTime->now(),
        });
        $c->stash->{job_id} = $job->mimosa_job_id();
    } else { # this is a duplicate, check if it is still running and notify user appropriately
        my $job          = $jobs->single;
        my ($start,$end) = ($job->start_time, $job->end_time);
        my $jid          = $job->mimosa_job_id;
        my $user         = $job->user;
        # TODO: add more info to the error message
        if( $end ) { # already finished
            $c->stash->{job_id} = $jid;
            $c->detach('/show_cached_report');
        } else {
            $user ||= 'anonymous';
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

sub columnar_table_html {
    my %params = @_;

    die "must provide 'data' parameter" unless $params{data};

    my $noborder = $params{__border} ? '' : '_noborder';

    my $html;

    #table beginning
    $params{__tableattrs} ||= qq{summary="" cellspacing="0" width="100%"};
    $html .=
      qq|<table class="columnar_table$noborder" $params{__tableattrs}>\n|;

    if( defined $params{__caption} ) {
        $html .= "<caption>$params{__caption}</caption>\n";
    }

    unless ( defined $params{__alt_freq} ) {
        $params{__alt_freq} =
            @{ $params{data} } > 6 ? 4
          : @{ $params{data} } > 2 ? 2
          :                          0;
    }
    unless ( defined $params{__alt_width} ) {
        $params{__alt_width} = @{ $params{data} } > 6 ? 2 : 1;
    }
    unless ( $params{__alt_width} < $params{__alt_freq} ) {
        $params{__alt_width} = $params{__alt_freq} / 2;
    }
    unless ( defined $params{__alt_offset} ) {
        $params{__alt_offset} = 0;
    }

    #set the number of columns in our table.  rows will be padded
    #up to this with '&nbsp;' if they don't have that many columns
    my $cols =
      $params{headings}
      ? scalar( @{ $params{headings} } )
      : max( map { scalar(@$_) } @{ $params{data} } );
    $cols ||= 1;

    ###figure out text alignments of each column
    my @alignments = do {
        if ( ref $params{__align} ) {
            ref( $params{__align} ) eq 'ARRAY'
              or die '__align parameter must be either a string or an arrayref';
            @{ $params{__align} }    #< just dereference it
        }
        elsif ( $params{__align} ) {
            split '', $params{__align};    #< explode the string into an array
        }
        else {
            ('c') x $cols;
        }
    };
    my %lcr =
      ( l => 'align="left"', c => 'align="center"', r => 'align="right"' );
    foreach (@alignments) {
        if ($_) {
            $_ = $lcr{$_} or die "'$_' is not a valid column alignment";
        }
    }

    #columns headings
    if ( $params{headings} ) {

        # Turn headings like this:
        #  [ 'foo', undef, undef, 'bar' ]
        # into this:
        # <tr><th colspan="3">foo</th><th>bar</th></tr>
        # The first column heading may not be undef.
        unless ( defined( $params{headings}->[0] ) ) {
            die "First column heading is undefined";
        }
        $html .= '<thead><tr>';

        # The outer loop grabs the defined colheading; the
        # inner loop advances over any undefs.
        my $i = 0;
        while ( $i < @{ $params{headings} } ) {
            my $colspan = 1;
            my $align   = $alignments[$i] || '';
            my $heading = $params{headings}->[ $i++ ] || '';
            while (( $i < @{ $params{headings} } )
                && ( !defined( $params{headings}->[$i] ) ) )
            {
                $colspan++;
                $i++;
            }
            $html .=
"<th $align class=\"columnar_table$noborder\" colspan=\"$colspan\">$heading</th>";
        }
        $html .= "</tr></thead>\n";
    }

    $html .= "<tbody>\n";
    my $hctr                     = 0;
    my $rows_remaining_to_hilite = 0;
    foreach my $row ( @{ $params{data} } ) {
        if ( $params{__alt_freq} != 0
            && ( $hctr++ - $params{__alt_offset} ) % $params{__alt_freq} == 0 )
        {
            $rows_remaining_to_hilite = $params{__alt_width};
        }
        my $hilite = do {
            if ($rows_remaining_to_hilite) {
                $rows_remaining_to_hilite--;
                'class="columnar_table bgcoloralt2"';
            }
            else {
                'class="columnar_table bgcoloralt1"';
            }
        };

        #pad the row with &nbsp;s up to the length of the headings
        if ( @$row < $cols ) {
            $_ = '&nbsp;' foreach @{$row}[ scalar(@$row) .. ( $cols - 1 ) ];
        }
        $html .= "<tr>";
        for ( my $i = 0 ; $i < @$row ; $i++ ) {
            my $a = $alignments[$i] || '';
            my $c = $row->[$i]      || '';
            my $tdparams = '';
            if ( ref $c eq 'HASH' )
            {    #< process HTML attributes if this piece of data is a hashref
                my $d = $c;
                $c = delete $d->{content};
                if ( my $moreclasses = delete $d->{class} )
                {    #< add more classes if present
                    $hilite =~ s/"$/ $moreclasses"/x;
                }
                if ( exists $d->{'colspan'} )
                { ### If exists a colspan it should not add more columns so, we increase
                    ### the column count as many times as colspan
                    $i = $i + $d->{'colspan'};
                }
                $tdparams = join ' ',
                  map { qq|$_="$d->{$_}"| } grep { $_ ne 'content' } keys %$d;
            } elsif( ref $c eq 'ARRAY' ) {
                $c = "@$c";
            }
            $html .= "<td $hilite $tdparams $a>$c</td>";
        }
        $html .= "</tr>\n";

#    $html .= join( '',('<tr>',(map {"<td $hilite>$_</td>"} @$row),'</tr>'),"\n" );
    }
    $html .= "</tbody></table>\n";

    return $html;
}

__PACKAGE__->meta->make_immutable;

1;
