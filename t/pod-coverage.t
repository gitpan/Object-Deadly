#!perl -T

use Test::More tests => 1;
use Devel::Symdump;
eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage"
    if $@;

pod_coverage_ok(
    'Object::Deadly',
    {   trustme => [
            map {qr/\A\Q$_/}
                map { /\AUNIVERSAL::(.+)/xms ? $1 : $_ }
                Devel::Symdump->rnew('UNIVERSAL')->functions
        ]
    }
);
