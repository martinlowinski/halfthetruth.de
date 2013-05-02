---
layout: post
title: "TimeCapsule for Linux fans"
slug: timecapsule-for-linux-fans
date: 2013-01-30 22:59
author: martinlowinski
comments: true
published: false
categories: 
tags: 
  - mac
  - backup
  - timecapsule
  - openvpn
  - netatalk
---

== OpenVPN ==

== Netatalk (AFP Service) ==

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


{% highlight bash %}
/etc/default/netatalk
ATALKD_RUN=no
PAPD_RUN=no
CNID_METAD_RUN=yes
AFPD_RUN=yes
TIMELORD_RUN=no
A2BOOT_RUN=no
{% endhighlight %}

/etc/netatalk/afpd.conf
- -tcp -noddp -ipaddr 10.8.0.1 -noddp -uamlist uams_randnum.so,uams_dhx.so,uams_dhx2.so -nosavepassword -mimicmodel RackMac

/etc/netatalk/AppleVolumes.default
/home/cobolt/timemachine TimeMachine allow:cobolt cnidscheme:dbd options:usedots,upriv,tm

sudo /etc/init.d/netatalk restart


== Avahi (Bonjour) ==

sudo aptitude install avahi-daemon

/etc/nsswitch.conf
hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4 mdns

/etc/avahi/services/afpd.service
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

sudo /etc/init.d/avahi-daemon restart


=== for netatalk-2.2.4 ===

Needed:
libavahi-client-dev

checkinstall fails, so before:
mkdir -p /usr/local/etc/netatalk/uams

checkinstall --pkgname=netatalk --pkgversion="$(date +%Y%m%d%H%M)" --backup=no --deldoc=yes --default

Configs in:
/usr/local/etc/netatalk/afpd.conf
/usr/local/etc/netatalk/AppleVolumes.default

== Mac ==

defaults write com.apple.systempreferences TMShowUnsupportedNetworkVolumes 1
allow communications over port 548 and 5353


=== Full System Restore ==

mount -t afp afp://username:password@hostname/ShareName /Volumes/ShareMount



== References ==

http://kremalicious.com/ubuntu-as-mac-file-server-and-time-machine-volume/
http://www.tristanwaddington.com/2011/07/debian-time-machine-server-os-x-lion/
http://chris-lyons.blogspot.de/2012/03/setting-time-machine-and-netatalk-222.html
http://www.ubuntugeek.com/getting-timemachine-to-work-under-ubuntu-10-04-lts-os-x-lion.html
