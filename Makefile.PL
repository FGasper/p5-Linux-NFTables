use strict;
use warnings;

use Config;

use ExtUtils::MakeMaker::CPANfile;
use ExtUtils::PkgConfig;
use File::Temp;

my $PC_MODULE = 'libnftables';

my $version = ExtUtils::PkgConfig->modversion($PC_MODULE);

if (!$version) {
    die "pkg-config did not find libnftables; is it installed?$/";
}

if ($version =~ m<\A0>) {
    die "Unsupported libnftables version: $version$/";
}

my $libs = ExtUtils::PkgConfig->libs($PC_MODULE);
my $cflags = ExtUtils::PkgConfig->cflags($PC_MODULE) || q<>;

# Sometimes the linker fails to load libnftnl at runtime,
# so let’s save a hint.
#
my @libdirs = split m<\s+>, ExtUtils::PkgConfig->libs_only_L($PC_MODULE);
s<\A-L><> for @libdirs;

#----------------------------------------------------------------------
my @checks = (
    ( map {
        my $identifier = $_;

        my $define = "GSC_$identifier";
        $define =~ tr<a-z><A-Z>;

        {
            label => $identifier,
            c => [
                '#include <nftables/libnftables.h>',
                'int main() {',
                "   (void)($identifier);",
                '   return 0;',
                '}',
            ],
            define => $define,
        };
    } (
        'NFT_CTX_OUTPUT_JSON',
    ) ),
);

my @defines;

{
    my $ccpath = $ENV{'CC'} || $Config::Config{'cc'};
    print "Your C compiler appears to be: $ccpath\n";

    for my $check (@checks) {
        my $tdir = File::Temp::tempdir( CLEANUP => 1 );
        my $cpath = File::Spec->catdir( $tdir, 'check.c' );
        my $progpath = File::Spec->catdir( $tdir, 'check' );

        {
            open my $wfh, '>', $cpath;
            print {$wfh} "$_$/" for @{ $check->{'c'} };
        }

        my $cmd = "$ccpath $Config{'ccflags'} $cflags $cpath -o $progpath $Config{ccdlflags} $libs";
        system($cmd);

        print "$check->{'define'}: ";
        if (-s $progpath) {
            print "yes";
            push @defines, $check->{'define'};
        }
        else {
            print "no";
        }

        print $/;
    }
}
#----------------------------------------------------------------------

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

    DEFINE => join(
        q< >,
        map { "-D$_" } @defines,
    ),

    LIBS => join(
        q< >,
        $libs,
        ( map { "-Wl,-rpath-link=$_" } @libdirs ),
    ),

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
