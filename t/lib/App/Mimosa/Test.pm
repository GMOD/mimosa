package App::Mimosa::Test;
use strict;
use warnings;
use autodie qw/:all/;

use base 'Exporter';
our @EXPORT = (
    # re-export subs from Catalyst::Test
    qw(
          get
          request
          ctx_request
          action_ok
          action_redirect
          action_notfound
          content_like
          contenttype_is
    ),
  );

# set things up for in-process testing only
BEGIN {
    delete $ENV{CATALYST_SERVER};
    delete $ENV{APP_MIMOSA_SERVER};
    $ENV{CATALYST_CONFIG_LOCAL_SUFFIX} = 'testing';

    # TODO: Look this up in app_mimosa_testing.conf
    unless (-e "mimosa_test.db") {
        system("$^X -Ilib ./script/mimosa_deploy.pl app_mimosa_testing.conf");

    }
}

# load the app, grab the context object so we can use it for configuration
use Catalyst::Test 'App::Mimosa';
my ( undef, $c ) = ctx_request('/nonexistent_url_for_t_lib_app_mimosa_test');
sub app { $c }


1;


