---
title: "How A UDM Pro Saves Me $35 A Month"
date: 2025-10-25
tags: ["random", "homelab", "lessons-learned"]
type: post
---

This is a rambling tale about redundancy, understanding needs, and the sunk cost
fallacy.

After upgrading my router to a Unifi Dream Machine Pro, I was able to
comfortably eliminate two aging servers from my stack and save several hundred
watts of power in the process.  I did this for a number of reasons, but after
some reflection I'm more confident in my set up even with less redundancy now.

## My Old Setup

My router used to be a virtualized OPNSense router that lived on a Proxmox
cluster.  Since the router was crucial for things to operate in the house,
having some form of redundancy was paramount, and for years that redundancy
looked like a Proxmox cluster with three nodes.

The main goal was to avoid a single point of failure in this key path, as I've
been burned by hardware routers letting out magic smoke at the worst times
possible in the past.  Having the redundancy here, and a bit upstream with
gateways, made it to where I could tolerate nodes failing, drives failing, etc
without more than a few minutes of downtime.

This setup worked fine for a long time, and performance was always acceptable.
I was able to reboot physical nodes and account for the occasional failure
without much fuss.

## What's Changed

All this started to show it's shortcomings in the last year, and for a number of
reasons.

First, I changed ISPs and I'm now able to both overwhelm the router.  Before my
ISP was only able to deliver 300mbps of my 1000mbps connection (I complained
[here](/2024/ramblings-on-shitty-consumer-internet/)), so the router never sat
being nearly saturated with traffic for more than brief moments. Since changing,
though, things like game updates would have a noticeable impact on the rest of
the network.  The machine would get behind, then latency and packet loss would
increase and impact remote desktop sessions or meetings.

I also was running into ... quirks ... with trying to keep a low power router on
standby.  My setup has a low-power segment that is intended to keep things
running during an outage, but this meant running a second OPNSense machine on
that node.  The second node was not enough to be the full-time router, but some
services like DHCP have a noticeable gap between failover.  Traffic flows, but
new devices or devices trying to reconnect had to wait several minutes.

With just those two factors in mind, I decided the time was here and I bought a
new UDM Pro to act as the primary router.

## The Bigger Lessons

During the migration I took the approach of doing things the "right" way, so
nothing was sacred.  Every cable, VM, disk etc was checked on how it could be
cleaned up and this led to some greater insight.

### The router machine was big.

I hadn't realized how much room I left for the router because it had become so
sensitive to CPU and Memory pressure on the host.  There may have been tuning I
could have done to improve this, this could be due to network level factors, but
regardless nearly 1/3 of a single host was devoted to just my router.

On a whim, I tried an experiment: I shuffled RAM around and built one server
with 2 CPUs and 96GB of memory and put all my VMs on it.  My expectation was
that the node would fall over in an day or so, and other intensive tasks would
fall behind.  To my surprise, though, the node has kept up for months now
without any major issue.

### I didn't actually use HA.

High Availability sounds really nice on paper and in a lot of environments it's
crucial, but I never really made use of it.  I only had a few minor hardware
failures in the last few years, so the increased hardware redundancy was never
really used, outside of RAID.

Even during updates, I found that a few minutes of downtime is fine.  When doing
updates I also didn't bother migrating machines and doing roling restarts; I'd
just hit the reboot button on the entire node.  All my machines are based on
Debian and I updated them at the same time, so when one needs rebooted they all
tended to need a reboot.

In the past, I did have a few applications that _had_ to keep running for weeks
on end to complete a process or risk starting over.  In those cases, HA and
being able to live migrate machines is a must.  Most of these have since been
migrated out for a number of other reasons, leaving no good reason to continue
to maintain the overhead of HA.

### I still have redundancy.

Part of the fear of making this change was losing redundancy in my network.
I'll admit I'm more vulnerable to a single hardware failure with the UDM being
the capstone of my network now, but other changes and planning are mitigating
those issues as well.

In the event of a total outage, I now have a fairly acceptable 5G connection.
It's not perfect,and not great for long term, but I can change my laptop and
access documentation, support sties, and the like for a few days if needed.
With the now unused edge router and some light configuration, I can also even
get things like the required VLANS for the normal Unifi WiFi working.

In the event of a hardware failure on the server, the critical items can move
around between the low power and main node still, but the fear of living without
a build server for a few days is much more tolerable than living without a
working network at all.

### Simpler is better.

As other priorities in life come up, and my homelab becomes more and more like
homeprod, I'm starting to value things that either just work or that take
complexity out of what I need to manage.  Running a hyperconverged cluster
complete with a few dozen TB's of Ceph OSDs, Proxmox's HA, and just the general
balancing act of migrating machines around takes time.

To be clear, none of what I ran was unreliable or didn't do what it expected, it
just became features (and CPU and memory and, by proxy then, money) that I
didn't use but had tangible impacts on the complexity of most tasks.  Upgrading
Proxmox took time when Ceph needed upgrades, virtual machines took performance
hits with Ceph's network overhead, Ceph OSD's really didn't like the RAID
controllers I ran and would fail when I was at airports, and all for features I
never really made use of.

Sure, diving headfirst into Unifi and translating my problems into the right
questions to ask and shifting my way of thinking took time and effort, but in
the long run it will be less effort to maintain.

## The Money Saved

At the end of all of this, I removed two large R710 machines from my 24/7
environment.  Doing some quick math with my power rate, I'm estimating these
used about $30-35 of electricity each month, and with rate increases getting
approved that number will only go up.
