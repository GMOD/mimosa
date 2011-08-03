package App::Mimosa;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst ((
#    '-Debug',
    qw/
    ConfigLoader
    Static::Simple
    AutoCRUD
    Authentication
    Authorization::Roles
    Session
    Session::State::Cookie
    Session::Store::FastMmap
    /)
);

extends 'Catalyst';

our $VERSION = '0.01';
$VERSION = eval $VERSION;

# Defaults

__PACKAGE__->config(
    name                                                     => 'Mimosa',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback              => 1,

    default_view                                             => 'Mason',
    'Plugin::Authentication'                                 => {
        default => {
            credential => {
                class => 'Password',
                password_field => 'password',
                password_type => 'clear'
            },
            store => {
                class => 'Minimal',
                users => {
                    petunia => {
                        password => "cUC598",
                    },
                }
            }
        }
}
);


# Start the application
__PACKAGE__->setup();


=head1 NAME

App::Mimosa - Miniature Model Organism Sequence Aligner

=head1 SYNOPSIS

    perl script/app_mimosa_server.pl

=head1 DESCRIPTION


=head1 SEE ALSO

L<App::Mimosa::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Jonathan "Duke" Leto <jonathan@leto.net>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
