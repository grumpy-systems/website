---
title: "I Double NAT My Network, And I'm Proud"
date: 2022-06-08
tags: ["homelab", "how-to"]
type: post
---

I double NAT my home network.  And the funny part is I _designed_ it that way.

Let me explain.

## Why This is Bad

If you're a network person, you've already groaned.  If you haven't groaned, you
probably should.

Network Address Translation (NAT) is a service that most consumer routers
perform by default.  Essentially, it's what lets you connect your privately
addressed network to a publicly addressed network and have things work.  It
takes the private addresses and translates them into the correct public address
before sending it along.

Double-NAT is typically viewed as a bad thing.  Essentially, you're
double-converting addresses on their way in and out of your network and blocking
a _ton_ of visibility for devices.  Alongside this, there's issues with
management and port-forwarding that tend to make this a very undesirable
"feature" of a network.

If you want know to more, read up on
[NAT](https://en.wikipedia.org/wiki/Network_address_translation).

## What I'm Trying to Solve

I work from home, so a reliable internet connection is essential for me to work.
My ISP recently had a few outages that lasted days, so this naturally disrupted
my job and was the source of great frustration.  I set out to "optimize" my
network and made some plans for expansion.

Really, these are the two problems I wanted to solve:

* **Allow for a redundant connection** - My phone plan has free data and free
  data sim cards, so getting a 4G modem as a backup is actually a pretty cheap
  option for me.  My plan is to get such a modem and pipe it in as a backup
  connection to step in when my main ISP fails.
* **Redundant Routers** - I needed this for two reasons.  First, I want the
  redundancy for when stuff breaks.  But I also wanted to run IDS and some more
  intense firewall tasks on my router, but I don't want to overwhelm the new
  [Low Power
  Node](/2022/how-my-homelab-became-critical-infrastructure-during-a-tornado/) I
  built.  The plan is to have a nice primary router that has all the firewall
  stuff turned on, and a second node for backup operations.

The hard part with this was that with the residential ISP I have, switching
between two routers is not very straightforward.  These modems assume you only
have one router, so they lock on to the first MAC address they see and only give
their IP to that MAC address.  If you want to failover here, you'll have to
spoof MAC address or power-cycle the modem.

The other challenge is that I wasn't really interested in more physical routers
for my setup.  They make devices that run your firewall of choice, but these
devices are a black-box to me: if they break you buy a new one.  They might have
_some_ serviceable parts, but they're usually no-name boxes that are re-branded
so documentation is likely sparse.

## The Prototype That Sorta Works

So the first version of my network I came up with was what I'm dubbing the
"Hybrid Loop".  It didn't really solve either of these problems though.

![Version 1](/images/2022.06-networkv1.png)

Here, just the Edge Gateway is doing NAT (indicated by the `*`).

In the normal state, the gateway forwards traffic to the firewall, which then
passes it into the LAN (and other subnets, I've excluded those from all my
diagrams).  If the main firewall fails, the traffic can talk to the gateway
directly and still egress.

There are a lot of problems here:

* **Failover never worked.** - The edge gateway is a Ubiquiti device and my
  firewall was pfSense, so there was no slick failover.  I could fail the IP
  over with VRRP, but DHCP and all the route states would be dropped.  This is a
  pretty big blip when it occurs, and never went right.
* **Single Point of Failure** - The edge gateway is crucial to all of this.  The
  firewall is a VM, so I can't pipe it directly to the modem easy in the case of
  failure.
* **Can't add failover internet** - I mean I _can_, but again it's a big single
  point of failure here.
* **Did I mention failover?** - If the firewall VM rebooted, migrated, or
  anything that took it offline for more than about 10 seconds the entire
  network felt it.  This failover was not graceful and usually killed about
  every active session for 10 minutes.

I had a few variations of this I thought about as well but never implemented,
namely to replace the edge gateway with a compatible firewall to my VM so
failover would be "better."  I put better in quotes because CARP was not
designed for that setup at all and I would have had a whole new set of
challenges.

This setup worked though, at least worked in the sense that it gave me internet
and worked for a year or so.

## Version 2 - Almost There

So the problems above were related largely to my edge gateway trying to be
something that can fail over too.  It was a single point of failure that just
seemed to be pretty inflexible.

The solution I came up with was to create a new DMZ network that sits between
everything:

![Version 2](/images/2022.06-networkv2.png)

Is this overly complex? Probably.  Let's dive in.

So the idea here was to create some device that the cable modem can see to make
it oblivious to the double routers ahead.  The cable gateway is just a small
Edgerouter X that does this job.  This device has to NAT more-or-less, since the
modem gives out a single public IP and wants a single MAC.

This new DMZ network is privately addressed, and gives both the firewalls a nice
place to live.  This way I can run a pretty vanilla CARP setup with VRRP and all
the bells and whistles.  The firewalls are configured with multiple gateways,
and if it detects the cable connection is down, it just switches over.

Likewise, if a firewall fails, it fails over in short order with minimal drops.

This also gets rid of my single points of failure, since the cable gateway isn't
_really_ required anymore, if it fails I just fall back to cell service.

## Enter the Double-NAT

This isn't perfect though, specifically with port forwarding and firewalls.

So the edge gateways can directly talk to all the devices on the LAN which is
good, but that means that I need two firewall entries now: I need to add the
entry to the edge and to the firewall.  I can't disable the firewall on the
firewalls, as I need them for inter-vlan routes, so I'd be stuck with this setup.

For static ports, this isn't a huge deal actually, it's double entries but
do-able.  The problem's really when you want to play any console games.

My Nintendo Switch and PS4 rely on UPnP to dynamically port forward things.  The
issue is now I'd need double UPnP in this setup: one for the firewall and one
for the edge.  You _can_ work around this, but you basically have to blow a hole
in your firewall (literally, Nintendo's help site says to forward several
thousand ports to your switch on the off chance one is used).

To prevent having to double-enter everything and to account for dynamic ports, I
figured I'd just setup some cath-all rule to forward everything along at the
edge and disable the firewall.  The main firewall is still filtering things, so
there's not a lot of additional risk. Home routers call this a DMZ, but it's a
destination NAT rule and firewall rule that just blindly forward traffic along
with no regard. 

When you set this up, you need a single IP to forward to though.  Port
Forwarding isn't super smart so it needs to know where internally to route
stuff, and this has to be a single IP.  But since the edge can reach all the
servers by IP, what IP do I put in?  If only I could combine them all behind the
firewall somehow.

Something like .... NAT?

Yeah, exactly that.  If the firewalls _also_ NAT, the edge can just blindly
forward things to the firewall, and it'll sort it out.  This is actually a great
solution, as it un-breaks UPnP for the game consoles, gives me a single place to
do firewall rules, and doesn't really open anything else up as everything gets
sent to one fixed address.

## Please Don't Be Upset

I know the network engineers out there are crying, and I'm sorry.  Yes, I'm sure
there's a performance hit but the edge and firewall are overkill enough that I
don't feel it.

I've just put the finishing touches on the config, but so far things look just
fine actually.  I'm sure I'll change it all in 8 months again anyway.
