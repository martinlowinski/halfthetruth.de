--- 
wordpress_id: 445
author_login: admin
layout: post
comments: []

author: Martin Lowinski
title: Using git to deploy a website
published: true
tags: 
- website
- git
- deployment
date: 2011-09-13 20:27:52 +02:00
categories: 
- Website
author_email: martin@goldtopf.org
wordpress_url: http://halfthetruth.de/?p=445
author_url: http://goldtopf.org
status: publish
---
Git is powerful and better than everything else, says <a href="http://whygitisbetterthanx.com/">Scott Chacon</a>. In this post I want to show&nbsp; you a simple approach to manage and deploy a website with git. It's not the most complex scenario for a revision control tool but git provides a very nice technique to implement it.

The goal is to deploy your website by just running 'git push website' and git will deploy the website for you.
<h1>The local repository</h1>
First of all you need a local git repository. So, create a directory, let's call it 'website', run 'git init' inside and be happy. Of course you can also use an existing git repository, your choice.

{% highlight bash %}
$> mkdir website && cd website
$> git init
Initialized empty Git repository in /home/user/website/.git/
{% endhighlight %}

<h1>The remote repository</h1>
Than we need to setup the remote repository. To make it simple, we assume that the remote repository is on the same server that also hosts your website. Now create a git repository to which you have access to via ssh, git or some other protocol (it is recommended that you use ssh-pubkeys).

{% highlight bash %}
$> mkdir website.git && cd website.git
$> git init --bare
Initialized empty Git repository in /var/cache/git/website.git/
{% endhighlight %}

<h1>Post-receive</h1>
Now comes the magic: We create a post-receive hook, one great way to customize git. To do that simply change to the remote repository and add the following code to the file 'hooks/post-receive' and make it executable.

{% highlight bash %}
$> cat website.git/hooks/post-receive
#!/bin/sh
echo "********************"
echo "Post receive hook: Updating website"
echo "********************"

export GIT_WORK_TREE=/var/www/domain.com/htdocs
cd $GIT_WORK_TREE
sudo -u www-data git pull
sudo -u www-data git checkout master -f
$> chmod +x website.git/hooks/post-receive
{% endhighlight %}

This short script checks out the latest tree into a folder which is accessible by the webserver. If you follow the very nice <a title="A successful git branching model" href="http://nvie.com/posts/a-successful-git-branching-model/" target="_blank">branching model from Vincent Driessen</a> this is also the way to go as the master-branch always reflects a production-ready state. Some people even add a release file containing a tag to achieve the same functionality. They can parse it on post-receive and checkout this specific tag on a branch.

Back to the script. It's not working yet. We have to add a sudo rule for the user git. Therefore run visudo and add the following rules:

{% highlight bash %}
# After: Defaults env_reset
Defaults!/usr/bin/git env_keep=GIT_WORK_TREE
git ALL=(www-data) NOPASSWD: /usr/bin/git
{% endhighlight %}

This allows git (and the user 'git') to switch to 'www-data' (the webserver user) and to checkout the repository as such. That means we don't have to give the user 'www-data' more privileges than it needs and we can read and write to the directories of the webserver. With this rule git is only allowed to run /usr/bin/git as user 'www-data' and nothing more.

The deployment-process is set up and ready. Now we have to configure our local repository to be able to run 'git push website'. For that we have to connect the remote repository with the local one and push the changes:

{% highlight bash %}
$> git remote add webite git+ssh://domain.com/website.git
$> git push website +master:refs/heads/master
{% endhighlight %}

That is all. If you work on your code, you can now simply commit your changes and run 'git push website' to deploy everything.
<h1>Tweaks</h1>
If your project is a symfony-project you can also extend your hook with the following (for that you have to allow the user 'git' to run php):

{% highlight bash %}
echo "Updating symfony"
php bin/vendors update
php app/console assetic:dump
php app/console cache:clear
{% endhighlight %}

Abhijit Menon-Sen shows another <a href="http://toroid.org/ams/git-website-howto">tweak</a> to deploy your website on multiple servers.
