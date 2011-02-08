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
        'Moose'                   => '1.00',
        'YAML'                    => 0,
        'Dancer'                  => '1.3002',
        'Dancer::Template::Mason' => 0,
        'Class::Accessor::Fast'   => 0,
        'IPC::System::Simple'     => 0,
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
