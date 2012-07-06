---
layout: post
title: "Nginx Maintenance Page"
slug: nginx-maintenance-page
date: 2012-07-06 18:59 +01:00
author: Martin Lowinski
comments: true
published: false
categories: 
tags: 
  - nginx
---

{% highlight nginx %}
server {
  # Maintenance
  if (-f /var/www/servers/$server_name/down.html) {
    return 503;
  }
  error_page 503 @maintenance;
  location @maintenance {
    root   /var/www/servers/$server_name;
    rewrite ^(.*)$ /down.html break;
}
{% endhighlight %}

{% highlight bash %}
$> ln -s maintenance/down.html $server_name/.
{% endhighlight %}
