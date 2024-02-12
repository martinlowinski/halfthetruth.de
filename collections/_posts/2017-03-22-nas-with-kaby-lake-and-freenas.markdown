---
layout: post
title: "NAS with Kaby Lake and FreeNAS"
slug: nas-with-kaby-lake-and-freenas
date: 2017-03-22 18:12
description: Instructions for a FreeNAS server built on Intel's Kaby Lake platform with full ZFS support.
author: martinlowinski
comments: true
published: true
categories: 
tags: 
  - backup
  - nas
  - freenas
---

_"Back up your data before you continue!"_ Almost every tutorial where you mess with your data starts with it. And the question is always how? For all the OSX' users out there, there is TimeMachine. It is an incremental back-up mechanism that is needly integrated into the OS. Backing up is done hourly and restoring data is easy (from a very fancy GUI). OSX supports the TimeCapsule, external harddrives and some [NAS](abbr:Network Attached Storage) as backup location. These NAS are typically Linux-based and run some sort of [netatalk](http://netatalk.sourceforge.net/), the open-source implementation of the AppleTalk protocol. I have a Netgear NAS running netatalk at home but had the problem that when I'm on the road, I can't access the data (since I don't want to drill a hole into my router's firewall).

A virtual-server was my solution to that. It is 24/7 online, accessible from nearly everywhere and has a 100Mbit/s connection. In this post I will describe how you set up a [VPN](abbr:Virtual Private Network) to do backups via TimeMachine on an AFP-share. I'm using Debian Squeeze here, but the instructions should work on other distributions as well. First, we will configure a VPN to transfer the data securely and then create the AFP service within the new network.

> Wer FreeNAS nicht kennt: es handelt sich dabei um ein System, dass auf FreeBSD basiert, also ein UNIX ist, und speziell für den Einsatz auf NAS-Systemen zugeschnitten ist. Die Konfiguration erfolgt hierbei vollständig über eine übersichtliche Weboberfläche. Dieses Projekt basiert auf M0n0wall, einer ebenfalls auf FreeBSD basierenden integrierten Firewall-Lösung.

## Requirements

On the FreeNAS website the minimum hardware requirements are listed as:

- Multicore 64-bit processor (Recommended Intel)
- 8GB boot drive
- 8GB of RAM
- A physical network port

And the recommended hardware is listed as:

- Multicore 64-bit processor (Recommended Intel)
- 16GB boot drive
- 16GB of ECC RAM
- Two directly attached discs (non-hardware RAID)
- A physical network port


## Components

- ASUS P10S-M WS Motherboard (90SB05Q0-M0EAY0)
- Intel Pentium G4560, 2x 3.50GHz, boxed (BX80677G4560)
- Kingston ValueRAM Hynix A-Die DIMM 8GB, DDR4-2133, CL15-15-15, ECC (KVR21E15D8/8HA)
- Seasonic G-Series G-450 450W ATX 2.3 (SSR-450RM) Power Supply
- 2x Western Digital Red 3TB, 3.5", SATA 6Gb/s (WD30EFRX)
- SanDisk Ultra Fit 32GB, USB 3.0 (SDCZ43-032G-GAM46)
- Lian Li Midi Tower
- 2x Noname Case Fans

Some notes regarding the parts.
Got the motherboard in an outlet with a 40% discount.
[Power supply calculator](http://outervision.com/power-supply-calculator)


## Build

Check serial number with: smartctl -a /dev/ada1 | grep "Serial Number"
[WD waranty status](http://support.wdc.com/warranty/warrantystatus.aspx).
Serial Number:    WD-WCC4N2DRSEN9 (ada0)
Serial Number:    WD-WCC4N4LTUNYX (ada1)

### Memtest

Run Memtest86 or Memtest86+


### ECC

Check in BIOS. Check Memtest86+.
`dmidecode -t 16`, check for "Error Correction Type"
`dmidecode -t memory`, check for "Error Correction Type"
Ref: https://www.pugetsystems.com/labs/articles/How-to-Check-ECC-RAM-Functionality-462/

### Burn-in tests

Run the following commands, one test for each drive. These tests run online, i.e. you can even log out.

Short self-test (takes about 5 minutes):
{% highlight bash %}
smartctl -t short /dev/adaX
{% endhighlight %}

You can check the progress by running:
{% highlight bash %}
smartctl -a /dev/adaX | grep "test remaining"
{% endhighlight %}

Conveyance test (2 minutes):
{% highlight bash %}
smartctl -t conveyance /dev/adaX
{% endhighlight %}

Long test (took approx. 400 minutes for my 3TB drives)
{% highlight bash %}
smartctl -t long /dev/adaX
{% endhighlight %}

The next drive tests run in foreground and takes quite a while. Hence, it is recommended to use either `screen` or `tmux`. Create a new session and run the following commands, it is a 4-pass r/w test. Before running badblocks, we need to enable the kernel geometry debug flags.

{% highlight bash %}
sysctl kern.geom.debugflags=0x10
{% endhighlight %}

The badblocks test can run simultaneously, one for each drive without slowing down the other test. As badblocks has some limitations with drives larger than 2TB, we have to specify the block size manually. Attention: badblocks will destroy any data on the disk!

{% highlight bash %}
badblocks -b 4096 -ws /dev/adaX
{% endhighlight %}

I ignored the warning `Testing with pattern 0xaa: set_o_direct: Inappropriate ioctl for device` as I couldn't find any information to it. It took TBD hours for badblocks to test the two 3TB drives.
Once the badblocks tests are finished, run the S.M.A.R.T long test again. It can the detect errors that have occured while writing to bad sectors via badblocks.

Output (55h for ada1, 59h for ada0):
{% highlight bash %}
Testing with pattern 0xaa: set_o_direct: Inappropriate ioctl for device
done
Reading and comparing: ^Abddone
Testing with pattern 0x55: done
Reading and comparing: done
Testing with pattern 0xff: done
Reading and comparing: done
Testing with pattern 0x00: done
Reading and comparing: done
{% endhighlight %}

{% highlight bash %}
smartctl -t long /dev/adaX
{% endhighlight %}

When the tests are finished, we can view the results.

{% highlight bash %}
smartctl -A /dev/adaX
{% endhighlight %}

The important attributes are `Reallocated_Sector_Ct`, `Current_Pending_Sector`, and `Offline_Uncorrectable`. If their `RAW_VALUE` is 0, this means there are currently no bad sectors. If this number is greater than 0 for a new drive, you should probably return it.


## Configuration

Check for updates and install
Set hostname
Set timezone

Go to System->System Dataset in the GUI, select the pool you just created for "System dataset pool", and I suggest (unless you understand these options and consciously have something else in mind for some reason) that you check both the "syslog" and "reporting database" options.

Set HTTPS for the GUI (with letsencrypt)
Create internal CA: http://doc.freenas.org/9.10/system.html#cas

Set up outgoing email credentials
Set up ssh keys
Set this up for your root email. Go to Account->Users, highlight user ID 0 (root), and click "change e-mail", and enter your email address.
Set up UPS service (oh oh)

[3-2-1 rule](http://lifehacker.com/5961216/why-you-should-have-more-than-one-backup):

> 3 copies of anything you care about - Two isn't enough if it's important.
> 2 different formats - Example: Dropbox+DVDs or Hard Drive+Memory Stick or CD+Crash Plan, or more
> 1 off-site backup - If the house burns down, how will you get your memories back?

Als Faustregel gilt dabei das 3-2-1-Prinzip: Drei Kopien der Daten (eine im System selbst plus zwei Backups), zwei verschiedene Medientypen für die Backups (z.B. externe Festplatte und Cloud-Speicher) sowie stets eine der Kopien außer Haus (etwa mittels Cloud oder durch Lagern der externen Platte auf Omas Dachboden).


Scrubs

[3]: https://forums.freenas.org/index.php?threads/scrub-and-smart-testing-schedules.20108/

12. Set up Scrubs. Go to Storage->Scrubs. Scrubs are one way ZFS heals itself. You should perform scrubs on your main pool probably about twice per month for typical consumer grade hardware. Click "Add Scrub", select your volume, and set your "Threshold days" to something like 10, 14, 20. Something like that. If you scroll down, you'll see it (probably) defaults to only performing scrubs on Sundays. For most home users, it doesn't much matter what day of the week a scrub is performed, so you could checkmark all the days of the week.

12a. Boot scrubs. The scrubbing for the boot pool is handled separately. Go to System->Boot. In most cases, a default scrub interval of "35 days" will be set at the top. In my view, that's far too long--USB drives throwing errors is VERY common, and I like to know the minute it happens. I recommend a much smaller value. Mine is set to "5 days".

13. Set up SMART tests. Go to Tasks->S.M.A.R.T. tests. I recommend a regimen of Long tests every fortnight, and Short tests every few days. A lot of people out there think "short" tests are completely useless, just for full disclosure. Here's what mine looks like:


Alerts and Reporting

Services -> SMART
  Set critical to 45 degrees and email to report

Set boot scrub to 10 days

Snapshots

Dataset: tank1
Expires after 2 weeks
Recursive


## UPS

- Power Anschlüsse: mind. 3
- RJ45: mind. 1
- USB zur Überwachung
- Blitzschutz
- Puffer: 20-30%
- `>750VA`


## References

[2]: https://forums.freenas.org/index.php?threads/how-to-hard-drive-burn-in-testing.21451/
[3]: https://forums.freenas.org/index.php?threads/scrub-and-smart-testing-schedules.20108/
[4]: https://forums.freenas.org/index.php?threads/the-math-on-hard-drive-failure.21110/
https://forums.freenas.org/index.php?threads/slideshow-explaining-vdev-zpool-zil-and-l2arc-for-noobs.7775/
https://www.familybrown.org/dokuwiki/doku.php?id=fester:intro

