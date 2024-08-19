---
title: "Fixing Infinite Shutdowns in NUT"
date: 2024-08-18
tags: ["random", "how-to", "linux"]
type: post
---

I recently figured out a solution to a problem I've long been battling.  When
rebooting a server after it's forced to shutdown to losing power and the UPS
battery running low, it'd enter a cycle of starting, starting the NUT service,
then immediately shutting down.

## Symptoms

There were a few clues that you may see on your environment as well:

The issue manifested as nodes powering off as soon as they start after a power
outage.  They'd start, boot fully, then in about 30 seconds shutdown again.
This seems like it may have been hardware, as I don't sit and watch machines
boot usually (I push the power button, then come back in 15 minutes to actually
unlock drives), so coming back to see a dead machine was alarming.

The big culprit is seeing `nut-monitor[4162]: UPS liebert@nut:3493: forced
shutdown in progress` when booting the machine, and the machine doing an
immediate clean shutdown.  This is the smoking gun, as it indicates the
`nut-monitor` process started and found the UPS to already be calling for a
shutdown (we'll get to why it enters this state shortly).

The shutdown only occurs when the node is connected to the network and talking
to the NUT daemon.  If you stop the daemon, disconnect the network, or
disconnect the interface for the UPS the node won't reboot until the
communication is established (though, stopping and starting `nut-server` will
"fix" the problem).

What didn't matter, though, is the state of charge for the UPS.  I assumed at
first the UPS was still below it's low battery cutoff and was triggering a
shutdown that way, but even with a 100% charged UPS it still had issues.

## The Cause

The cause is sinister, but harkens back to [my two-tiered backup
power](https://grumpy.systems/2022/how-my-homelab-became-critical-infrastructure-during-a-tornado/)
configuration.  The tldr is that I have to pieces of my network: a power hungry
part that runs all the big services, then a small core that can stick behind in
a power outage and provide Internet, security cameras, and now even broadcast TV
on your phone.

The NUT server for my network runs on this core piece and monitors both UPS
units.  This works, but exposes a design in NUT that isn't immediately obvious
without the two tiered setup:

> Please note that by design, since we require power-cycling the load and don’t
> want some systems to be powered off while others remain running if the "wall
> power" returns at the wrong moment as usual, **the "FSD" flag can not be
> removed from the data server unless its daemon is restarted**. If we do take
> the first step in critical mode, then we normally intend to go all the
> way — shut down all the servers gracefully, and power down the UPS.

(emphasis added)

What this translates to is that since our NUT server has the FSD flag set on the
UPS running the high power stuff, when it comes back online it sees this
latching state and immediately powers off thinking that it came online during a
power outage.  Since we aren't restarting NUT (since Stellar doesn't power off),
this flag is never unset.

This was brought to light even more recently, as I've added a power station
inline with the Core UPS, giving it 3+ hours of runtime during an outage.

## Fixing It

To fix it, I just moved the NUT server for that UPS onto one of its protected
loads.  When the power fails, that machine will power off and implicitly reset
the FSD flag for the next boot.

You can also just do `systemctl restart nut-server`, but this would require
logging in and wouldn't be an option should you need someone less technical to
start things again.
