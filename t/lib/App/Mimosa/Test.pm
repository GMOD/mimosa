package App::Mimosa::Test;
use strict;
use warnings;
use FindBin qw($Bin);
use Test::More;

BEGIN{
    diag "Checking for $Bin/t/data/mimosa.db";
    unless (-s "$Bin/../mimosa.db") {
        #diag "Deploying schema with $Bin/t/data/config.yml";
        #qx{$^X -Ilib $Bin/../bin/deploy.pl $Bin/t/data/config.yml}
    };
};

1;


