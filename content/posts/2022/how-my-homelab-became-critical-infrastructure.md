---
title: "How My Homelab Became Critical Infrastructure During a Tornado"
date: 2022-04-30
tags: ["homelab", "personal"]
type: post
---

I recently made a design change to my homelab that paid off in leaps and bounds,
and just secured my homelab as a part of my critical infrastructure during
emergencies.  This change was a pretty simple idea, but recently proved itself
during a recent tornado near my home.

This post will largely be tooting my own horn, sharing why I think this is a
good idea, but will also talk about severe weather and have some pictures.

## The Scenario I Built For

I live in Kansas so severe weather is a part of life here.  Things tend to come
up suddenly, and you have to plan in advance of where to go and what to do to
really be safe during these events.

Other than the basics (like food, water, and a shelter), there's a few things
that I feel are required during these events:

* **Information about the weather.**  This can be a TV, radio, or internet
  stream. Since I don't have cable and I like looking at pictures of the
  impending doom, I like internet streams.
* **A way to communicate with others.**  It's an unwritten rule that when
  there's weather near someone you know you call them to tell them (sometimes
  people get complacent or just aren't aware).  If things get really hairy,
  calling and telling others you're safe (or not safe) or even calling for help
  is crucial.

Depending on the severity of the storm, a number of things can fail that make
getting those two things harder:

* **Power will probably go out.**  Wind snaps poles and trees, and tornadoes
  destroy miles of lines that can take a long while to repair.  If you don't
  have power, you're either without TV and Internet information sources, or
  you're relying on UPS power.
* **Cell phones will stop working.**  Once a tornado warning gets issued, even if
  there isn't a tornado), your cell phone will probably stop working.  I imagine
  the unwritten rule about calling everyone you know comes into play to some
  extent, but winds and lightning probably damage towers to knock them offline.
* Both these services may be down for hours, but the storm may only last a few
  minutes.  Tornados especially are brief events, you may have an hour of
  warning but the damage and danger only lasts 30 minutes or so.  Any backup
  solution should work for at least that long.

## How I Solved It

In the imaginary scenario above, a hardwired internet connection can
more-or-less solve those key problems and work around those key challenges.  As
long as the fiber and cables carrying data are in tact, if I can keep my servers
powered I should be able meet my needs.

In my case, my homelab runs about 800 watts when it's busy.  This is obviously
something a UPS can handle, but getting 30 minutes of runtime for 800 watts is a
lot of upfront UPS cost, and a lot of recurring cost for batteries every 5-ish
years.

Low power homelabs are also a thing, but in my case I didn't want to outright
replace all my hardware, and low power things wouldn't be able to handle some of
the more intense tasks I have.

My idea was to combine these two ideas.  Have a small "core" network that gives
basic internet access and communication that can run on a more affordable UPS,
and have the extra things poweroff quickly like normal.

## Enter: Stellar

The idea I had was to create a new low-power node that would be able to run
(along with low power switches and modems) for at least 30 minutes on a UPS.  I
used an old Celeron J1900 board, and this node draws less than 30 watts
full-tilt.

I have backup copies of my core services running on it, and when the main lab
goes offline Stellar will take over and run these services in a reduced
capacity.  The point here is _just_ to have communication and information.
Services like Plex, build servers, backups are all really nice, but not
critical.

Stellar (named for a Stellar Core of a star) runs its own Proxmox installation
and isn't clustered with the main lab.  This is done so when 3 nodes of what
would be a 4 node cluster go down, Stellar doesn't feel the need to fence
itself.  The services then just use VRRP, CARP, or other HA protocols to detect
when their peer is down and change over.

Between Stellar, my access points, security cameras (fun for looking outside to
see things, but not critical in this case really) the main switch and modem,
it's about 150 watts.  I'm confident my old Cisco switch is 100 of those watts,
and I plan on replacing it soon.  On a 1000W UPS from office depot on old
batteries, it gets 30+ minutes of run time.

## How it Paid Off

On April 29, a tornado came very close to striking my house.  This picture was
snapped about a mile away and is looking in the direction of our hose.

![Tornado](/images/2022.04-Tornado.jpg)

When we got the warning, everyone in my house went to the basement, we turned on
the weather, and we started watching it get closer.  As it got near, it took out
the power to the house as expected.  The main lab continued to run for about 10
minutes and did a clean shutdown as is expected, leaving Stellar and the core
behind.

The tornado passed in another 10 minutes or so, and thanks to watching the
weather streams we were able to confirm we were safe.

As expected, cell service also failed at that time.  Thanks to Wi-Fi calling and
a SIP phone, we were able to call our family and also let them know we were
safe.  Probably not critical that we're able to do this, but its nice not to
raise my parent's blood pressure or worry.

After about 30 minutes from losing power, the weather was clear again but the
power was still out.  I called my family to let them know my phone is going to
cut out (I couldn't make or get calls with any reliability without Wi-Fi).  The
UPS for Stellar cut out shortly after, but we were safe and it had done its job
_perfectly_.

## Conclusions

If I can part some knowledge on other homelabbers, it's this:

* Have a plan for emergencies.  Your homelab might very well be able to solve
  tangible problems during these emergencies!
* Take stock of what is really needed when fecal matter hits air circulation
  devices.  Do you need Plex? Owncloud? Just basic Internet?  Understand what
  you need to run these critical services.
* Take offsite backups, and make sure they work.  We were close in this case,
  but a few thousand feet and our house would likely be gone.  Computers are
  replaceable, but the information they store may not be.  Having an offsite
  backup of critical documents, family pictures, etc would be the only option if
  things get leveled.
* Set this up before hand.  When things are going pear shaped is not the time to
  be making config changes or trying to fix things.  If you plan on having a
  failover plan like this, test it before hand so you can focus on other
  important things.

In my case, this setup is only going to get perfected and will always be a part
of my lab.  Stellar made a stressful situation much less so, and it will always
be worth the setup trouble just for this one incident.
