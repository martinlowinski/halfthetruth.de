---
layout: post
title: "Nginx Maintenance Page"
slug: nginx-maintenance-page
date: 2012-07-08 13:45 +01:00
author: Martin Lowinski
comments: true
published: true
categories: Website
tags: 
  - nginx
---

I had to move all websites from the old host to the new one during this week. For the sites that I had already moved, I changed the DNS records accordingly. But what if someone (browser, router, ...) has the record cached? This would mean the old host gets the connection, the webserver does its thing and the database is altered. It is generally not a bad thing because one could synchronize the databases with the new host. Most of the time this is not an easy task and one problem stays the same: When has everyone purged the record from their cache and you can finish the migration?

This is where a maintenance page is very useful. One can migrate the website to the new host, set up the DNS records and place a maintenance page (with a meaningful message) for this website on the old host.

There is a nice way to do this with nginx. The following code checks for the file `down.html` in the root of your website. Note: All my websites are located in `/var/www/servers/$server_name/htdocs`, so you might wanna change that to your needs. If this file exists, all requests are rewritten and return this page with a `503` status code. If you remove `down.html` everything is back to normal.

{% highlight bash %}
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
}
{% endhighlight %}

This is nice but when you have a bunch of websites, this becomes a mess. For that I wrote a very basic script to enable (`-a /path/to/maintenance.html`) and disable (`-r`) the maintenance mode for each website (`-s vhost`).

{% highlight bash %}
#!/bin/bash

SERVERS=/var/www/servers

function usage() {
  echo "Usage: `basename $0` options (-a /path/to/maintenance-site) (-r) (-s vhost) -h for help";
  exit $E_OPTERROR;
}

if ( ! getopts "a:rs:h" opt); then
  usage
fi

while getopts "a:rs:" opt; do
  case "$opt" in
    "a")
      #echo "Option -$opt is specified: $OPTARG"
      ADD=true
      MAINTSITE=$OPTARG
      ;;
    "r")
      #echo "Option -$opt is specified: $OPTARG"
      ADD=false
      ;;
    "s")
      #echo "Option -$opt is specified: $OPTARG"
      VHOST=$OPTARG
      ;;
    ":")
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    "?")
      echo "Unknown option $OPTARG." >&2
      exit 1
      ;;
    *)
      # Should not occur
      echo "Unknown error while processing options." >&2
      exit 1
      ;;
  esac
done

if $ADD
then
  echo "Enabling maintenance mode for $VHOST..."
  ln -s $MAINTSITE $SERVERS/$VHOST/down.html
else
  echo "Disabling maintenance mode for $VHOST..."
  rm -v $SERVERS/$VHOST/down.html
fi
{% endhighlight %}
