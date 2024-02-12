---
layout: post
title: "Docker: Move to new data-root"
slug: docker-move-data-root
date: 2023-12-11 19:08
description: Docker reliably encapsulates configuration, data and other files. But as soon as you start running services like databases or even common monitoring concepts, the underlying storage layer may become a bottleneck. However, moving all docker-related data to a new location is more than just a `mv` command.
author: martinlowinski
comments: true
published: true
categories: 
tags: 
  - docker
---

Dockerized services are great, especially with named docker volumes. All the configuration, data and other files are reliably stored away and can easily be accessed. But as soon as you run services like databases or even common monitoring concepts, the underlying storage layer becomes important. Factors like access latency, throughput, backup and space need to be taken into account.

We ran into the limitations of our storage after switching from prometheus to mimir. The requirement was, that we can access long-term monitoring data of our infrastructure efficiently. The storage space on our virtual servers however was quite small. Hence, we added external storage managed by our provider. Now we just needed to move all docker-related data to its new location. Unfortunately, it is more then just a `mv` command.

Let's begin. First, we need to stop all docker services.

{% highlight bash %}
sudo systemctl stop docker
sudo systemctl stop docker.socket
sudo systemctl stop containerd
{% endhighlight %}

Now copy the current state of your docker data root to its new location. I'm using rsync here, but cp should work similar. Depending on the size of your containers and images, it's time to grab a coffee or tea.

{% highlight bash %}
rsync -aqxP /var/lib/docker/ /new/path/docker
{% endhighlight %}

I'd to like to keep a backup if things go wrong.

{% highlight bash %}
mv /var/lib/docker /var/lib/docker.old
{% endhighlight %}

It's time to change the configuration of docker to point to the new location. Edit `/etc/docker/daemon.json` as follows:

{% highlight conf linenos %}
{
    "data-root": "/new/path/docker"
}
{% endhighlight %}

So far, so good. That's what we thought. However, the `config.v2.json` file for each container stores the absolute path to the original storage location. As pointed out in this [thread](https://forums.docker.com/t/error-starting-container-after-moving-docker-root-directory/64324), there is very little information on this important detail. We reversed the migration, tried again, double checked everything until we found the problem.

{% highlight bash %}
sed -i 's%/var/lib/docker%/new/dir%g' /new/path/docker/containers/*/config.v2.json
{% endhighlight %}

Don't change the container configuration while docker is running, otherwise it won't have any affect. After that you're ready to boot up docker with it's new storage location.

{% highlight bash %}
sudo systemctl start docker
{% endhighlight %}

You can verify the storage paths with this command:

{% highlight bash %}
{% raw %}
docker info -f '{{ .DockerRootDir }}'
{% endraw %}
{% endhighlight %}
