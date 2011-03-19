#!/usr/bin/env perl
use inc::Module::Install;

name 'NSMS-API';
version '0.01';

requires 'Moose';
requires 'Moose::Util::TypeConstraints';
requires 'Data::Dumper';
requires 'URI::Escape';
requires 'LWP::Simple';
requires 'JSON';

test_requires 'Test::More' => '0.88';

WriteAll;

