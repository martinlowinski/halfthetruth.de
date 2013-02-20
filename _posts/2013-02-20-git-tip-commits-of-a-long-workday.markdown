---
layout: post
title: "Git tip: commits of a long workday"
slug: git-tip-commits-of-a-long-workday
date: 2013-02-20 23:46
author: Martin Lowinski
comments: true
published: true
categories: work
tags:
  - git
---

This is just a small tip for all git users out there. Usually, after a long workday, you want to briefly review the day before you leave the office. And who could tell you what you've done today better than git? It is a common practise to make small commits and commit often, which helps a lot in that case. With this config option (`~/.gitconfig`) you can simply run `git today` and get a nice and colorful list of the commits from today.. and than call it a day.

{% highlight bash %}
[alias]
  today = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --after="yesterday" --abbrev-commit --
{% endhighlight %}
