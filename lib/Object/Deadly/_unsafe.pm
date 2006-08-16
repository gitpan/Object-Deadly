## no critic (Version,PodSections,Warnings)
package Object::Deadly::_unsafe;

use strict;

require overload;
my $death = Object::Deadly->get_death;
overload->import(
    map { $_ => $death }
        map { split ' ' }    ## no critic EmptyQuotes
        values %overload::ops    ## no critic PackageVars
);

# Kill off all UNIVERSAL things and try it at several points during
# execution just in case someone added something along the way.
Object::Deadly->kill_UNIVERSAL;
CHECK { Object::Deadly->kill_UNIVERSAL; }
INIT  { Object::Deadly->kill_UNIVERSAL; }
END   { Object::Deadly->kill_UNIVERSAL; }

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

=item C<< $obj->isa >>

=item C<< $obj->can >>

=item C<< $obj->version >>

=item C<< $obj->DOES >>

=item C<< $obj->import >>

=item C<< $obj->require >>

=item C<< $obj->use >>

=item C<< $obj->blessed >>

=item C<< $obj->dump >>

=item C<< $obj->peek >>

=item C<< $obj->refaddr >>

=item C<< $obj->exports >>

=item C<< $obj->moniker >>

=item C<< $obj->plural_moniker >>

=item C<< $obj->which >>

=item C<< $obj->AUTOLOAD >>

Each of AUTOLOAD, a named list of known UNIVERSAL functions and then a
query for everything currently known are all implemented with C<<
Object::Deadly->get_death >> to prevent anything from sneaking through
to a successful call against something in UNIVERSAL.

That list of functions are what core perl uses plus a bunch from CPAN
modules including L<UNIVERSAL>, L<UNIVERSAL::require>,
L<UNIVERSAL::dump>, L<UNIVERSAL::exports>, L<UNIVERSAL::moniker>,
L<UNIVERSAL::which>. That's just the list as it exists today. If
someone else creates a new one and you load it, be sure to do it
*prior* to loading this module so I can have at least a chance at
noticing anything it's loaded.

=back

=head1 SEE ALSO

L<Object::Deadly>, L<Object::Deadly::_safe>

=cut

1;
