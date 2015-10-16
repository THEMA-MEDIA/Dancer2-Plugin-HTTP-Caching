# Dancer2-Plugin-HTTP-Caching
A Plugin to set the HTTP-Expires header of the response or any of the Cache-Directives, like max-age

## RFC-7234: "Hypertext Transfer Protocol (HTTP/1.1): Caching"
That RFC describes a lot on how to store and respond with cached data. But basicly, to make caching work it falls in two parts:

1) A origing server that SHOULD provide a expiration-date and or directives that tell the cache long it can hold the data. That is basicly enough for web-server to do, sending off information about freshness.

2) A caching server that once in a while checks with the origin server what to do with it's cached-data, a process called validation. Validation is handled by conditional-requests using request headers like 'If-Modified-Since' and when not, the server SHOULD send a status of 304 (Not Modified).

Handling conditional requests by the server is beyond the scope of this caching plugin, and is not described as such in the RFC. For this to work, use the Dancer2::Plugin::HTTP-ConditionalRequest

## keywords

Only the first from the list below has it's own HTTP =response header field, all others, when used, will be appended to the HTTP Cache-Control response header field. Some of those take paramteres.

### http_cache_expire

### http_cache_must_revalidate

### http_cache_max_age

### http_cache_no_cache

### http_cache_no_store

### http_cache_no_transform

### http_cache_public

### http_cache_private

### http_cache_proxy_revalidate

### http_cache_max_age

### http_cache_s_max_age

See the RFC for a explenation of what these kewords would mean

---
NB. Once more, i can not stress it enough, Date-Last-Modified and eTag are mechanisms for a conditional GET method for revalidating and have nothing to do with Cache-Control directives.
