use strict;
use ExtUtils::MakeMaker;

my %prerequisites;

print <<"END_NOTE";

Carp::Clan 5.4+ allows the stack traces to ignore Object::Deadly so
you get cleaner output. The 5.4+ version might not be on CPAN but is
accessible by applying the patch at
http://rt.cpan.org//Ticket/Display.html?id=21002.

END_NOTE
if (prompt(
        'Do you wish to add Carp::Clan 5.4+ to the list of prerequisites?',
        'y' ) =~ /y/i
    )
{
    $prerequisites{'Carp::Clan'} = '5.4';
}

WriteMakefile(
    NAME          => 'Object::Deadly',
    AUTHOR        => 'Joshua ben Jore <jjore@cpan.org>',
    VERSION_FROM  => 'lib/Object/Deadly.pm',
    ABSTRACT_FROM => 'lib/Object/Deadly.pm',
    PREREQ_PM     => {
        'Test::Exception'   => 0,
        'Devel::Symdump'    => 0,
        'Devel::StackTrace' => 0,
        %prerequisites,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Object-Deadly-*' },
);
