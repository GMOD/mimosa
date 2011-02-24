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
        'Bio::Root::Version'               => '1.006009',
        'Moose'                            => '1.19',
        'YAML'                             => 0,
        'Class::Accessor::Fast'            => 0,
        'IPC::System::Simple'              => 0,
        'autodie'                          => 0,
        'Bio::Chado::Schema'               => '0.08000',
        'Catalyst::Runtime'                => '5.80029',
        'Catalyst::Controller::REST'       => 0,
        'Catalyst::Plugin::Authentication' => 0,
        'Catalyst::View::HTML::Mason'      => 0,
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
