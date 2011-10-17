package App::Mimosa::Util;
use autodie qw/:all/;
use parent 'Exporter';

our @EXPORT_OK = qw/slurp/;

# we need our own slurp because File::Slurp uses 3x the memory of the file that it is reading

sub slurp {
    my ($filename) = @_;
    my $content = '';
    open( my $fh, '<', $filename);
    while (<$fh>) { $content .= $_ };
    close $fh;
    return $content;
}

1;
