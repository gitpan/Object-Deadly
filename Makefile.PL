use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Object::Deadly',
    AUTHOR        => 'Joshua ben Jore <jjore@cpan.org>',
    VERSION_FROM  => 'lib/Object/Deadly.pm',
    ABSTRACT_FROM => 'lib/Object/Deadly.pm',
    PREREQ_PM     => {
        'Test::Exception'   => 0,
        'Devel::Symdump'    => 0,
        'Devel::StackTrace' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Object-Deadly-*' },
);
