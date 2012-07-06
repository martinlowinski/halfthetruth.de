---
layout: post
title: "Nginx with IPv6/Dual stack"
slug: nginx-with-ipv6-dual-stack
date: 2012-07-06 14:29 +01:00
author: Martin Lowinski
comments: true
published: true
categories: 
tags:
  - nginx
  - ipv6
---

The new virtual host serving you this website is now capable of IPv6, which is great. In the days where IPv4 addresses are rare and also not very cheap (>15€ per month for more than 4 addresses), it's good to have a /64 IPv6 subnet. `2^64` addresses is way to much but well.. it is for free.

Nginx is my webserver of choice right now and I want to enable IPv6 in dual stack mode. My first naive approach was to just uncomment the `listen [::]:80` directive for all servers and that's it. I was wrong, this is the result:

{% highlight bash %}
Starting nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
configuration file /etc/nginx/nginx.conf test is successful
[emerg]: bind() to [::]:80 failed (98: Address already in use)
[emerg]: bind() to [::]:80 failed (98: Address already in use)
[emerg]: bind() to [::]:80 failed (98: Address already in use)
[emerg]: bind() to [::]:80 failed (98: Address already in use)
[emerg]: bind() to [::]:80 failed (98: Address already in use)
[emerg]: still could not bind()
{% endhighlight %}

The point here is, that if `net.ipv6.bindv6only` (in `/etc/sysctl.conf`) is disabled - which it is by default - nginx listens in dual stack mode. And as we have the directive `listen 80` in our configuration as well, it crashes.

There are two solutions to this: Disable `listen 80` for every server or change `ipv6only` to `1`.

### Replace all `listen 80` with `listen [::]:80` ###

{% highlight nginx %}
server {
# listen   80; ## listen for ipv4
  listen   [::]:80; ## listen for ipv6
}
{% endhighlight %}

{% highlight bash %}
$> netstat -nlp | grep nginx
tcp6  0   0 :::80     :::*    LISTEN   8960/nginx
tcp6  0   0 :::443    :::*    LISTEN   8960/nginx
{% endhighlight %}

No tcp (IPv4) listen directives for nginx. Despite that, the sockets are configured to accept both IPv4 and IPv6 connections via `in6addr_any`.

### Enable `ipv6only` ###

To explicitly create to sockets for each protocol, you'd have to to configure nginx the following way:

{% highlight nginx %}
server {
  listen 80;
  listen [::]:80 ipv6only=on;
}
{% endhighlight %}

The default on Linux is disabled ipv6only. So you have to enable it manually with `sysctl -w net.ipv6.bindv6only="1"` or put the following into `/etc/sysctl.conf` and reboot.

{% highlight nginx %}
net.ipv6.bindv6only = 1
{% endhighlight %}

