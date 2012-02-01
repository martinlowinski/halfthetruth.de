--- 
wordpress_id: 411
author_login: admin
layout: post
comments: []

author: Martin Lowinski
title: WP-Piwik and disabled index-file.names
published: true
tags: 
- wordpress
- piwik
- plugin
date: 2011-06-23 22:16:53 +02:00
categories: 
- Website
author_email: martin@goldtopf.org
wordpress_url: http://halfthetruth.de/?p=411
author_url: http://goldtopf.org
status: publish
---
<a href="http://wordpress.org/extend/plugins/wp-piwik/">WP-Piwik</a> is a really cool plugin to connect your wordpress-site with <a href="http://piwik.org/">Piwik</a> and I am using it on all my installations. But as I moved Piwik to a  new server the plugin refused to generate the proper JavaScript-code.  WP-Piwik could connect to my Piwik-server but the URLs in the script  were wrong, as you can see here:
<pre lang="javascript"><!-- Piwik -->
<script type="text/javascript">
var pkBaseURL = (("https:" == document.location.protocol) ? "https://mydomain.de/" : "http://mydomain.de/");
document.write(unescape("%3Cscript src='" + pkBaseURL + "piwik.js' type='text/javascript'%3E%3C/script%3E"));
</script><script type="text/javascript">
try {
var piwikTracker = Piwik.getTracker(pkBaseURL + "piwik.php", 1);
piwikTracker.trackPageView();
piwikTracker.enableLinkTracking();
} catch( err ) {}
</script><noscript><p><img src="http://mydomain.de/piwik.php?idsite=1" style="border:0" alt="" /></p></noscript>
<!-- End Piwik Tracking Code --></pre>
Piwik is actually installed in a subdirectory &ldquo;/piwik&rdquo; on  mydomain.de. The cause for this problem here is, that I was running  lighttpd and had disabled any file-index.names on that specific domain.  Within the installation of WP-Piwik the default setting  &ldquo;mydomain.de/piwik&rdquo; is not working, but the plugin accepts  &ldquo;mydomain.de/piwik/index.php&rdquo;. At the first moment it looks like the  plugin is doing its job, but the generated JavaScript-Code is missing  the subdirectory in pkBaseURL. In this case, tracking simply doesn&rsquo;t  work.

Sure, it is not an major issue nor is it happening very often but  when you&rsquo;re in this situation it&rsquo;s pretty hard to find the bug. I&rsquo;ve  already contacted the developer of WP-Piwik and as a workaround for now I  can only suggest to enable &ldquo;index.php&rdquo; in file-index.names of your  Piwik-installation.

<strong>Edit:</strong> I've spoken to the author of WP-Piwik <a href="http://www.braekling.de/">Andr&eacute; Br&auml;ckling</a> and he fixed the issue (which was more Piwik-related than a actual bug in the plugin) in not more than 6 days! Revision 0.8.8 is the fixed one and is already in the wordpress plugin directory. Thanks Andr&eacute;, you do a great job!<strong>
</strong>
