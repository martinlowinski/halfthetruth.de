--- 
wordpress_id: 421
author_login: admin
layout: post
comments: []

author: Martin Lowinski
title: The Mac OS X crash & bug series
published: true
tags: 
- mac
- lion
- snow-leopard
- bug
- apple
date: 2011-08-27 00:01:27 +02:00
categories: 
- Uncategorized
author_email: martin@goldtopf.org
wordpress_url: http://halfthetruth.de/?p=421
author_url: http://goldtopf.org
status: publish
---
For a few months now, I am a proud owner of a Macbook Pro.. at least I thought so. I made the change from my 4-years old Samsung notebook running ArchLinux just because I was curious about Mac OS X (and the underlying UNIX) and the ongoing hype around all the Apple products. There is nothing more to say since I already had a lot of discussions going on with friends which is somehow a never ending story.

So what's the point? Well, there is no operating system out there without bugs. Windows, Linux and also Mac OS, they all have bugs and a more or less sophisticated schedule to fix theses bugs. As a long-term Linux user the usual way to get along with bugs was simple: reproduce (that's the hard part), find the corresponding sourcecode, dig through it, fix it, submit a patch, done. It's not as easy as it sounds but a lot of Linux users and developers think similarly, so there's a good chance to find a patch on the web.

With Mac OS X and probably every other proprietary operating system it's a bit different to fight bugs. Apparently we don't have the source, so we can't patch anything (apart from reverse engineering and that kind of stuff). Since the update to Lion I have this bug: The kernel fills up my log with that message:

<code>kernel[0]: nstat_lookup_entry failed: 2</code>

Sometimes every few seconds, sometimes once a day. So the first thing to do? Google it. And I even found some <a href="https://discussions.apple.com/thread/3200365">threads</a> in the Apple Support Community complaining about the issue, some actually say it is slowing down their system, but nobody could come up with a solution.

To be fair, it is not visibly affecting my system. But a few weeks ago I had a major crash:

<code>Aug 7 22:57:20 kernel[0]: WaitForStamp: Overflowed waiting for stamp 0x0 on Main ring: called from
Aug 7 22:57:20 kernel[0]: timestamp = 0x809ec770
Aug 7 22:57:20 kernel[0]: **** Debug info for apparent hang in Main graphics engine ****
Aug 7 22:57:20 kernel[0]: ring head = 0x0f202f68, wrap count = 0x79
Aug 7 22:57:20 kernel[0]: ring tail = 0x00002f68 ring control = 0x00003001 enabled, auto report disabled, not waiting, semaphore not waiting, length = 0x004 4KB pages
Aug 7 22:57:20 kernel[0]: timestamps = 0x809ec770
Aug 7 22:57:20 kernel[0]: Semaphore register values:
Aug 7 22:57:20 kernel[0]: VRSYNC: (0x12044) = 0x809ec770
Aug 7 22:57:20 kernel[0]: BRSYNC: (0x22040) = 0x0
Aug 7 22:57:20 kernel[0]: RVSYNC: (0x 2040) = 0x0
Aug 7 22:57:20 kernel[0]: BVSYNC: (0x22044) = 0x0
Aug 7 22:57:20 kernel[0]: RBSYNC: (0x 2044) = 0x0
Aug 7 22:57:20 kernel[0]: VBSYNC: (0x12040) = 0x0
Aug 7 22:57:20 kernel[0]: kIPEHR: 0x78170003
Aug 7 22:57:20 kernel[0]: kINSTDONE: 0xfffffffe
Aug 7 22:57:20 kernel[0]: kINSTDONE_1: 0xffffffff</code>

"hang in Main graphics engine" doesn't sound good and my system really hanged. I could do nothing except power-down and restart. And again, there are users who have the <a href="https://discussions.apple.com/thread/2769135">same problem</a>. And again, no solution.

As you can see, it's a bit frustrating and I have to change my workflow in keeping my system running to: reproduce (that's the <em>easy</em> part), reboot, find other users who have the same problem, smile, wait for an update from Apple, keep waiting... ;)
