package Dancer2::Plugin::HTTP::Caching;

=head1 NAME

Dancer2::Plugin::HTTP::Caching - RFC 7234 compliant

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use warnings;
use strict;

use Carp;
use Dancer2::Plugin;

use HTTP::Date;

=head1 SYNOPSIS

Conditionally handling HTTP request based on eTag or Modification-Date,
according to RFC 7232

HTTP Conditional Requests are used for telling servers that they only have to
perform the method if the preconditions are met. Such requests are either used
by caches to (re)validate the cached response with the origin server - or -
to prevent lost-updates with unsafe-methods in a stateless api (like REST).

=head 1 RFC_7234 HTTP: Caching

Caching is a important mechanism that partially defines the whole HTTP protocol.

For caching there are three different parties involvded.

=over

=item client

the application that initiates the requests for a specific resource

=item origin server

the server that stores resources, creates them and retrieves them and sends of
the original representation of the resource, the response

=item cache

a service that sits between the client and the origin server that stores copies
of responses. There is much to do about cache and the RFC explains in great
detail how such must operate.

=back

Since this plugin is meant to be used in a Dancer App, it mostlikely will be the
origin server that this will run. Therfore, this plugin will only implement the
HTTP Cache-Control response header field as specified in Section 5.2 of the RFC
- plus the Epire header from Section 5.3.

Since it does not do any caching itself (not yet) it does not need to respond to
the various Cache-Control directives that can come in from the client (or any
other intermedium server)

The origin server should only know how to respond to conditional GET request,
that come from a cache, used to do validation of the cached data. Responding to
conditional requests is done in a seperate plugin,
Dancer2::Plugin::HTTP::ConditionalRequest which is follows the RFC 7232.

Maybe in a future release there might be a option to have a cache run inside the
Dancer app, but if one wants a cache in the origin server, one could simply use
plack middle ware that will implement it (Although there is not even one module
on CPAN that actually does it right)

=head1 Dancer2 Keywords

No further explenation is given, see the RFC itself.

=cut

=head2 http_cache_must_revalidate

see RFC 7234: ¤ 5.2.2.1.  must-revalidate

=cut

# RFC 7234: ¤ 5.2.2.1.  must-revalidate
register http_cache_must_revalidate => sub {
        shift->_append_cache_control_directive('must-revalidate' => @_);
    return;
};

=head2 http_cache_no_cache

see RFC 7234: ¤ 5.2.2.2.  no-cache

=cut

# RFC 7234: ¤ 5.2.2.2.  no-cache
register http_cache_no_cache => sub {
    shift->_append_cache_control_directive_quoted('no-cache' => @_);
    return;
};

=head2 http_cache_no_store

see RFC 7234: ¤ 5.2.2.3.  no-store

=cut

# RFC 7234: ¤ 5.2.2.3.  no-store
register http_cache_no_store => sub {
    shift->_append_cache_control_directive('no-store' => @_);
    return;
};

=head2 http_cache_no_transform

see RFC 7234: ¤ 5.2.2.4.  no-transform

=cut

# RFC 7234: ¤ 5.2.2.4.  no-transform
register http_cache_no_transform => sub {
    shift->_append_cache_control_directive('no-transform' => @_);
    return;
};

=head2 http_cache_public

see RFC 7234: ¤ 5.2.2.5.  public

=cut

# RFC 7234: ¤ 5.2.2.5.  public
register http_cache_public => sub {
    shift->_append_cache_control_directive('public' => @_);
    return;
};

=head2 http_cache_private

see RFC 7234: ¤ 5.2.2.6.  private

=cut

# RFC 7234: ¤ 5.2.2.6.  private
register http_cache_private => sub {
    shift->_append_cache_control_directive_quoted('private' => @_);
    return;
};

=head2 http_cache_proxy_revalidate

see RFC 7234: ¤ 5.2.2.7.  proxy-revalidate

=cut

# RFC 7234: ¤ 5.2.2.7.  proxy-revalidate
register http_cache_proxy_revalidate => sub {
    shift->_append_cache_control_directive('proxy-revalidate' => @_);
    return;
};

=head2 http_cache_max_age

see RFC 7234: ¤ 5.2.2.8.  max-age

takes a 'delta-seconds' integer

=cut

# RFC 7234: ¤ 5.2.2.8.  max-age
register http_cache_max_age => sub {
    shift->_append_cache_control_directive_seconds('max-age' => @_);
    return;
};

=head2 http_cache_s_maxage

see RFC 7234: ¤ 5.2.2.9.  max-age

takes a 'delta-seconds' integer

=cut

# RFC 7234: ¤ 5.2.2.9.  s-maxage
register http_cache_s_maxage => sub {
    shift->_append_cache_control_directive_seconds('s-maxage' => @_);
    return;
};

=head2 http_expire

This Keywords set one of the two HTTP response headers that are related to
caching. It takes a HTTP Date formatted string that will tell any caching server
that the stored respource should be refreshed after the specified date/time

See RFC 7234: ¤ 5.3

=cut

# RFC 7234: ¤ 5.3.      Expires
register http_expire => sub {
    $_[0]->log( warning =>
        "http_expire: missing date" )
        unless  $_[1];
    $_[0]->header('Expires' => $_[1]);
    return;
};

sub _append_cache_control {
    my $dsl         = shift;
    my $directive   = shift;
    my $value       = shift;
    
    $dsl->header('Cache-Control' =>
        join ', ',
            $dsl->header('Cache-Control'),
            ( defined $value ? join '=', $directive, $value : $directive)
    );
    return $dsl->header('Cache-Control')
};

sub _append_cache_control_directive {
    my $dsl         = shift;
    my $directive   = shift;
    
    $dsl->log( warning =>
        "http_cache_control: '$directive' does not take any parameters"
    ) if @_ ;
    
    return $dsl->_append_cache_control($directive, undef);
};

sub _append_cache_control_directive_seconds {
    my $dsl         = shift;
    my $directive   = shift;
    my $seconds     = shift || 0;
    
    $dsl->log( warning =>
        "http_cache_control: '$directive' does only take 'delta-seconds'"
    ) if @_ ;
    
    $dsl->log( error =>
        "http_cache_control: '$directive' requires number of seconds"
    ) unless $seconds =~ /\d+/ ;
    
    my $value = $seconds;
    return $dsl->_append_cache_control($directive, $value);
};

sub _append_cache_control_directive_quoted {
    my $dsl         = shift;
    my $directive   = shift;
    my @strings     = ref $_[0] eq 'ARRAY' ? @$_[0] : @_; 
#   my @strings     = @_; 
    
    my $value = @strings ? '"' . join(' ', @strings) . '"' : undef;
    return $dsl->_append_cache_control($directive, $value);
};



on_plugin_import {
    my $dsl = shift;
    my $app = $dsl->app;
};

register_plugin;

1;