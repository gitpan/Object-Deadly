#!perl
use Test::More;

if ( not $ENV{AUTHOR_TESTS} ) {
    plan skip_all => 'Skipping author tests';
}
else {
    plan tests => 1;
    require Test::Signature;
    Test::Signature->import;
    signature_ok();
}
