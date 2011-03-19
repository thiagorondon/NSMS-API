#!/usr/bin/env perl

use Test::More tests => 5;

use FindBin qw($Bin);
use lib "$Bin/lib";
use NSMS::API;

my $sms = NSMS::API->new(
    username => 'sppm',
    password => 'sppm0808',
    debug    => 0
);

eval { $sms->to('asdfsfas') };
ok($@);
eval { $sms->to('+551193322332') };
ok($@);
eval { $sms->to('1188338833') };
is( $@, '' );
eval { $sms->text('teste de sms') };
is( $@, '' );
eval { $sms->text( 'x' x 150 ) };
ok($@);

