use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'App::Mimosa',
    license             => 'perl',
    dist_author         => 'Jonathan "Duke" Leto <jonathan@leto.net>',
    dist_abstract       => 'Miniature Model Organism Sequence Aligner',
    dist_version_from   => 'lib/App/Mimosa.pm',
    include_dirs        => '',
    build_requires => {
        'Catalyst::Test'                 => 0,
        'Test::DBIx::Class'              => 0,
        'Test::Most'                     => 0,
        'Test::WWW::Mechanize::Catalyst' => 0,
    },
    recursive_test_files => 1,
    requires => {
        'aliased'                                => 0,
        'autodie'                                => '2.00',
        'Bio::BLAST::Database'                   => '0.2',
        'Bio::Chado::Schema'                     => '0.08100',
        'Bio::Root::Version'                     => '1.006009',
        'Catalyst::Action::RenderView'           => 0,
        'Catalyst::Controller::REST'             => 0,
        'Catalyst::Model::DBIC::Schema'          => '0.48',
        'Catalyst::Plugin::Authentication'       => '0.10016',
        'Catalyst::Plugin::Authorization::Roles' => 0,
        'Catalyst::Plugin::AutoCRUD'             => '1.110731',
        'Catalyst::Plugin::ConfigLoader'         => 0,
        'Catalyst::Plugin::Static::Simple'       => 0,
        'Catalyst::Runtime'                      => '5.80029',
        'Catalyst::View::Bio::SeqIO'             => 0,
        'Catalyst::View::Email'                  => 0,
        'Catalyst::View::HTML::Mason'            => 0,
        'Class::Accessor::Fast'                  => 0,
        'Config::JFDI'                           => 0,
        'Digest::SHA1'                           => 0,
        'DBIx::Class'                            => '0.08127',
        'File::Temp'                             => 0,
        'IPC::Run'                               => 0,
        'IPC::System::Simple'                    => 0,
        'IO::String'                             => 0,
        'Moose'                                  => '1.19',
        'SQL::Translator'                        => '0.11007',
        'namespace::autoclean'                   => 0,
        'Path::Class'                            => 0,
        'YAML'                                   => 0,
    },
    add_to_cleanup      => [ 'mimosa.db' ],
    create_makefile_pl  => 'traditional',
    meta_merge     => {
        resources => {
            repository  => 'http://github.com/gmod/mimosa/tree/master'
        },
    },
);

$builder->create_build_script();
print "Have a great day!\n";
