---
layout: post
title: "Nginx SSL notes"
slug: nginx-ssl-notes
date: 2012-07-31 17:59 +01:00
author: Martin Lowinski
comments: true
published: true
categories: Website
tags: 
  - nginx
  - ssl
---

Here are some (useful) notes about SSL and security with Nginx. This is just a collection of tips, nothing more...

## A SSL cert ##

For certificates for this and also other hosts, I signed up for [StartSSL](http://www.startssl.com/). In contrast to other providers, they offer a free SSL certificate for one domain plus subdomain. Before that, I had certs from [CaCert](http://cacert.org) which is also nice, but the root certificate is missing in all major browsers.

I won't describe the actual process of how to get a certificate from StartSSL because the may change it over time. This is just about how Nginx works with SSL.

So now you have a certificate from $provider. For Nginx you have to create a chain with your private key, your certificate and the StartSSL cert, in that order. Because of this special format, I store all certificates Nginx is using in `/etc/nginx/ssl`.

{% highlight bash %}
$> cat example.com.key sub.class1.server.ca.pem example.com.pem > /etc/nginx/ssl/example.com.pem
{% endhighlight %}

If you've done that, configuring Nginx to use it is fairly simple:

{% highlight nginx %}
server {
    listen 443;
    ssl_certificate /etc/nginx/ssl/example.com.pem;
    ssl_certificate_key /etc/nginx/ssl/example.com.key;
}
{% endhighlight %}

## Ciphers ##

HTTPS is ready to go, but which ciphers are actually used? Nginx has the following default rules (Taken from [http://wiki.nginx.org/HttpSslModule#ssl_ciphers](http://wiki.nginx.org/HttpSslModule#ssl_ciphers)):

{% highlight nginx %}
ssl_ciphers   HIGH:!aNULL:!MD5;
{% endhighlight %}

List available ciphers:
{% highlight bash %}
$> openssl ciphers
{% endhighlight %}
Cipher list format explained: http://openssl.org/docs/apps/ciphers.html

### Check for negotiated chipher ###

If you'd like to see which cipher is negotiated between you and your host, openssl has a very nice way to do that. Just run

{% highlight bash %}
openssl s_client -host example.com -port 443
{% endhighlight %}

or, when you need to specify a hostname for SNI for example, run

{% highlight bash %}
openssl s_client -host example.com -port 443 -servername example.com
{% endhighlight %}

### Comparison ###

Okay, so now we know which cipher is usually negotiated. But how are the "others" doing?

{% highlight bash %}
$> openssl s_client -host google.com -port 443 
New, TLSv1/SSLv3, Cipher is ECDHE-RSA-RC4-SHA
$> openssl s_client -host facebook.com -port 443
New, TLSv1/SSLv3, Cipher is AES128-SHA
$> openssl s_client -host news.ycombinator.com -port 443
New, TLSv1/SSLv3, Cipher is DHE-RSA-AES256-SHA
$> openssl s_client -host twitter.com -port 443
New, TLSv1/SSLv3, Cipher is RC4-SHA
{% endhighlight %}

As one could see, different (default) cyphers are used for different reasons. It is always a tradeoff between performance and security.

The cypher `kEDH` for example is known as a rather expensive one and many people disable it for this very reason. In some cases this would actually make sense, when you have to deal with lots of new connections and the host is at its limits.

## Session Caching ##

Sessions (since SSLv2) allow to create connections with encryption keys based on the same key data. Once the (complete) negotiation was successful, further connections within the same session can use this data to calculate the encryption keys.

Nginx supports this:

{% highlight nginx %}
# Shared cache of 10MB
ssl_session_cache    shared:SSL:10m;
# Default timeout is 5m
ssl_session_timeout  10m;
{% endhighlight %}

## HTTP Strict Transport Security ##

HSTS ([draft](http://tools.ietf.org/html/draft-ietf-websec-strict-transport-sec-11)) is something like a permanent redirect to HTTPS: Once a user visits a website via HTTPS and receives a HSTS header, it declares itself that this site is only accessible over a secure connection. The next time, the user wants to access the site via HTTP, the browser automatically switchs to HTTP (unless the HSTS preference hasn't expired). It only works with HTTPS, it is not allowed to send this header over HTTP.

Nginx configuration:

{% highlight nginx %}
# The browser should remember this preference for 1 year
add_header Strict-Transport-Security max-age=31536000;
# If you'd like to include subdomains:
add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";
{% endhighlight %}

## X-Frame-Options ##

This header specifies how a site can be used in a frame. This is also a [draft](https://tools.ietf.org/html/draft-ietf-websec-x-frame-options-00) and should help against Clickjacking.

{% highlight nginx %}
# If not otherwise specified
add_header X-Frame-Options ALLOW;
# Sameorigin-policy
add_header X-Frame-Options SAMEORIGIN;
# Never allow
add_header X-Frame-Options DENY;
{% endhighlight %}
