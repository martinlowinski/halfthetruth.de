---
layout: post
title: "TimeCapsule for Linux fans"
slug: timecapsule-for-linux-fans
date: 2013-08-20 22:59
author: martinlowinski
comments: true
published: true
categories: 
tags: 
  - mac
  - backup
  - timecapsule
  - time-machine
  - openvpn
  - netatalk
---

{% image 2013-08-20-timecapsule-for-linux-fans.jpg %}
  title: timecapsule-linux
  alt: TimeCapsule for Linux fans
{% endimage %}

_"Back up your data before you continue!"_ Almost every tutorial where you mess with your data starts with it. And the question is always how? For all the OSX' users out there, there is TimeMachine. It is an incremental back-up mechanism that is needly integrated into the OS. Backing up is done hourly and restoring data is easy (from a very fancy GUI). OSX supports the TimeCapsule, external harddrives and some [NAS](abbr:Network Attached Storage) as backup location. These NAS are typically Linux-based and run some sort of [netatalk](http://netatalk.sourceforge.net/), the open-source implementation of the AppleTalk protocol. I have a Netgear NAS running netatalk at home but had the problem that when I'm on the road, I can't access the data (since I don't want to drill a hole into my router's firewall).

A virtual-server was my solution to that. It is 24/7 online, accessible from nearly everywhere and has a 100Mbit/s connection. In this post I will describe how you set up a [VPN](abbr:Virtual Private Network) to do backups via TimeMachine on an AFP-share. I'm using Debian Squeeze here, but the instructions should work on other distributions as well. First, we will configure a VPN to transfer the data securely and then create the AFP service within the new network.

Packages that you need (without dependencies):

* netatalk >= 2.2.4
* avahi-daemon
* openvpn

## OpenVPN ##

## Netatalk (AFP Service) ##

Since most distributions don't include netatalk >= 2.2.4, we have to build it from source.

{% highlight bash %}
sudo apt-get build-dep netatalk
sudo aptitude install cracklib2-dev fakeroot libssl-dev
sudo apt-get source netatalk
{% endhighlight %}

{% highlight bash %}
cd netatalk-2*
sudo DEB_BUILD_OPTIONS=ssl dpkg-buildpackage -rfakeroot
{% endhighlight %}

{% highlight bash %}
sudo dpkg -i ~/netatalk_2*.deb
{% endhighlight %}

{% highlight bash %}
echo "netatalk hold" | sudo dpkg --set-selections
{% endhighlight %}


`/etc/default/netatalk`
{% highlight bash %}
ATALKD_RUN=no
PAPD_RUN=no
CNID_METAD_RUN=yes
AFPD_RUN=yes
TIMELORD_RUN=no
A2BOOT_RUN=no
{% endhighlight %}

`/etc/netatalk/afpd.conf`
{% highlight bash %}
- -tcp -noddp -ipaddr 10.8.0.1 -noddp -uamlist uams_randnum.so,uams_dhx.so,uams_dhx2.so -nosavepassword -mimicmodel RackMac
{% endhighlight %}

`/etc/netatalk/AppleVolumes.default`
{% highlight bash %}
/home/cobolt/timemachine TimeMachine allow:cobolt cnidscheme:dbd options:usedots,upriv,tm
{% endhighlight %}

{% highlight bash %}
sudo /etc/init.d/netatalk restart
{% endhighlight %}


## Avahi (Bonjour) ##

{% highlight bash %}
sudo aptitude install avahi-daemon
{% endhighlight %}

`/etc/nsswitch.conf`
{% highlight bash %}
hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4 mdns
{% endhighlight %}

`/etc/avahi/services/afpd.service`
{% highlight xml %}
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">%h</name>
  <service>
    <type>_afpovertcp._tcp</type>
    <port>548</port>
  </service>

  <service>
    <type>_device-info._tcp</type>
    <port>0</port>
    <txt-record>model=Xserve</txt-record>
  </service>

  <service>
    <type>_adisk._tcp</type>
    <port>9</port>
    <txt-record>dk0=adVF=0x83,adVN=Time Machine</txt-record>
  </service>
</service-group>
{% endhighlight %}

{% highlight bash %}
sudo /etc/init.d/avahi-daemon restart
{% endhighlight %}


### for netatalk-2.2.4 ###

Needed:
libavahi-client-dev

checkinstall fails, so before:
{% highlight bash %}
mkdir -p /usr/local/etc/netatalk/uams
{% endhighlight %}

{% highlight bash %}
checkinstall --pkgname=netatalk --pkgversion="$(date +%Y%m%d%H%M)" --backup=no --deldoc=yes --default
{% endhighlight %}

Configs in:
`/usr/local/etc/netatalk/afpd.conf`
`/usr/local/etc/netatalk/AppleVolumes.default`

## Mac ##

{% highlight bash %}
defaults write com.apple.systempreferences TMShowUnsupportedNetworkVolumes 1
allow communications over port 548 and 5353
{% endhighlight %}


### Full System Restore ###

{% highlight bash %}
mount -t afp afp://username:password@hostname/ShareName /Volumes/ShareMount
{% endhighlight %}



## References ##

* [kremalicious.com/ubuntu-as-mac-file-server-and-time-machine-volume/](http://kremalicious.com/ubuntu-as-mac-file-server-and-time-machine-volume/)
* [tristanwaddington.com/2011/07/debian-time-machine-server-os-x-lion/](http://www.tristanwaddington.com/2011/07/debian-time-machine-server-os-x-lion/)
* [chris-lyons.blogspot.de/2012/03/setting-time-machine-and-netatalk-222.html](http://chris-lyons.blogspot.de/2012/03/setting-time-machine-and-netatalk-222.html)
* [ubuntugeek.com/getting-timemachine-to-work-under-ubuntu-10-04-lts-os-x-lion.html](http://www.ubuntugeek.com/getting-timemachine-to-work-under-ubuntu-10-04-lts-os-x-lion.html)
