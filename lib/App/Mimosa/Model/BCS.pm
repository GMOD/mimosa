package App::Mimosa::Model::BCS;
use base qw/Catalyst::Model::DBIC::Schema/;

__PACKAGE__->config(
    schema_class => 'Bio::Chado::Schema',
    connect_info => ['dbi:SQLite:mimosa.db', '', '', {AutoCommit=>1} ],
);

1;
