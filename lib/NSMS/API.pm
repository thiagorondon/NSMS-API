#!/usr/bin/perl

package NSMS::API;

use Moose;
use Moose::Util::TypeConstraints;
use Carp;
use Data::Dumper;

use URI::Escape;
use HTTP::Request::Common;
use HTTP::Response;
use LWP::UserAgent;
use JSON;

has ua => (
    is => 'rw',
    isa => 'Object',
    lazy => 1,
    default => sub { LWP::UserAgent->new }
);

has username => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

has password => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

has baseurl => (
    is      => 'rw',
    isa     => 'Str',
    default => 'http://api.nsms.com.br/api',
);

has debug => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0
);

subtype 'NSMS_Number' => as 'Str' => where { $_ =~ /^[0-9]{10}$/ } =>
  message { "The number you provider, $_, was not a mobile number" };

has to => (
    is  => 'rw',
    isa => 'NSMS_Number'
);

subtype 'NSMS_Message' => as 'Str' => where { length($_) < 140 } =>
  message { "The lenght of message has more then 140 chars." };

has text => (
    is  => 'rw',
    isa => 'NSMS_Message'
);

has url_auth => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        join( '/', $self->baseurl, 'auth', $self->username, $self->password );
    }
);

has url_sendsms => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        join( '/', $self->baseurl, 'get', 'json' ) 
          . '?to=55'
          . $self->to
          . '&content='
          . uri_escape( $self->text );

    }
);

has has_auth => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0
);

sub json_to_struct {
    my ($self, $ret) = @_;
    $ret = $ret->content if ref($ret) eq 'HTTP::Response';
    my $st   = decode_json($ret);
    print Dumper($st) if $self->debug;
    return $st;
}

sub auth {
    my $self = shift;
    warn $self->url_auth if $self->debug;
    my $content = $self->ua->get( $self->url_auth );
    my $ret     = $self->json_to_struct($content);
    return undef unless $ret->{sms}{ok};
    $self->has_auth(1);
    return $ret->{sms}{ok};
}

sub send {
    my ( $self, $to, $text ) = @_;
    $self->to($to)     if $to;
    $self->text($text) if $text;
    $self->auth unless $self->has_auth;
    warn $self->url_sendsms if $self->debug;
    my $content = $self->ua->get( $self->url_sendsms );
    my $ret     = $self->json_to_struct($content);
    return $ret->{sms}{ok} || undef;
}

1;

