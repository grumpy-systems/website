---
title: "Load Balancing With pfSense"
date: 2016-09-01
tags: ["dev-ops"]
type: post
---

I’ve been using pfSense in production for a number of years.  What started out
as a casual exploration of alternative firewalls years ago has blossomed into a
real love of pfSense and the power it offers.  Being a software based firewall
gives lots of features out of the box, including built in load balancing.
Although load balancing in pfSense doesn’t get much hype, it probably should.
It solves a unique problem in a very effective and reliable way.

One of the things I ran into with Storehouse early on was the question of
reliability.  From the beginning, I’ve built the architecture to be
shared-nothing and N+1 whenever possible.  One crucial component of this is a
load balancer, or a device that sorts traffic to a pool of hosts to both
distribute load and build a level of fault tolerance.  With common applications
such as a web server, there are lots of software packages like nginx and apache
that can handle your load balancing.  One challenge Storehouse presented was the
need to load balance SSH, something that doesn’t have an a clear cut solution
like HTTP traffic.

My original solution for this was to use Round Robin DNS, essentially sthse.co
resolved to two addresses: 205.196.125.63 and 205.196.125.67.  When you
connected and asked the nameserver for an address, it would reply with one of
those two and you would connect.  This worked, but had a few drawbacks.  The
biggest was that this couldn’t automatically failover, meaning if a SSH host
went down I would have to update the firewall to forward traffic to the node
that is up.  This never really sat too well so I always kept an eye out for a
better load balancing solution, which I found in our pfSense firewall.

## Not Much, But Well Deserved, Hype

To be honest, I didn’t even know pfSense had a load balancer built in until I
was poking around in the settings and found it in the service menu.  It’s not a
feature that comes to mind right away when picking pfSense, but it really should
be.  I’ve found the default load balancer to be excellent in handling traffic.
It balances well, keeps a user talking to a single host (a consideration with
SSH), and fails over without delay.  Since we already pfSense, enabling it was
no big deal.  We set it up to automatically balance traffic coming in on our
virtual IP’s to the correct server based on the port.  Since the processing is
done in the firewall, there isn’t any additional machines or setup to do on the
network.

An important ability is for pfSense to reroute traffic once an application
server (the server you talk to after the load balancer) fails.  I ran a few
tests, but I don’t have the means to set up a better environment and compare it
to other solutions, so these results should be taken with a grain of salt.  I’ve
found failoverto take just a few miliseconds to not only detect a down node but
to reconverge.  I tested this by abruptly stopping one of my application servers
to see how quick pfSense would detect that it was down.  Using the default ICMP
monitor, pfSense knew it was down before I could even make it over to refresh
the page on the firewall.  This means that I can, in theory at least, fail over
heavily utilizied links with dropping just a few requests.

The other major feature that makes pfSense so wonderful is it’s ability to fail
over, including the load balancer, to another host on failure.  This isn’t the
same as failing over a service to a new host, this is failing over the entire
load balancing operation.  This means with CARP, you automatically get a
redundant load balancer without having to configure anything.  This fails over
just as fast as pfSense (a few packets, not a few seconds) and keeps everything
lined up since it syncs everything automatically.

I still can’t get over how awesome this is:  I can have redundant firewalls with
redundant load balancers sending traffic to renduant application servers with
everything failing over in a matter of miliseconds.  That’s at least N+1, closer
to 2N redundancy without any expensive equipment or any proprietary software or
protocols.  There’s no software to install on the pool nodes and virtually no
configuration.

## Speed is Killer

One of the great things I love about this setup is its speed.  It only takes a
moment to detect a failure and adjust accordingly.  This blows any solution that
relies on VMWare’s or Proxmox’s HA software to detect the failure and restart
the machine.  Since those have to wait for the node to go offline, confirm that
it’s offline, and restart the node they can take a few seconds or minutes.  That
doesn’t sound like a lot, but that’s still an interruption to your users.  Since
Storehouse can fail over so quickly, we’re not likely to drop a single request
from a user, which is pretty awesome.

I’ve been running the pfSense balancer on Storehouse for a couple of months now,
and have had no issues with its speed during a number of simulated and actual
failures.  I would recommend this to anyone, especially if you’re already
running pfSense since it’s built in.  If you’re running redundant pfSense
installations, even better: you just got yourself a 2N load balancer fore free.
Compared to a hardware solution or a more hacked Iptables solution, it’s a no
brainer to make the change.
