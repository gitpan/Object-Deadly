use Test::Exception tests => 14;
use Object::Deadly;

lives_ok { Object::Deadly->new } '->DESTROY lives';

my $obj = Object::Deadly->new( 'XXX' );

dies_ok { $obj->new } '$obj->new dies';
dies_ok { $obj->AUTOLOAD } '$obj->AUTOLOAD dies';
dies_ok { $obj->isa( '...' ) } '$obj->isa( "..." ) dies';
dies_ok { $obj->can( '...' ) } '$obj->can( "..." ) dies';
dies_ok { $obj->VERSION } '$obj->VERSION dies';

dies_ok { "$obj" } 'Stringification is deadly';
dies_ok { 0+$obj } 'Numificiation is deadly';
dies_ok { !$obj } 'Boolification is deadly';

for my $sigil (qw( $ @ % & * )) {
    eval "dies_ok { $sigil\$obj } '$sigil\$obj is deadly';";
    die $@ if $@;
}

