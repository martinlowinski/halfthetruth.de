---
layout: post
title: "Highlighting of clicked Links in PhoneGap Apps"
slug: highlighting-of-clicked-links-in-phonegap-apps
date: 2012-10-14 23:09
author: Martin Lowinski
comments: true
published: true
categories: Work
tags:
  - android
  - phonegap
  - css
---

Recently, working on a mobile app for Android, I recognized that the DroidView of PhoneGap (which uses WebKit) draws a border around links and buttons when clicked. As a native-looking app this green/orange border sometimes breaks the layout and here is how you can remove it:

{% highlight css %}
/* Hide Android WebView Highlight Border */
* {
  -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
}
{% endhighlight %}

Some people may argue that from the user experience perspective it is important that the user knows when something is focused or tapped. This is probably true for normal websites and the reason why the developers of webkit for Android included this default css rule. In native-looking apps though, one usually has other approaches to give this feedback to the user.
