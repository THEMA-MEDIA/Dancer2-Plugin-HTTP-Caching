package Dancer2::Plugin::HTTP::Caching;

use warnings;
use strict;

use Carp;
use Dancer2::Plugin;

use HTTP::Date;

register http_cache_expires => sub {
    my $dsl         = shift;
    my $arg         = shift; # HTTP Date formatted string
    
    carp "Missing date for HTTP Header-Field 'Expire'"
        unless $arg;
    
    $dsl->header('Expires' => $arg);
    
    return;
};

1;