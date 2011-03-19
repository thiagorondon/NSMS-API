#!/usr/bin/env perl


use FindBin qw($Bin);
use lib "$Bin/lib";
use NSMS::API;

my $sms = NSMS::API->new(
   username => 'user',
   password => 'pass',
   debug => 0
);

$sms->to('1183329923');
$sms->text('teste de sms');
print $sms->send;

