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
        'Test::Most'      => 0,
    },
    requires => {
        'autodie'                                => '2.00',
        'Bio::Chado::Schema'                     => '0.08000',
        'Bio::Root::Version'                     => '1.006009',
        'Catalyst::Action::RenderView'           => 0,
        'Catalyst::Controller::REST'             => 0,
        'Catalyst::Plugin::Authentication'       => 0,
        'Catalyst::Plugin::Authorization::Roles' => 0,
        'Catalyst::Plugin::AutoCRUD'             => '1.110471',
        'Catalyst::Plugin::ConfigLoader'         => 0,
        'Catalyst::Plugin::Static::Simple'       => 0,
        'Catalyst::Runtime'                      => '5.80029',
        'Catalyst::View::Bio::SeqIO'             => 0,
        'Catalyst::View::Email'                  => 0,
        'Catalyst::View::HTML::Mason'            => 0,
        'Class::Accessor::Fast'                  => 0,
        'Config::General'                        => 0,
        'IPC::System::Simple'                    => 0,
        'Moose'                                  => '1.19',
        'namespace::autoclean'                   => 0,
        'YAML'                                   => 0,
    },
    add_to_cleanup      => [  ],
    create_makefile_pl  => 'traditional',
    meta_merge     => {
        resources => {
            repository  => 'http://github.com/gmod/mimosa/tree/master'
        },
    },
);

$builder->create_build_script();
print "Have a great day!\n";
