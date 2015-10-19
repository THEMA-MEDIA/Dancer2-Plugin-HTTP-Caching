package Dancer2::Plugin::HTTP::Caching;

use warnings;
use strict;

use Carp;
use Dancer2::Plugin;

use HTTP::Date;

# RFC 7234: ¤ 5.3.      Expires
register http_expire => sub {
    $_[0]->log( warning =>
        "http_expire: missing date" )
        unless  $_[1];
    $_[0]->header('Expires' => $_[1]);
    return;
};

# RFC 7234: ¤ 5.2.2.1.  must-revalidate
register http_cache_must_revalidate => sub {
        shift->_append_cache_control_directive('must-revalidate' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.2.  no-cache
register http_cache_no_cache => sub {
    shift->_append_cache_control_directive_quoted('no-cache' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.3.  no-store
register http_cache_no_store => sub {
    shift->_append_cache_control_directive('no-store' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.4.  no-transform
register http_cache_no_transform => sub {
    shift->_append_cache_control_directive('no-transform' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.5.  public
register http_cache_public => sub {
    shift->_append_cache_control_directive('public' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.6.  private
register http_cache_private => sub {
    shift->_append_cache_control_directive_quoted('private' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.7.  proxy-revalidate
register http_cache_proxy_revalidate => sub {
    shift->_append_cache_control_directive('proxy-revalidate' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.8.  max-age
register http_cache_max_age => sub {
    shift->_append_cache_control_directive_seconds('max-age' => @_);
    return;
};

# RFC 7234: ¤ 5.2.2.9.  s-maxage
register http_cache_s_maxage => sub {
    shift->_append_cache_control_directive_seconds('s-maxage' => @_);
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