## no critic (Version,PodSections,Warnings)
package Object::Deadly::_unsafe;

# $Revision$
# $Source$
# $Date$

use strict;

require overload;
my $death = Object::Deadly->get_death;
overload->import(
    map { $_ => $death }
        map { split ' ' }    ## no critic EmptyQuotes
        values %overload::ops    ## no critic PackageVars
);
Object::Deadly->kill_UNIVERSAL;
Object::Deadly->kill_function('AUTOLOAD');

sub DESTROY { }

1;

__END__

=head1 NAME

Object::Deadly::_unsafe - Implementation for the deadly object

=head1 METHODS

=over

=item C<< $obj->DESTROY >>

The DESTROY method doesn't die. This is defined so it won't be
AUTOLOADed or fetched from UNIVERSAL.

=item C<< $obj->import >>

=item C<< $obj->isa >>

=item C<< $obj->can >>

=item C<< $obj->VERSION >>

=item C<< $obj->DOES >>

=item C<< $obj->require >>

=item C<< anything in UNIVERSAL:: >>

=item C<< $obj->AUTOLOAD >>

Each of AUTOLOAD, a named list of known UNIVERSAL functions and then a
query for everything currently known are all implemented with C<<
Object::Deadly->get_death >> to prevent anything from sneaking through
to a successful call against something in UNIVERSAL.

=back

=head1 SEE ALSO

L<Object::Deadly>, L<Object::Deadly::_safe>

=cut

1;
