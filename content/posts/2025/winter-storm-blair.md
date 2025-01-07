---
title: "Winter Storm Blair As Seen By Trunk Recorder"
date: 2025-01-07
tags: ["random", "homelab", "radios"]
type: post
---

Coming later this month, I have a post on monitoring my Trunk Recorder
installation with Zabbix and Prometheus.  It's written, but released later for
pacing.

In the meantime, Kansas got hit with Winter Storm Blair, which lead to some
interesting finds on my Trunk Recorder Instance.  Other than local fires, this
was the first large scale event that really stressed my recorders and setup.
Every federal and state highway in central and northeast Kansas was closed on
January 5th and 6th, and everyone was getting stuck on the snow and ice: plows,
law enforcement, ambulances, fire trucks, and even tow trucks trying to get
others out.

I won't get sappy because that's not why you or I are here, but I do want to
hopefully highlight how much information is available on these streams in events
like these.  Knowing what's going on, even if it's not a complete picture, can
be an important thing.

Now onto the graph.

This dashboard has a lot, but pay attention to the middle left and bottom right
graph: those are the number of calls coming through my system and getting
streamed out.  The state highway patrol, who was dealing with all the highway
issues, is the green shaded area on the bottom right graph.

![Dashboard](/images/2025.01-SnowStormTrunkStats.png)

There are some lessons I learned and some stats I want to share.

## The number of calls increased ... a lot.

On December 30, my system saw 3170 calls that weren't busses[^1].  On January 4,
that increased to 6208 calls.  On January 5, 7233 calls, and another 7031 on
January 6.  With 5 recorders, we only missed 83 calls in high priority
talkgroups (local police, fire, ems).

This is possible because of Trunk Recorder's `Priority` field you set when
defining talkgroups.  This field defaults to 1, but increasing it requires that
`n-1` recorders are free.  So a value of 1 means 0 recorders must be free
(highest priority) and a value of 3 means 2 recorders must be free.  As the
system contends with more calls, you can skip calls on these lower value
talkgroups and save recorders for priority things.

My policy for setting the priority is to reserve 1 for safety or streamed
things; 3 for things that are far away, low value (like busses), or unknown; and
2 for most everything else.  This seems to work wonderfully, even with 20
talkgroups set to priority 1.  We still ran out of recorders several times, but
we still only missed 0.04% of across the storm.

## A Raspberry Pi is enough.

A big fear I've had is if the little Pi 4 can keep up with these events.  As I
mentioned it hasn't ever had a big, widespread event to strain it.  As it turns
out, it was plenty but not by much.

The memory usage of the Pi has always been close to it's redline.  I got the 2
GB model, and each instance of Liquidsoap takes up a fair amount of memory. This
amount increases as files are played, not much just enough to start to cause
worrying memory usage as multiple audio streams were continually active.  As a
result, I disabled one of my online streams for a county whose traffic I often
don't get reliably anyway.  This is the drop in the yellow memory usage line in
the top left graph.

The CPU was keeping up though, even with all the decoders in use and peaks of
100% usage.  The only issue there was when Puppet would apply changes on its
fixed time interval, which caused spikes and I/O delay that would cause decode
errors.  Disabling puppet during the storm was an easy fix there.

## Scanners that can receive multiple calls at the same time are a must.

Another interesting tidbit is the change from largely single channel operations
to multi channel operations when things get busy.  The highway patrol, which
were by far the busiest talkgroups, usually operates on two channels, but calls
don't overlap often as the single dispatcher will respond to one at a time.  In
this event, both channels were active at the same time.  Add more busy agency
talkgroups on, and a scanner with only one audio stream simply won't keep up.
In the time it takes to listen to one call, 3 others are taking place on other
talkgroups.

At one point when listening to every talkgroup on a single audio stream, I was
over 10 minutes behind.  Having a way to listen to multiple streams at once,
similar to a Broadcastify Dashboard, is a very key thing to have as well.

----

I'll share more about the methods used to collect the graphs and visuals, and
have Zabbix templates for usage in the near future.

[^1]: Our local bus system uses the same radio system as the public safety
    agencies, though on different talk groups, and generate a lot of traffic on
    days they operate.  They call out at each stop, so a good portion of traffic
    is that.  For the sake of this comparison, I excluded those talkgroups.