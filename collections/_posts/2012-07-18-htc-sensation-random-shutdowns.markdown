---
layout: post
title: "HTC Sensation: Random Shutdowns"
slug: htc-sensation-random-shutdowns
date: 2012-07-18 14:53 +01:00
author: martinlowinski
comments: true
published: true
categories: Uncategorized
tags: 
  - htc
---

This is a nightmare. My HTC Sensation which I got almost a year ago with my mobile phone extension contract is full of bugs.

The _first_ bug: The phone automatically switches from silent to normal/loud mode. Very anoying. Not just for me but also the other students in the lectures. It was obviously a software bug and the next update fixed it fortunately.

The _second_ bug: The touchscreen. Especially when the sensation was charging, the touchscreen had massive issues and was almost unusable. Here's a [video](http://www.youtube.com/watch?v=Bk1BlXZQDrU) showing it. This time, I went to the Vodafone shop and got a replacement unit. Unfornutately, it had the same issues. But okay, I can accept that I can't use it when it is charging.

The _third_ bug: Random shutdowns. Every week or so, I take the phone out of my pocket and it's off. I have been living with this bug for a few months now and am tired of it. There are also a bunch of people having [the same problem](http://androidforums.com/htc-sensation/422583-help-my-sensation-keeps-shutting-down-randomly.html). The first solution was the following:

> I have the same problem and have found a solution for it. The Sensation shuts down when it changes to 2G GSM network. I found this out when I thought it might have something to do with the bad 3G singal in my house, so I changed my phone to 2G only mode and it couldn't stay on for more than 10 seconds. Then I tried to put it on 3G WCDMA only and it hasn't shut down since. It has worked for 5 days now. To change this go to the mobile network menu in settings and change the Network mode to WCDMA only. I'm still going to send my phone to maintenance though.

And indeed, with `GSM only` the phone couldn't stay on for a few minutes. So I tried `WCDMA only` and it worked. But this is not a solution, just a workaround and as WCDMA needs much more power than GSM, I had to look for another solution.

I came across this post (there's also a [video](http://www.youtube.com/watch?v=xXR7Ra3f2LU)):

> First of all I would like to thank all people that have replied to this specific topic, without all your help I would never come up with my solution to the problem. I won't explain how they have helped me, but at least I can tell you my phone kept shutting down about 4 or 5 times per day. I have implemented my solution a week ago and the phone hasn't shut down since.

> If you open up the back cover of the Sensation and you look at the battery, you'll notice that the bottom side of the battery is slightly angled. This causes the battery to not be in full contact with the four pins that are attached to the Sensations case. If you pull the right top side of the battery a little down, you'll notice that the battery will make a better connection with the four pins. So for me the problem was solved by putting something in between the top right of the battery and the casing. I've used a business card (I knew saving those would pay of at one time) and tore of the rest that was sticking out. It's been fine ever since. 

And this is where I really started questioning the skills of HTC. I mean, bugs happen, okay.. I know that (see bug 1 and 2). But seriously, the case for the battery doesn't fit?

Honestly, I was kind of desperate and tried the fix. __It worked.__

And here comes the explanation:

> Now my explanation, although I'm far from being a electrician, is that the battery connection to the case is fine for low power situations. But as soon as more power is required by the phone, like in low connection situations, the phone will loose power and shut down. That's why ensuring that those situations do not happen or rarely happen gives some result.

It worked since, even with `GSM only`. So, thanks guys for figuring it out. And HTC, please test your phones (better).

