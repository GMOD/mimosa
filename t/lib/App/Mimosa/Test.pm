package App::Mimosa::Test;
use strict;
use warnings;
use FindBin qw($Bin);
use Test::More;

BEGIN{
    diag "Checking for $Bin/../mimosa.db";
    unless (-s "$Bin/../mimosa.db") {
        diag "Deploying schema with $Bin/../config.yml";
        qx{$^X -Ilib $Bin/../bin/deploy.pl $Bin/../config.yml}
    };
};

1;


