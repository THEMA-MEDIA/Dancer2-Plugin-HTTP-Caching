# Dancer2-Plugin-HTTP-Caching
A Plugin to set the HTTP-Expires header of the response or any of the Cache-Directives, like max-age

## RFC-7234: "Hypertext Transfer Protocol (HTTP/1.1): Caching"
That RFC describes a lot on how to store and respond with cached data. But basically, to make caching work it falls in two parts:

1) A origin server that SHOULD provide a expiration-date and or directives that tell the cache long it can hold the data. That is basically enough for web-server to do, sending off information about freshness.

2) A caching server that once in a while checks with the origin server what to do with it's cached-data, a process called validation. Validation is handled by conditional-requests using request headers like 'If-Modified-Since' and when not, the server SHOULD send a status of 304 (Not Modified).

Handling conditional requests by the server is beyond the scope of this caching plugin, and is not described as such in the RFC. For this to work, use the Dancer2::Plugin::HTTP-ConditionalRequest

## keywords

Only the first from the list below has it's own HTTP =response header field, all others, when used, will be appended to the HTTP Cache-Control response header field. Some of those take parameters.

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

See the RFC for a explanation of what these keywords would mean

## The Cache

I might or I might not implement a cache inside this plugin, using before/after hooks.

If I would, it would act like a proper implemented caching server. Store data after a GET (or other responses for different request methods), invalidate data when dealing with unsafe methods (like DELETE or PUT) and validate it's data when asked to do a GET if needed. And naturally, since I also wrote the Dancer2::Plugin::HTTP::ContentNegotiation, it will take the Vary response header filed in consideration.

However... caching could be handled at any other level in process or in the long path of the data being sent. It could be handled with dedicated software, or plugins for specific servers or with plack-middleware too

---
NB. Once more, i can not stress it enough, Date-Last-Modified and eTag are mechanisms for a conditional GET method for revalidating and have nothing to do with Cache-Control directives.
