---
layout: post
title: "Jekyll is the new Wordpress"
slug: jekyll-is-the-new-wordpress
date: 2012-02-07 22:52
author: Martin Lowinski
comments: true
published: true
categories: 
tags:
  - wordpress
  - jekyll
---
At least for this blog. ([Jump](#jekyll-installation) right to the Jekyll-part)

It's amost 3 years ago since [I moved this blog](/2008/05/05/moved-to-wordpress) blog from textpattern to wordpress. The main reason was because there's a ton of plugins to extend the blogging experience and also &mdash; I have to admit &mdash; because everybody used it. Wordpress's ecosystem grew further and today we have companies like [WPEngine](http://wpengine.com/) that were build on top of it.

Wordpress is nice, so what's the matter? Well, my server crashed a few times in the last year mostly because it couldn't handle the load. As it is only running lighttpd and MySQL it is easy to pinpoint what the problem is. I'm currently running a growing number of Wordpress instances (plus some handmade code) on this server. You can install Wordpress in 5 minutes but I can't migrate to a bigger machine in 5 minutes. "The Cloud is the solution", one would say. Indeed, it is _a_ solution but a rather expensive one [[1]](http://blog.carlmercier.com/2012/01/05/ec2-is-basically-one-big-ripoff/ "EC2 is basically one big rip-off")[[2]](http://gigaom.com/2012/02/11/which-is-less-expensive-amazon-or-self-hosted/ "Which is less expensive: Amazon or self-hosted?") for this blog.

So instead of constantly switching to bigger machines or invest in the cloud, I want to reduce the load (who doesn't want that?). The $100-question is how? I've already tried some stuff:

* W3 Total Cache and [WP-Cache](/2011/08/27/wp-cache-error-500-after-upgrade-to-wordpress-3-2-1)
* PHP bytecode cache XCache
* Config tweaks in lighttpd

First I had some problems with the cache-plugins for Wordpress but all of these tweaks kinda work as promised.

There has to be more. Long story short: This is my first try to replace one Wordpress installation with Jekyll. If it works out I consider replacing the other one as well.


<a name="jekyll"></a>
## What is Jekyll?

> Jekyll is a simple, blog aware, static site generator. It takes a template directory (representing the raw form of a website), runs it through Textile or Markdown and Liquid converters, and spits out a complete, static website suitable for serving with Apache or your favorite web server. This is also the engine behind GitHub Pages, which you can use to host your project’s page or blog right here from GitHub.

There's probably nothing to add. The optimization consists of basically replacing all dynamic parts of a blog with client-side code (Disqus with JavaScript) and leave the rest static.


<a name="jekyll-installation" /></a>
## Jekyll installation and configuration

This was my todo list to do a clean migration from Wordpress to Jekyll which I want to explain in the next part.

* Set up Jekyll (fork mojombo)
* Migrate comments from Wordpress to Disqus (via plugin)
* Import posts from Wordpress using the Jekyll importer with some additions
* Install Sass &amp; Compass
* Create archive pages for tags and categories
* Wordpress compatibility tweaks
* Create some usefull rake tasts (compile, deploy, post, ...)


### Set up Jekyll

This task is the easiest one. Simply fork one of the many git repositories on github (like the one from [mojombo](https://github.com/mojombo/mojombo.github.com)):

{% highlight bash %}
$> git clone https://github.com/mojombo/mojombo.github.com.git
$> rm mojombo.github.com.git/_posts/* mojombo.github.com.git/images/*
{% endhighlight %}

With that you have a working (local) jekyll repository. To generate the site simply run

{% highlight bash %}
$> jekyll
{% endhighlight %}

By default the result is stored in `_site`.


### Migrate comments from Wordpress to Disqus

You have two options. One is to install the Disqus plugin for Wordpress or to export your comments to a XML-file and upload it to Disqus. For either approaches, it took almost a day to import the 11(!) comments.

I tried both ways which are really straight forward but had the problem, that special characters were translated to their escaped hexadecimal representation which looked ugly.


### Import posts from Wordpress

### Sass &amp; Compass

### Wordpress compatibility

#### RSS feed

By default, Jekyll provides an `atom.xml` feed in the root folder. Wordpress's feed in contrast is usually in `/feed/`.

For that, create a folder feed and move the `atom.xml` to `feed/index.xml`. You may have also to change the index-filenames in your webserver configuration to support `index.xml` as well.


#### Archive and index pages

Wordpress provides index pages for tags and categories, for free. With Jekyll we have to add this feature. Jose Diaz-Gonzalez has written a few [plugins](https://github.com/josegonzalez/josediazgonzalez.com/tree/master/_plugins) to support these kind of standard weblog extensions.

`generic_index.rb` is the one we're looking for. Download it to your `_plugins` directory and edit the `config.yml` like that:

{% highlight yaml %}
category_dir:       categories
 
index_pages:
 category:
   do_related:     false
   title_prefix:   'Category: '
 tag:
   do_related:     true
   title_prefix:   'Tag: '
{% endhighlight %}

Now, for each index page (tag and categories) create a file `_layout/(tag|category)_list.html`:

{% highlight html %}
{% raw %}
<!-- tag_list.html -->
---
layout: default
---
{% for tag in page.tags %}
    <h4><a href="/tags/{{ tag | replace:' ', '-' | downcase }}" name="{{ tag | replace:' ','-' | downcase }}">{{ tag }}</a></h4>
    <ul>
        {% for post in site.tags[tag] %}
        <li><a href="{{post.url}}">{{ post.title }}</a></li>
        {% endfor %}
    </ul>
{% endfor %}
{% endraw %}
{% endhighlight %}

And `_layout/(tag|category)_index.html` with something like that:

{% highlight html %}
{% raw %}
<!-- tag_index.html -->
---
layout: default
---
<ul>
{% for post in site.tags[page.tag] %}
  <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>
{% endraw %}
{% endhighlight %}


### Rake tasks

There are lots of Rakefiles out there, so my advice is to pick the best parts (e.g. from Octopress) und create your own. This could be the basis:

{% highlight ruby %}
require "rubygems"
require "stringex"
require "highline/import"

public_dir      = "_site"    # compiled site directory
posts_dir       = "_posts"    # directory for blog files

namespace :jekyll do
  desc 'Delete generated _site files'
  task :clean do
    system "rm -fR #{public_dir}"
  end

  desc 'Run the jekyll dev server'
  task :server => [ :compile ] do
    system "jekyll --server --auto"
  end

  desc 'Clean temporary files and run the server'
  task :compile => [ :clean, 'compass:clean', 'compass:compile' ] do
    system "jekyll"
  end
end

desc 'List all draft posts'
task :drafts do
  puts `find ./_posts -type f -exec grep -H 'published: false' {} \\;`
end

desc 'Clean out temporary files'
task :clean => [ 'compass:clean', 'jekyll:clean' ] do
end

desc 'Compile whole site'
task :compile => [ 'jekyll:compile' ] do
end
{% endhighlight %}

