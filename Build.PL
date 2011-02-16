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
        'Bio::Root::Version'      => '1.006009',
        'Moose'                   => '1.00',
        'YAML'                    => 0,
        'Dancer'                  => '1.3002',
        'Dancer::Template::Mason' => 0,
        'Dancer::Plugin::DBIC'    => '0.1504',
        'Class::Accessor::Fast'   => 0,
        'IPC::System::Simple'     => 0,
        'autodie'                 => 0,
        'Bio::Chado::Schema'      => '0.08000',
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
