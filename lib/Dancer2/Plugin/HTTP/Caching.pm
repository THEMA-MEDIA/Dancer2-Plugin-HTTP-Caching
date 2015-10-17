package Dancer2::Plugin::HTTP::Caching;

use warnings;
use strict;

use Carp;
use Dancer2::Plugin;

use HTTP::Date;

register http_expire => sub {
    my $dsl         = shift;
    my $arg         = shift; # HTTP Date formatted string
    
    carp "Missing date for HTTP Header-Field 'Expire'"
        unless $arg;
    
    $dsl->header('Expires' => $arg);
    
    return;
};

on_plugin_import {
    my $dsl = shift;
    my $app = $dsl->app;
};

register_plugin;

1;