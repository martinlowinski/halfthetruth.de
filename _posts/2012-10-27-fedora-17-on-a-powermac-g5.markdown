---
layout: post
title: "Fedora 17 on a PowerMac G5"
slug: fedora-17-on-a-powermac-g5
date: 2012-10-27 18:59
author: Martin Lowinski
comments: true
published: true
categories: Uncategorized
tags: 
  - powerpc
  - nvidia
  - linux
  - fedora
---

Besides my MacBook Pro, I got an old PowerMac G5 which should become my desktop. MacOS 10.5 was installed on it but you don't get any updates. So I decided to install Fedora and to get a little bit back to the roots because I grew up with Linux. I did the installation with an old 15" monitor and a keyboard I found somewhere in a box. It all went fine, so I took this heavy thing to my student room, connected it to my 22" monitor (with 1680x1050 pixels), turned it on and got a black screen after the bootloader.

It turned out, that the duallink and the so called "phantom" display ports are the reason for that. These [posts from str8bs](http://www.mintppc.org/forums/viewtopic.php?f=15&t=810) helped me a lot, I got something on my display, but it was only a small part of the desktop. I tried both DVI-ports, nothing helped.

Today, I talked to a fellow student about my problem. He adviced me to get rid of the DVI-to-VGA adapter and to try it one more time. Well, I honestly couldn't think of a reason why this adapter has something to do with my problem, but I gave it a shot, one last try. And it worked.

My configuration is as follows:

- The DVI-capable monitor connected to the right DVI-port (port location is from facing the back)
- No DVI-to-VGA adapters
- The following `yaboot.conf`

{% highlight bash %}
append="nouveau.duallink=0 video=DVI-I-1:d video=DVI-I-2:1680x105-24@60 video=TV-1:d"
{% endhighlight %}

Unfortunately, repositories like [RPM Fusion](http://rpmfusion.org/) don't support the `ppc` architecture anymore, so you have to build packages like VLC by yourself.

