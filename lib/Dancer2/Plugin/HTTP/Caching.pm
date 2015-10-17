package Dancer2::Plugin::HTTP::Caching;

use warnings;
use strict;

use Carp;
use Dancer2::Plugin;

use HTTP::Date;

# RFC 7234: ¤ 5.3.      Expires
register http_expire => sub {
    $_[0]->log( warning =>
        "Missing date for HTTP Header-Field 'Expire'" )
        unless  $_[1];
    $_[0]->header('Expires' => $_[1]);
    return;
};

# RFC 7234: ¤ 5.2.2.1.  must-revalidate
register http_cache_must_revalidate => sub {
    _append_cache_control('must-revalidate' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.2.  no-cache
register http_cache_no_cache => sub {
    $_[0]->log( warning =>
        "Cache-Control Directive 'no-cache' does not support fields (yet)" )
        if defined $_[1];
    _append_cache_control('no-cache' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.3.  no-store
register http_cache_no_store => sub {
    _append_cache_control('no-store' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.4.  no-transform
register http_cache_no_transform => sub {
    _append_cache_control('no-transform' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.5.  public
register http_cache_public => sub {
    _append_cache_control('public' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.6.  private
register http_cache_private => sub {
    $_[0]->log( warning =>
        "Cache-Control Directive 'private' does not support fields (yet)" )
        if defined $_[1];
    _append_cache_control('private' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.7.  proxy-revalidate
register http_cache_proxy_revalidate => sub {
    _append_cache_control('proxy-revalidate' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.8.  max-age
register http_cache_max_age => sub {
    $_[0]->log( warning =>
        "Cache-Control Directive 'max-age' missing delta-seconds" )
        unless defined $_[1];
    _append_cache_control('max-age' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.9.  s-maxage
register http_cache_s_maxage => sub {
    $_[0]->log( warning =>
        "Cache-Control Directive 's-maxage' missing delta-seconds" )
        unless defined $_[1];
    _append_cache_control('s-maxage' => @_);
    return;
};

sub _append_cache_control {
    my $directive   = shift;
    my $dsl         = shift;
    my $value       = shift;
    
    $dsl->header('Cache-Control' =>
        join ', ',
            $dsl->header('Cache-Control'),
            ( defined $value ? join '=', $directive, $value : $directive)
    );
    return $dsl->header('Cache-Control')
;}

on_plugin_import {
    my $dsl = shift;
    my $app = $dsl->app;
};

register_plugin;

1;