package Dancer2::Plugin::HTTP::Caching;

use warnings;
use strict;

use Carp;
use Dancer2::Plugin;

use HTTP::Date;

register http_expire => sub {
    $_[0]->log( warning =>
        "Missing date for HTTP Header-Field 'Expire'" )
        unless  $_[1];
    $_[0]->header('Expires' => $_[1]);
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