---
title: "Cleaning Up Firewall Rules"
date: 2023-11-07
tags: ["homelab", "how-to"]
type: post
---

One project I recently invented for myself is cleaning up my jumbled mess of
firewall rules.  The issue is that as time has gone on, I've created more VLANS,
which has led to more rules that I've never really formally organized.

It finally reached a tipping point, and after some experimentation, I found a
new system that improves my security and makes things much more simple.

## My Problem

The main issue here is that I have a lot of VLANs in my network.  Things like
IoT devices, servers, home automation, and trusted LAN devices (and more) are
all kept separate on my network, and only things that have a need to communicate
can.

Since I lack any L3 switching or anything fancy, this has translated into my
OPNSense firewalls having about 10 interfaces each.  With these 10 interfaces,
there now needs to be rules to prevent, say, the IoT network from talking into
the LAN network.

### Version 1 - Inbound Rules

My first solution to this problem was to use the normal OPNSense "in" rules, and
create rules for each interface.  To continue my example before of blocking IoT
from talking into the LAN, I'd create a rule on the IoT network to block this,
and repeat for each interface and network.  This lead to about `n^n` rules, as
each interface had just as many rules as interfaces to accomplish the default
blocks.

This setup had a lot of issues:

* **The setup for each new VLAN required a _ton_ of work.**  That VLAN needed
  it's spattering of rules, and each other interface required at least one new
  rule as well.  This led to a few cases where rules were missed or omitted,
  leading to holes in my security.
* **Rules for the LAN interface weren't on the LAN.**  When trying to get a
  feeling of what rules were set up for an interface, I'd have to scan all the
  other interfaces.  This made things more complex and much less clear than it
  should be.
* **There's a single point of human failure** This kinda is the same as the
  first point, but in this setup, I'm relying on a ton of individual rules to
  block traffic.  It's much harder to set up and maintain 50 rules and check
  them than creating one omnibus rule.

### Version 2 - Floating Rules

My first attempt at improvement was to move to floating rules.  I created two
per interface: one that allowed certain exceptions into the network and one that
blocked everything else.  Using aliases, I could keep things pretty clean and
tidy for a while in the rules screen.

We had some pros and cons on this setup:

* **Pro: Less rules**  This reduced my exponential rule growth to just a few
  rules per interface.
* **Pro/Con: Rules in one place** Since floating rules are all on the same page,
  it's easy to see what rules are set up.  However as things grew, the list of
  rules on the single page became too much.
* **Con: Last Match** Because the interfaces sometimes had extra rules beyond
  what was a floating rule, the floating rules all needed to be last match.
  This, again, just made things more complicated than they needed to be.

## Out Rules

Wanting to separate rules onto interfaces where they work became a new goal as
the number of interfaces continued to grow, so I was left with trying to
organize things yet again.  This time I discovered a slick solution in Out
rules.

These operate a bit backwards than the normal way of thinking.  We tend to block
traffic as it comes _in_ to the firewall, but an out rule (as the name implies)
filters it on the way _out_.  This change seems minor, but allows us to now
create rules that block traffic to the LAN network and have them appear on the
LAN group of rules.

This translates into a few set rules for each interface:

* The exception rules that allow otherwise blocked traffic through.
* A rule to allow traffic from the firewall (more later).
* A global block rule.

This looks mostly the same, with the exception of the added rule to allow
traffic from the firewall.  Since we're filtering things on their way out, the
firewall itself is now in the crossfire.  Without this rule, OPNSense wouldn't
be able to initiate any traffic, which is needed for a few different services.

Alongside making the rules easier to understand, this also removes the potential
gap of adding interfaces without adding a new set of firewall rules (and cuts
down on the number of new rules needed).  If a new VLAN shows up and it hasn't
been allowed into a protected network, it won't get in without intervention.

### The Real Winner: VPN Links

The place where this really shines is with remote VPN networks and rules.  I
don't rely on the remote firewalls to do any filtering (they all do, but I write
rules assuming they aren't), so I need to rely on In and Out rules to filter
things.

Everything across a VPN link is blocked by default, so using combinations of In
and Out rules, I'm able to block any remote VPN network from talking to things
they shouldn't with an In rule, and block devices on my local network from
talking to remote nodes with Out rules.

## Network Security Is Hard

Half of the problem with network security is fighting the urge to take the easy
road and allow traffic to flow freely.  In a lot of cases, that's fine, but part
of the goals of segmenting my network as much as I do is to keep devices in
networks with the minimum level of access required.

There isn't a lot of reason for an Amazon Alexa device to talk to my network
share, and keeping them isolated limits the reach of any future compromise or
rouge firmware update.  Having tight and easy to manage firewall rules is one
part of my strategy to keep everything where it needs to be, and nothing more