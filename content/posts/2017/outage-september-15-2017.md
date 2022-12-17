---
title: "Outage September 15 2017"
date: 2017-09-15
tags: ["dev-ops", "lessons-learned"]
type: post
---

Today, The Storehouse experienced an outage that lasted approximately 12 hours.
This was caused due to updates performed late the night before and services
restarting during that process.

Last night I ran upgrades of the servers that run The Storehouse, including our
three ProxmoxVE nodes.  When the upgrades on these nodes were complete, the
nodes had an updated kernel version and needed to restart to use the new kernel

Restarting is usually a painless process in our environment.  Since the nodes
are built with redundancy, one can be rebooted or offline at any time without
disrupting service.  Usually, we perform the rolling upgrades in the background
and Storehouse customers see no disruption of affects on services.

The nodes also co-host a GlusterFS volume that we use for customer data and a
few critical virtual machines.  We run two pfSense routers as VM’s and store the
disks on there to allow the routers to migrate between nodes.  These routers
(like most) are critical: without them our environment is not accessible to the
outside world.

When restarting the PVE hosts for the upgrade, I do them one at a time with a
delay between each to allow the Gluster volume to heal.  Last night when I went
to upgrade nodes, I did not wait long enough and the volume was not fully
healed.

This wasn’t an issue with customer data, since no customers were uploading data
during the upgrades.  The router disks, however, became inconsistent and both
went offline around midnight.  When both went offline, the outage began.

Our monitoring system alerted me to the issues, but I slept soundly through the
alerts.  Due to scheduling issues in the morning, I was unable to return to the
data center until 12.  At that time, the routers were restored from backups and
restarted, restoring service.

## Lessons Learned

### 1. Get a backup connection

One of the reasons it took so long to restore service was that I was unable to
travel to the data center to physically connect to the network.  The system
relies on at least one of the two routers running at all times.  When both are
offline, a trip to the data center is required to fix it.  While this isn’t a
big deal, it takes extra time to pack and travel, and requires that I am free
and able to travel.

### 2. Check GlusterFS during rolling upgrades

If I had looked at the Gluster volume status, I would have noticed the
inconsistent files.  This isn’t an issue, as Gluster automatically will heal the
files, but both nodes need to be online to do that.

### 3. Get better night monitoring

It certainly didn’t help that I slept through the alerts streaming into my
phone.  The monitoring system was working perfectly: our offsite poller noticed
the outage and was quick to alert me.

All in all, human error caused this outage.
