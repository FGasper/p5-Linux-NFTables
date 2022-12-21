use strict;
use warnings;

use ExtUtils::MakeMaker::CPANfile;
use ExtUtils::PkgConfig;

my $libs = ExtUtils::PkgConfig->libs('libnftables');
my $cflags = ExtUtils::PkgConfig->cflags('libnftables') || q<>;

if (!$libs) {
    die "pkg-config did not find libnftables; is it installed?$/";
}

WriteMakefile(
    NAME              => 'Linux::NFTables',
    VERSION_FROM      => 'lib/Linux/NFTables.pm', # finds $VERSION
    ABSTRACT_FROM  => 'lib/Linux/NFTables.pm', # retrieve abstract from module
    AUTHOR         => [
        'Felipe Gasper (FELIPE)',
    ],

    LICENSE => "perl_5",

    INC => join(
        q< >,
        '-Wall',
        '-std=c99',
        $cflags,
    ),

    LIBS => $libs,

    PMLIBDIRS => ['lib'],

    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url => 'git://github.com/FGasper/p5-Linux-NFTables.git',
                web => 'https://github.com/FGasper/p5-Linux-NFTables',
            },
            bugtracker => {
                web => 'https://github.com/FGasper/p5-Linux-NFTables/issues',
            },
        },
    },
);
