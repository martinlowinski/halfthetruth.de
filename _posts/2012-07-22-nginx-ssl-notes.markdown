---
layout: post
title: "Nginx SSL notes"
slug: nginx-ssl-notes
date: 2012-07-22 14:38
author: Martin Lowinski
comments: true
published: false
categories: 
tags: 
  - nginx
  - ssl
---

Create chain of ceritificates
cat example.com.pem sub.class1.server.ca.pem ca.pem > /etc/nginx/ssl/example.com_chain.pem

Nginx:
server {
    listen 443;
    ssl_certificate /etc/nginx/ssl/example.com_chain.pem;
    ssl_certificate_key /etc/nginx/ssl/example.com.key;
    ...
}

List available ciphers:
openssl ciphers
Cipher list format explained: http://openssl.org/docs/apps/ciphers.html

nginx ciphers default:
ssl_ciphers   HIGH:!aNULL:!MD5;
source: http://wiki.nginx.org/HttpSslModule#ssl_ciphers

## Check for Ausgehandelter chipher ##
openssl s_client -host halfthetruth.de -port 443
With SNI:
openssl s_client -host halfthetruth.de -port 443 -servername halfthetruth.de

## Comparison ##
openssl s_client -host google.com -port 443 
New, TLSv1/SSLv3, Cipher is ECDHE-RSA-RC4-SHA

openssl s_client -host facebook.com -port 443
New, TLSv1/SSLv3, Cipher is AES128-SHA

openssl s_client -host news.ycombinator.com -port 443
New, TLSv1/SSLv3, Cipher is DHE-RSA-AES256-SHA

openssl s_client -host twitter.com -port 443
New, TLSv1/SSLv3, Cipher is RC4-SHA

## kEDH ##
kEDH is expensive


## Session caching ##

http://auxbuss.com/blog/posts/2011_06_28_ssl_session_caching_on_nginx/
gnutls-cli -V -r HOSTNAME |grep 'Session ID'

## HTTP Strict Transport Security ##

the draft: http://tools.ietf.org/html/draft-ietf-websec-strict-transport-sec-11

Nginx:
# Remember this setting for 365 days
add_header Strict-Transport-Security max-age=31536000;
add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";

### X-Frame-Options ###

No frames

add_header X-Frame-Options DENY;
