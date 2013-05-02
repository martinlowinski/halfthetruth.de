--- 
wordpress_id: 277
author_login: admin
layout: post
comments: []

author: martinlowinski
title: Backups with duplicity and Amazon S3
excerpt: |-
  Last month I accidentally deleted ~700 emails from my inbox. And these sevenhundred emails weren't spam, no, I've read some of them just a minute ago. Even worse, I couldn't figure out what had happened to them. During an offlineimap-sync from my mailserver to a local harddrive offlineimap reported that it deleted my mails, on the mailserver and on my harddrive. And after some frustating hours of trying to recover these mails I decided to go on and find a better way to backup my inbox (and other files).
  
  So, in this post I want to show you my backup-setup with duplicity, duply and Amazons S3.
published: true
tags: 
- linux
- backup
- amazon
- s3
- duplicity
- duply
- debian
date: 2010-10-11 15:35:38 +02:00
categories: 
- Work
author_email: martin@goldtopf.org
wordpress_url: http://halfthetruth.de/?p=277
author_url: http://goldtopf.org
status: publish
---
Last month I accidentally deleted ~700 emails from my inbox. And these sevenhundred emails weren't spam, no, I've read some of them just a minute ago. Even worse, I couldn't figure out what had happened to them. During an offlineimap-sync from my mailserver to a local harddrive, offlineimap reported that it has deleted my mails, on the mailserver and on my harddrive. And after some frustating hours of trying to recover these mails I decided to go on and find a better way to backup my inbox (and other files).

So these are basically the requirements the new backup-routine has to fulfill:
<ul>
	<li>Full and incremental backups should be possible</li>
	<li>Backups should be unattended</li>
	<li>Backup archives should be compressed and on insecure locations be encrypted</li>
	<li>Communications with the backup server should be encrypted</li>
	<li>The complete archive as well as specific files from the archive should be restorable</li>
</ul>
There is lots of <a href="http://www.wolke.hs-furtwangen.de/">research</a> going on at my <a href="http://www.hs-furtwangen.de">university</a> on cloud computing and some friends from uni even wrote their final thesis on that kind of topic. This is how I got in touch with <a href="http://aws.amazon.com/s3/">Amazon Web Service S3</a>:
<blockquote>Amazon Simple Storage Service provides a fully redundant data storage infrastructure for storing and retrieving any amount of data, at any time, from anywhere on the Web.</blockquote>
S3 is great. You don't have to keep in mind how much free webspace you have, how you can access your data or what happens when a harddisk fails. You pay only for the amount of storage you actually use (plus the traffic) and can access your date over a SOAP or REST API. That is why I chose S3 as the storage medium for my backups.

Next topic is the software which should actually move the archives to S3. I chose <a href="http://duplicity.nongnu.org/">duplicity</a> (thanks for the tip, Christoph) and the wrapper-script <a href="http://duply.net/">duply</a> to handle this. It provides everything I need:
<blockquote>Duplicity backs directories by producing encrypted tar-format volumes and uploading them to a remote or local file server. Because duplicity uses librsync, the incremental archives are space efficient and only record the parts of files that have changed since the last backup. Because duplicity uses GnuPG to encrypt and/or sign these archives, they will be safe from spying and/or modification by the server.</blockquote>
Okay, now we have the software and the technology, let's take a look on the setup. I'm using Debian Lenny, so to install duplicity we need to adjust the sources.list because duplicity from the main repository is already two years old. To do that open /etc/apt/sources.list and add this at the end:
{% highlight bash %}deb http://www.backports.org/debian lenny-backports main contrib non-free{% endhighlight %}
We will then update and install it with aptitude as usual:
{% highlight bash %}aptitude update
aptitude -t lenny-backports install duplicity{% endhighlight %}
To use the Amazon S3 service with duplicity we have to install the library python-boto as well:
{% highlight bash %}aptitude install python-boto{% endhighlight %}
That is great so far, but duplicity is a complex piece of software and that is why there are lots of wrapper-scripts available on the internet. We want to use duply. Since duply is not in the debian repositories we have to install it by hand. Grab a copy from <a href="http://duply.net">duply.net</a>, unpack it and move it to a location you like (as long as it is available in your PATH):
{% highlight bash %}wget http://sourceforge.net/projects/ftplicity/
tar -xvf duply_*.tgz
cp duply_*/duply ~/bin/duply{% endhighlight %}
Next step is the configuration of the two. To create the folder-structure and the configuration files for duply, simply run:
{% highlight bash %}mkdir -p /etc/duply
duply s3backup create{% endhighlight %}
This will create a directory either in ~/.duply/ (as user) or in /etc/duply (as root) with a default conf-file. We can now edit the configuration to fit our needs:
{% highlight bash %}GPG_KEY='12345678'
GPG_PW='averylongpassword'
TARGET='s3+http://[user:password]@bucket_name[/prefix]'
SOURCE='/'
MAX_FULLBKP_AGE=1M
DUPL_PARAMS="$DUPL_PARAMS --full-if-older-than $MAX_FULLBKP_AGE"
VOLSIZE=100
DUPL_PARAMS="$DUPL_PARAMS --volsize $VOLSIZE"
DUPL_PARAMS="$DUPL_PARAMS --s3-use-new-style --s3-european-buckets"{% endhighlight %}
With line one and two we specifiy the gnupg-key and passphrase to encrypt the archives. The passphrase is saved in plaintext, but you can read the file only with root privileges. If this is to unsecure for you, the FAQ of GnuPG describes another way to use your <a href="http://www.gnupg.org/faq/GnuPG-FAQ.html#how-can-i-use-gnupg-in-an-automated-environment">gpg-key in an automated environment</a>. Line 3 specifies that we want to use Amazons S3 service over HTTPS (despites the url says http). You get your username and password from your <a href="http://aws.amazon.com/account/">AWS account</a> known as the Access Key ID and the Secret Access Key. The bucket-name is an unique identifier throughout S3 and you cannot change it, so choose wisely. Than we have to select the source, which I set to '/' and means backup everything under root (more on that later). The next two variables say that duplicity should create a full backup every month and by default remove all prior backups except one (you can change that by setting MAX_AGE and MAX_FULL_BACKUPS). With the variable volsize you can set the size of each chunk (default is 25 MByte). This is important because S3 doesn't allow files bigger than 5 GByte. If you set it to a small value, duplicity will create a huge bunch of files but this could speed up restoring. On the other hand a large number could save some time during the backup process. Finally, we have to add the params '--s3-use-new-style --s3-european-buckets' to tell S3 that I want to store my files in the European region (Ireland).

Now back to the data we want to backup. The file /etc/duply/s3backup/exclude (you have to create that file by hand) is the exclude global globbing filelist. You can specifiy with - (minus) what to exclude and with + (plus) what to include. By default, everything under SOURCE is included. For more information on the syntax, read the <a href="http://duplicity.nongnu.org/duplicity.1.html#toc9">manpage</a>. You can also put some commands for preparation, like dumping a database to file etc. in /etc/duply/s3backup/pre. Likewise, /etc/duply/s3backup/post is for doing some work after the backup, like send a mail to the admin.

As I mentioned earlier, I want to do incremental backups every day. To do that, create a file duply-s3backup in /etc/cron.daily/ (chmod +x)
{% highlight bash %}#!/bin/sh
#
# duply s3backup cron daily
/root/bin/duply s3backup backup_verify_purge --force > /var/log/duplicity.log 2>&1
exit 0{% endhighlight %}
If you need to save bandwidth you can remove "verify", but in order to know that you have a consistent backup you shouldn't. The script logs to /var/log/duplicity.log and because we don't want to waste our disk space logrotate should manage the duplicity-logfiles. To do that, just create a file duplicity in /etc/logrotate.d/ with the following:
{% highlight bash %}/var/log/duplicity.log {
       weekly
       rotate 14
       compress
}{% endhighlight %}
This tells logrotate to rotate the logfile very week, compress the old ones and delete it after 14 rotations (about 3 months).

You can now run the script for the first time, this will create a full backup. Depending on the size of your backup, your system and internet connection, you can most certainly grab a coffee or two.
{% highlight bash %}./etc/cron.daily/duply-s3backup{% endhighlight %}
To verify that the script did what it has to do, run:
{% highlight bash %}duply s3backup status{% endhighlight %}
You can also take a look at your <a href="https://console.aws.amazon.com/s3/home">management console</a>, duplicity should have created a bucket with your first backup.

We now have a great setup to backup our data. Duplicity will do an incremental backup every day, a full backup every month and will remove the old and unused archives from the backup-server every time cron runs the script. But we do backups not to just <em>have</em> backups. We backup our data to <em>restore</em> it in some way if the system crashes. And duplicity is really smart here. To restore the whole archive simply run
{% highlight bash %}duply s3backup restore ./restore-dir 7d{% endhighlight %}
and you'll get the 7-days old complete archive unencrypted in the folder restore-dir. If you want to restore just one specific file, use
{% highlight bash %}duply s3backup fetch etc/passwd /etc/passwd-yesterday 1D{% endhighlight %}
This will restore the file passwd from 1 day ago to /etc/passwd-yesterday. Duply and duplicity have a lot more powerful commands which a documented in the manpages very well.

The only thing you have to do now, is to copy the duply-confdir (/etc/duply or ~/.duply) and your gpg-key to a save place. If the whole system crashes you won't be able to restore your backups unless you have the configuration and/or your private key.

The sources to this post and some links on the topic:
<ul>
	<li><a href="http://duplicity.nongnu.org/">Duplicity</a></li>
	<li><a href="http://duply.net">Duply</a></li>
	<li><a href="http://aws.amazon.com/documentation/s3/">Amazon Simple Storage Service (S3) Documentation</a></li>
	<li><a href="http://www.debian-administration.org/articles/209">Unattended, Encrypted, Incremental Network Backups: Part 1</a></li>
	<li><a href="http://marcel-adamczyk.de/?p=34">Debian 5.0 Lenny, mit GPG und duplicity verschl&uuml;sseltes Backup auf FTP Server</a></li>
	<li><a href="http://www.marcogabriel.com/blog/archives/585-Linux-Backup-mit-Duply,-Duplicity-und-Rdiff-Backup-auf-potentiell-unsichere-Online-Speicher-Teil-1.html">Linux Backup mit Duply, Duplicity und Rdiff-Backup auf (potentiell unsichere) Online Speicher (Teil 1)</a></li>
	<li><a href="http://www.marcogabriel.com/blog/archives/586-Linux-Backup-mit-Duply,-Duplicity-und-Rdiff-Backup-auf-potentiell-unsichere-Online-Speicher-Teil-2.html">Linux Backup mit Duply, Duplicity und Rdiff-Backup auf (potentiell unsichere) Online Speicher (Teil 2)</a></li>
</ul>
