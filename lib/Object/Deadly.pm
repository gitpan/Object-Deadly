## no critic (PodSections,PodAtEnd,UseWarnings,RcsKeywords)
package Object::Deadly;

use strict;
require Devel::Symdump;

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
    eval 'use Carp::Clan 5.4;';    ## no critic StringyEval
    if ( not defined &confess ) {
        require autouse;
        autouse->import( Carp => 'confess' );
    }
}

# XXX use Carp::Clan once the infinite loop/hang is resolved.
use autouse 'Carp' => 'confess';

=head1 NAME

Object::Deadly - An object that dies whenever examined

=head1 VERSION

Version 0.04

=cut

use vars '$VERSION';    ## no critic Interpolation
$VERSION = '0.04';

=head1 SYNOPSIS

This object is meant to be used in testing. All possible overloading
and method calls die. You can pass this object into methods which are
not supposed to accidentally trigger any potentially overloading.

  use Object::Deadly;
  
  my $foo = Object::Deadly->new;
  print $foo; # dies  

=head1 METHODS

=over

=item C<< Object::Deadly->new() >>

=item C<< Object::Deadly->new( MESSAGE ) >>

The class method C<< Object::Deadly->new >> returns an C<< Object::Deadly >>
object. Dies with a stack trace and a message when evaluated in any
context. The default message contains a stack trace from where the
object is created.

=cut

use overload ();    # Load it
use overload(
    map { $_ => \&_death }
        map { split ' ' }    ## no critic EmptyQuotes
        values %overload::ops    ## no critic PackageVars
);

sub new {
    my $class = shift @_;
    my $data;
    if (@_) {
        $data = shift @_;
    }
    else {
        require Devel::StackTrace;

        # XXX Allow users to influence this object.
        $data = Devel::StackTrace->new( ignore_package => 'Object::Deadly' )
            ->as_string;
        $data =~ s/\AT/Object::Deadly t/xm;

    }
    return bless \$data, $class;
}

=back

=head1 PRIVATE FUNCTIONS

The following functions are all private and not meant for public
consumption.

=over

=item C<< _death( $obj ) >>

=cut

sub _death {    ## no critic RequireFinalReturn
    my $self = shift @_;

    # Fetch the message in the object.
    my $class = ref $self;
    bless $self, 'Object::Deadly::NotDeadly';
    my $message = $$self;    ## no critic DoubleSigils
    bless $self, $class;

    confess "[[[[ $message ]]]]";
}

=item C<< $obj->DESTROY >>

The DESTROY method doesn't die. This is defined so it won't be
AUTOLOADed or fetched from UNIVERSAL.

=cut

sub DESTROY {

    # Don't let AUTOLOAD see this. I'd die all the time otherwise.
}

=item C<< $obj->AUTOLOAD >>

=item C<< $obj->UNIVERSAL::* >>

Each of AUTOLOAD and all functions available through UNIVERSAL are all
defined so they won't be looked up in the UNIVERSAL package.

=cut

{
    no warnings 'once';    ## no critic NoWarnings
    *AUTOLOAD = \&_death;
}

for my $function ( Devel::Symdump->rnew('UNIVERSAL')->functions ) {
    $function =~ s/\AUNIVERSAL:://mx;
    no strict 'refs';      ## no critic NoStrict
    *$function = \&_death; ## no critic DoubleSigils
}

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

=head1 COPYRIGHT & LICENSE

Copyright 2006 Joshua ben Jore, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

## no critic (EndWithOne)
'For the SAKE... of the FUTURE of ALL... mankind... I WILL have
a... SMALL sprite!';
