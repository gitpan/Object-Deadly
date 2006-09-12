## no critic (PodSections,UseWarnings,RcsKeywords)
package Object::Deadly;

use strict;

use Devel::Symdump ();

BEGIN {

    # Fetch either Carp::Clan::confess or autoload
    # Carp::confess. Carp::Clan has a bug in 5.3 and earlier that
    # prevents it from handling overloaded objects in the call
    # stack. The ticket
    # http://rt.cpan.org//Ticket/Display.html?id=21002 proposes a fix
    # to Carp::Clan.
    #
    # Also, this happens in BEGIN because I want confess() to exist by
    # the time the parser sees the call to it farther down below.

    eval 'use Carp::Clan 5.4;';    ## no critic
    if ( not defined &confess ) {
        require autouse;
        autouse->import( Carp => 'confess' );
    }
}

use vars '$VERSION';               ## no critic Interpolation
$VERSION = '0.07';

sub new {

    # Public, overridable class method. Returns an _unsafe object.

    my $class                = shift @_;
    my $implementation_class = "$class\::_unsafe";

    my $data;
    if (@_) {
        $data = shift @_;
    }
    else {

        # No sense in loading this unless we actually use it.
        require Devel::StackTrace;

        $data = Devel::StackTrace->new( ignore_package => $class )->as_string;
        $data =~ s/\AT/Object::Deadly t/xm;

    }

    return bless \$data, $implementation_class;
}

sub kill_function {

    # Public, overridable class method. Creates a deadly function in
    # the _unsafe class.

    my ( $class, $func, $death ) = @_;
    my $implementation_class = "$class\::_unsafe";
    my $function_name        = "$implementation_class\::$func";
    no strict 'refs';    ## no critic Strict

    if ( defined &$function_name ) {    ## no critic
        return;
    }
    elsif ( defined $death ) {
        *$function_name = $death;       ## no critic
        return 1;
    }
    else {
        *$function_name = $class->get_death;    ## no critic
        return 1;
    }
}

sub kill_UNIVERSAL {

    # Public, overridable method call. Creates deadly functions to
    # mask all UNIVERSAL methods.

    my $class = shift @_;
    for my $fqf_function (

        # core perl
        'isa',
        'can',
        'VERSION',

        # core perl 5.9.3+
        'DOES',

        # UNIVERSAL.pm
        'import',

        # UNIVERSAL/require.pm
        'require',
        'use',

        # UNIVERSAL/dump.pm
        'blessed',
        'dump',
        'peek',
        'refaddr',

        # UNIVERSAL/exports.pm
        'exports',

        # UNIVERSAL/moniker.pm
        'moniker',
        'plural_moniker',

        # UNIVERSAL/which.pm
        'which',

        # Anything else we happen to find
        Devel::Symdump->rnew('UNIVERSAL')->functions
        )
    {
        my $function = $fqf_function;
        $function =~ s/\AUNIVERSAL:://mx;

        $class->kill_function($function);
    }

    return 1;
}

sub get_death {

    # Public, overridable method call. Returns the _death function
    my $class = shift @_;
    no strict 'refs';    ## no critic Strict
    return \&_death;
}

sub _death {             ## no critic RequireFinalReturn
                         # The common death
    my $self = shift @_;

    # Fetch the message in the object by switching the object into
    # something that's safe.
    my $unsafe_implementation_class = ref $self;
    my $safe_implementation_class   = $unsafe_implementation_class;
    $safe_implementation_class =~ s/\::_unsafe\z/::_safe/mx;

    bless $self, $safe_implementation_class;
    my $message = $$self;    ## no critic DoubleSigils
    bless $self, $unsafe_implementation_class;

    confess "[[[[ $message ]]]]";
}

# Compile and load our implementing classes. Don't use use() because
# that'll call ->import.
use Object::Deadly::_safe   ();
use Object::Deadly::_unsafe ();

## no critic (EndWithOne)
'For the SAKE... of the FUTURE of ALL... mankind... I WILL have
a... SMALL sprite!';

__END__

=head1 NAME

Object::Deadly - An object that dies whenever examined

=head1 SYNOPSIS

  use Object::Deadly;
  use Test::Exception 'lives_ok';
  
  # Test that a few functions inspect their parameters safely
  lives_ok { some_function( Object::Deadly->new ) } 'some_function';
  lives_ok { Dumper( Object::Deadly->new ) } 'Data::Dumper';

=head1 DESCRIPTION

This object is meant to be used in testing. All possible overloading
and method calls die. You can pass this object into methods which are
not supposed to accidentally trigger any potentially overloading.

This problem arose when testing L<Data::Dump::Streamer> and
L<Carp>. The former was triggering overloaded object methods instead
of just dumping their data. L<Data::Dump::Streamer> is now safe for
overloaded objects but it wouldn't have been unless it hadn't have
been tested with a deadly, overloaded object.

=head1 DEALING WITH DEATH

TODO

=head1 METHODS

=over

=item C<< Object::Deadly->new() >>

=item C<< Object::Deadly->new( MESSAGE ) >>

The class method C<< Object::Deadly->new >> returns an C<< Object::Deadly >>
object. Dies with a stack trace and a message when evaluated in any
context. The default message contains a stack trace from where the
object is created.

=item C<< Object::Deadly->kill_function( FUNCTION NAME ) >>

=item C<< Object::Deadly->kill_function( FUNCTION NAME, DEATH CODE REF ) >>

The class method kill_function accepts a function name like C<< isa >>,
C<< can >>, or similar and creates a function in the
C<< Object::Deadly::_unsafe >> class of the same name.

An optional second argument is a code reference to die with. This
defaults to C<< Object::Deadly->can( '_death' ) >>.

=item C<< Object::Deadly->kill_UNIVERSAL >>

This class method kills all currently known UNIVERSAL functions so
they can't be called on a C<< Object::Deadly >> object. This includes
a list of methods known to the author and then an inspection of
UNIVERSAL::.

=item C<< Object::Deadly->get_death >>

Returns the function C<< Object::Deadly::_death >>.

=back

=head1 PRIVATE FUNCTIONS

The following functions are all private and not meant for public
consumption.

=over

=item C<< _death( $obj ) >>

This function temporarilly reblesses the object into
C<< Object::Deadly::_safe >>, extracts the message from inside of it,
and C<< confess >>'s with it. If possible this will be
L<Carp::Clan>::confess.

=back

=head1 AUTHOR

Joshua ben Jore, C<< <jjore at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<< bug-object-deadly at
rt.cpan.org >>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Object-Deadly>. I
will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

  perldoc Object::Deadly

You can also look for information at:

=over

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Object-Deadly>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Object-Deadly>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Object-Deadly>

=item * Search CPAN

L<http://search.cpan.org/dist/Object-Deadly>

=back

=head1 ACKNOWLEDGEMENTS

Yves Orton and Yitzchak Scott-Thoennes.

=head1 COPYRIGHT & LICENSE

Copyright 2006 Joshua ben Jore, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
