---
title: "Reviewing T-Mobile's Backup Home Internet"
date: 2025-03-14
tags: ["homelab", "reviews"]
type: post
---

For the past few months, I've been test-driving T-Mobile's Backup Home Internet
that's based on their cell network.  The experience so far has been ... fine,
but I wanted to share some quirks and my experience so far.

None of this review is sponsored in any way.

## What The Backup Plan Is

T-Mobile offers a plan for $25 per month ($20 when on autopay) where you get
130-ish GB of data for times when your primary ISP is down.  This is a pretty
niche product, but for people like me that work from home having redundancy
means the difference between riding out and outage or taking a day of vacation
due to Internet issues.

I had a previous solution based on
[4G](/2022/setting-up-a-backup-4g-internet-connection-with-opnsense/) and this
solution worked really well for a number of outages.  I'm upgrading not because
it's not working, but because it's almost perfect.  A bit more speed with 5G
would make things even more smooth, and given the low cost of entry I gave it a
shot. If you're following along at home, the setup is identical but instead of
using the 4G GL.Inet modem, I use the provided T-Mobile modem.

## The Good: Service

So far, the service itself has been quite nice.  I now live in an area with
multiple Fiber ISPs and a Cable ISP, but I opted for the 5G solution for a few
reasons:

* **No Digging** - Not having to dig for a new drop cable was a big plus.
  There's still coax in the yard, but it's been damaged and so shallow it's not
  suitable for a new service.  Running more fiber would mean more headaches
  finding sprinkler pipes and holes dug in my yard for the eighth time.
* **Path Diversity** - In the event of a North American Fiber Seeking Backhoe
  making its way into my neighborhood, having a secondary path that bypasses the
  common trunk of cables along the street should (hopefully) bypass breaks.
* **Cost** - The Backup plan is the cheapest service I can find.  Even basic
  plans from other providers were nearly double this plan.  Cancelling an unused
  subscription elsewhere covered the cost.

Signing up and getting the equipment was quite easy too.  I had to call due to
some issues on my end with the website, and the rep on the phone was pleasant,
though he did have to read the terms and conditions in all their glory to me,
which neither of us enjoyed.

The equipment was then shipped with 2 day shipping and arrived that week.  We'll
get into the equipment.

Using it has been fine as well.  My testing shows a 200+ Mbps down and
about 30 Mbps up, which is more than enough.  I haven't seen packet loss or
major latency spikes as well, everything seems pretty stable at about 50ms ping
to 1.1.1.1.

With a traffic shaper in OPNSense, you hardly notice the changeover.

## The Bad: The Gateway

Don't get me wrong, the _hardware_ of the gateway is fine.  They sent the
Sagemcom Fast 5688W gateway, which is about the size of upended toaster and
comes with a very long USB-C type power cable.  It has an LCD that tells you the
signal strength, and the phone number that is provisioned (interesting), lets
you read the text messages sent to that number (mostly automated account texts)
and a few other screens.

My main gripe is the lack of any sort of configuration available.  You can
change the WiFi name and password or change the Admin password which you never
have to enter thanks to the T-Life app.  There's a web interface, but it's just
a status page.  You can manage some basic client options in the app, such as
setting schedules or blocking internet access, but again it's quite limited.

Noticeably, you can't set any LAN network settings, such as a network ot use or
DHCP reservations.  There's no ability to port forward or adjust the firewall
(thought it's CG-NAT anyway).  For someone trying to integrate it into a larger
network solution, it gets annoying how little you can change.  There's no
advanced mode, bridge mode, etc.

In my case, I just adjusted the network my routers use on the old 4G interface
to live in the `192.168.12.0/24` network the gateway uses, and since there's
nothing else connecting to the WiFi, I assume I won't have an address collision.
Setting those routers to NAT lets outbound traffic work, which for my backup
internet works well enough.

## That's The Use Case Though

Overall, I can't be too displeased though.  The device works for my use case,
it's free with the plan, and it was quite simple to plug in and set up.  Sure,
more customization would be nice but the cost of a new hardware modem and then
the labor of fooling T-Mobile's network to accept it just doesn't seem worth it
right now.

If you approach this device as a router for someone who considers Routers,
Modems, and WiFi all the same thing it's perfect.  You plug it in, it helps you
find a tower, you set a password and you have Internet.

If you're approaching this for use in a homelab or business scenario, though,
this gateway isn't the right choice.  Higher tier plans do have different
gateways available that might not have the same limitations, but I haven't tried
them.  If you do use one of these, just know that services like Cloudflare
Tunnels or Zerotier are going to be your friend to establish inbound
communication without a public IP.
