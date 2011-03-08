package App::Mimosa::Test;
use strict;
use warnings;
use FindBin qw($Bin);
use Test::More;

BEGIN{
    diag "Checking for $Bin/../mimosa.db";
    unless (-s "$Bin/../mimosa.db") {
        diag "Deploying schema with $Bin/../app_mimosa.conf";
        qx{$^X -Ilib $Bin/../script/mimosa_deploy.pl $Bin/../app_mimosa.conf}
    };
};

1;


