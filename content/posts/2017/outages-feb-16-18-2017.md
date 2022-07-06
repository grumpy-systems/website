---
title: "Outages Feb 16-18 2017"
date: 2017-03-01
tags: ["dev-ops", "lessons-learned"]
aliases: [
    "/2017/03/outages-feb-16-18-2017/",
]
---

So I’m a human, and I have outages.  My goal is to be more transparent, not only
with my customers, but with myself about why the outage occurred and what I can
do to keep it from happening again.  From February 16 to 18, Storehouse had a
few intermittent outages that lasted anywhere from 1 hour to 3 hours.

So this post is long overdue, heck it’s even March now.  I don’t have a good
excuse for the delay: I know what caused the outages and had taken corrective
action but I simply put off writing this.  Perhaps the S3 outage yesterday
refreshed my memory.

## Sequence of Events

To understand the outage, it helps to have a basic overview of our environment.
We run 3 servers in a Proxmox VE cluster and run all of our services in
containers and VMs on that cluster.  Each node in the cluster has a local SSD
and mounts a co-hosted GlusterFS volume that stores the bulk of our data.

One of the weak points has always been that VMs are stored on the SSD and not on
shared storage, so live migration and HA aren’t possible since the VM data has
to be moved to the new host.  This has always been a source of heartburn, since
certain VMs aren’t doubled up they could go offline with a node and not be able
to be brought back online if the node is offline for an extended period.  To
combat this, I started to migrate a few VMs to the GlusterFS volume and test the
HA features of Proxmox.

Things went well and the machines seemed to behave without any issue, so I
started to migrate more.  On Thursday the 16, we started to migrate two of the
heartburn inducing nodes to Gluster: our Zabbix monitoring server and a private
hosted server that hosts this site among other things.

This is when stuff really started to go sour, since I severely underestimated
the disk activity on both of these machines.  Migrating them from an SSD to
Gluster introduced quite a bit of load on the Gluster volume.  This caused the
VMs on the Gluster Pool (now all the important stuff) to become unresponsive,
including our monitoring server.  Monitoring doesn’t sound like a big thing to
lose, but during all this flying blind certainly didn’t help.

Since the VMs became unresponsive, the Proxmox node had to be restarted in order
to kill the processes.  Keep in mind, I hadn’t realized the folley of the
Gluster migration, so I began rebooting nodes as a fix for the symptom of
unresponsive VMs.  Nodes would restart, but the VMs would become unresponsive
again, leaving me back at square one.

Alongside this an issue developed with the Proxmox HA agent on the nodes perhaps
related to the stuck VMs.  This would cause nodes to now restart on their own,
since the HA agent would time out and fence the node.  During this time on
Thursday, one node failed to come back online at around 11:30 at night.  Since
all VMs had been restarted I didn’t give it the attention it quite deserved and
decided to fix it the next day.

Friday morning came and the node was still offline, but more VMs had frozen on
another node.  I decided to reboot that node without bringing the already
offline node back online, which made the cluster not quorate.  This made the
last node fence itself and brought all VMs offline at around 8:30 AM.  The
cluster was brought back online within a few hours and the outage ended.

On Saturday I went to investigate things further and falsely assumed that the
nodes were having some kind of memory or thermal issue that was causing them to
reboot.  I took a node offline and started to inspect it, running memtest which
took a few hours.  In the process of bringing that node back online, one of the
remaining nodes rebooted and took the cluster offline once again.  When bringing
nodes back online, I moved them back to SSD storage and this appeared to solve
the issue.

## Lessons Learned

### 1 – Test Environments Better

This whole ordeal was started by migrating very disk IO intense VMs to a
under-performing network file system.  Had I ran better testing, I could have
caught this and not migrated those nodes.  This not only means testing potential
changes, but bench marking current platforms to see exactly how much capacity is
left.

### 2 – Don’t Ignore Node Failures

The first outage was caused by me foolishly restarting a node when the cluster
was already without a node.  Since I couldn’t make it into the datacenter to
investigate directly, I thought this would be the next best option but in fact
was a very poor choice.

So in the end it was a few mistakes that lead to this failure.  No one to blame
but myself, and that’s OK.  The important thing, with most things in life, is to
take the lessons learned and use them in the future.  That’s kinda the point of
this post: more as a reminder to myself of what not to do more than anything
else.
