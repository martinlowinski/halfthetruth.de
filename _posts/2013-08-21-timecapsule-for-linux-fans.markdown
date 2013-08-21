---
layout: post
title: "TimeCapsule for Linux fans"
slug: timecapsule-for-linux-fans
date: 2013-08-21 21:48
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

* netatalk >= 2.2
* avahi-daemon
* openvpn
* udev

## OpenVPN ##

OpenVPN creates network "tunnels" between groups of computers by encrypting all traffic. It is very useful for our purpose as we don't want to have the backup services publicly accessible. A virtual private network can become very complex which is why we will focus on a simple scenario.

First, we have to install the packages.

{% highlight bash %}
$> aptitude install openvpn udev
{% endhighlight %}

OpenVPN comes with a set of tools called `easy-rsa` to create the neccessary key infrastructure and configuration. We simply copy them to `/etc/openvpn`.

{% highlight bash %}
$> cp -R /usr/share/doc/openvpn/examples/easy-rsa/ /etc/openvpn/.
{% endhighlight %}

Next step is to alter the relevant values in `/etc/openvpn/easy-rsa/2.0/vars`. This is an example:

{% highlight bash %}
export KEY_COUNTRY="DE"
export KEY_PROVINCE="AB"
export KEY_CITY="Somewhere"
export KEY_ORG="Somebody Inc."
export KEY_EMAIL="somebody@example.com"
{% endhighlight %}

With the following commands we will then build the public key infrastructure.

{% highlight bash %}
$> cd /etc/openvpn/easy-rsa/2.0/
$> . /etc/openvpn/easy-rsa/2.0/vars
$> . /etc/openvpn/easy-rsa/2.0/clean-all
$> . /etc/openvpn/easy-rsa/2.0/build-ca
$> . /etc/openvpn/easy-rsa/2.0/build-key-server <hostname>
{% endhighlight %}

All scripts will prompt you for additional information regarding the vars you set beforehand. The last command will generate the private key, the challenge password and company names are optional and can be left blank.

The server is now ready, let's create the certificates for the client.

{% highlight bash %}
$> . /etc/openvpn/easy-rsa/2.0/build-key <client>
{% endhighlight %}

Last but not least, we have to generate the Diffie Hellman parameters. This method is used to securely exchange the authentication data.

{% highlight bash %}
$> . /etc/openvpn/easy-rsa/2.0/build-dh
{% endhighlight %}

Now, we have all generated keys in `/etc/openvpn/easy-rsa/2.0/keys/`. The client needs the following files to authentication towards the server. Just copy them over to the client.

* `ca.crt`
* `client1.crt`
* `client1.key`

On the server, the following files have to be copied to the `/etc/openvpn` directory.

{% highlight bash %}
$> cd /etc/openvpn/easy-rsa/2.0/keys
$> cp ca.crt ca.key dh1024.pem <server>.crt <server>.key /etc/openvpn
{% endhighlight %}

The last step is to create the configuration for the OpenVPN server. We will use the sample configs provided with the package.

{% highlight bash %}
$> cd /usr/share/doc/openvpn/examples/sample-config-files
$> gunzip -d server.conf.gz
$> cp server.conf /etc/openvpn/
$> cp client.conf ~/
{% endhighlight %}

Great, restart OpenVPN.

{% highlight bash %}
$> /etc/init.d/openvpn start
{% endhighlight %}

The VPN server is now ready. As for the client configuration I'd like to refer to the [linode tutorial][3].

## Netatalk (AFP Service) ##

Netatalk is the open-source implementation of Apples AFP protocol. Since most distributions don't build netatalk with enabled encryption - which is needed by OSX - we have to configure and build the package ourselves.

This is how you do it:

{% highlight bash %}
$> sudo apt-get build-dep netatalk
$> sudo aptitude install cracklib2-dev fakeroot libssl-dev
$> sudo apt-get source netatalk
{% endhighlight %}

Another approach would be to install netatalk beta from an unofficial repository which is described [here][2].

Now we have installed all dependencies and downloaded the source package the our home directory. From there we can build netatalk with encryption enabled, this may take a while. Encryption is needed since FileVault was introduced to OSX.

{% highlight bash %}
$> cd netatalk-2*
$> sudo DEB_BUILD_OPTIONS=ssl dpkg-buildpackage -rfakeroot
{% endhighlight %}

When the process is finished without errors (simply ignore the warnings), we can install the new package as follows:

{% highlight bash %}
$> sudo dpkg -i ~/netatalk_2*.deb
{% endhighlight %}

As our new netatalk will have the same version number, Debian will overwrite it when an update is available. To prevent that, we will set the package state to hold.

{% highlight bash %}
$> echo "netatalk hold" | sudo dpkg --set-selections
{% endhighlight %}

Netatalk has lots of features which are enabled by default but we only need a few of them. All daemons can be configured in `/etc/default/netatalk`. For AFP shares, set `AFPD` and `CNID_META` to yes, if you want to use a printer enable `PAPD`.

{% highlight bash %}
ATALKD_RUN=no
PAPD_RUN=no
CNID_METAD_RUN=yes
AFPD_RUN=yes
TIMELORD_RUN=no
A2BOOT_RUN=no
{% endhighlight %}

Next, we configure the AFP daemon in `/etc/netatalk/afpd.conf`. Add the following at the bottom of the file or replace the existing line:

{% highlight bash %}
- -tcp -noddp -ipaddr 10.8.0.1 -noddp -uamlist uams_randnum.so,uams_dhx.so,uams_dhx2.so -nosavepassword -mimicmodel RackMac
{% endhighlight %}

This setting will set the AFP daemon to only listen to our private network for TCP connections and not to the outside world.

The last step is to tell the AFP daemon which Volumes it should offer. This is described in the `/etc/netatalk/AppleVolumes.default` configuration file. Because we want TimeMachine to work, add the following line:

{% highlight bash %}
/home/username/timemachine TimeMachine allow:username cnidscheme:dbd options:usedots,upriv,tm
{% endhighlight %}

This will create a share that can only be accessed from `username` and stores the data in `/home/username/timemachine` (you have to create this folder manually).

And finally, restart netatalk:

{% highlight bash %}
$> sudo /etc/init.d/netatalk restart
{% endhighlight %}


## Avahi (Bonjour) ##

[Avahi](https://en.wikipedia.org/wiki/Avahi_(software\)) is a free open-source implementation of [Zeroconf methodology](https://en.wikipedia.org/wiki/Zero_configuration_networking) and will advertise all services that we have configured before. Apples implementation is Bonjour which we will imitate using Avahi.

The installation is as simple as:

{% highlight bash %}
$> sudo aptitude install avahi-daemon
{% endhighlight %}

In `/etc/nsswitch.conf` we have to add `mdns` at the end of the line that starts with `hosts:`. It should than look like this:

{% highlight bash %}
hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4 mdns
{% endhighlight %}

The next step is to specify the shares we want to publish on the network. We therefor create the file `/etc/avahi/services/afpd.service` and put the following XML data into it.

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

It describes 3 services: The share itself, the device-info and the information needed for the TimeMachine mechanism to work properly. The string `model=Xserve` specifies how the device will look like in Finder.

Now restart Avahi.

{% highlight bash %}
$> sudo /etc/init.d/avahi-daemon restart
{% endhighlight %}


## Mac ##

### First Backup ###

Before you can use the TimeMachine, we have to enable unsupported network volumes in OSX. This is a hidden option.
You also have to allow communications over port 548 and 5353, only if you use a firewall.

{% highlight bash %}
$> defaults write com.apple.systempreferences TMShowUnsupportedNetworkVolumes 1
{% endhighlight %}

After that you are ready to go. Fire up the Time Machine system preferences and you should be able to choose the TimeMachine volume. Time Machine will then create a disk image on that volume (a sparsebundle) to cope the different filesystem formats.


### Full System Restore ###

If you ever need to do a full system restore, run the following to mount the complete disk image. Hopefully you'll never have to...

{% highlight bash %}
$> mount -t afp afp://username:password@hostname/ShareName /Volumes/ShareMount
{% endhighlight %}


## References ##

* [kremalicious.com/ubuntu-as-mac-file-server-and-time-machine-volume/](http://kremalicious.com/ubuntu-as-mac-file-server-and-time-machine-volume/)
* [tristanwaddington.com/2011/07/debian-time-machine-server-os-x-lion/](http://www.tristanwaddington.com/2011/07/debian-time-machine-server-os-x-lion/)
* [chris-lyons.blogspot.de/2012/03/setting-time-machine-and-netatalk-222.html](http://chris-lyons.blogspot.de/2012/03/setting-time-machine-and-netatalk-222.html)
* [ubuntugeek.com/getting-timemachine-to-work-under-ubuntu-10-04-lts-os-x-lion.html](http://www.ubuntugeek.com/getting-timemachine-to-work-under-ubuntu-10-04-lts-os-x-lion.html)
* [library.linode.com/networking/openvpn/debian-6-squeeze](https://library.linode.com/networking/openvpn/debian-6-squeeze)

[2]: http://www.tristanwaddington.com/2011/07/debian-time-machine-server-os-x-lion/
[3]: https://library.linode.com/networking/openvpn/debian-6-squeeze#sph_using-openvpn
