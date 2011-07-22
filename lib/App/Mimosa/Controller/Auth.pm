package App::Mimosa::Controller::Auth;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

sub login : Local {
    my ( $self, $c ) = @_;

    my $user     = $c->req->params->{user};
    my $password = $c->req->params->{password};

    if ( $user && $password ) {
        if ( $c->authenticate( { username => $user,
                                password => $password } ) ) {
            $c->forward('index');
        } else {
            # login incorrect
        }
    } else {
        # invalid form input
    }
}

1;
