---
title: "Naming Things in a Homelab"
date: 2022-08-17
tags: ["homelab"]
type: post
---

There's an old joke in Programming that 90% of your time is spent naming things,
and I think this extends into Homelabs and any other computer environment.

Names are there give your systems identifiable places, can describe where they
are and what they do, and are the easiest way to identify something, so giving
some thought into a naming system is worth it.

## Styles of Naming

Naming schemes, like the environments and systems they reflect, can vary widely.
Some people go for a purely pragmatic approach, naming things like `app-server`.
When you're managing hundreds or thousands of systems, this is really the only
way to go.

If you have fewer systems, people opt for more unique and creative names.  These
can be names of planets, spices, elements, cars, anything.  If you have one or
two machines, this is usually the easiest way because it requires the least
planning and thought.

Naming things can be broken into two ideas: Naming DNS resources and naming
individual systems.  Everyone also has their own way of doing things, but I'll
share my way as an example.

## DNS Names

The question I see often on /r/homelab is how to name stuff for private / public
DNS.  Lots of people want to make their applications accessible on the internet,
so a public domain name is obviously required.  Internally, DNS is still _very_
useful and I feel is often overlooked.

Both give you quite a bit of freedom, and I argue that you can use the same
domain for both public and private resources with Split DNS.  But picking a
memorable and unique domain is step one.  For my setup I went with
`last-name.cloud`.

For public DNS, I have two "types" of first-level names I use.  The first is a
site name, such as `home.last-name.cloud` or `provider.last-name.cloud`. These
point to the public IP of the site they correspond to, and can be updated via
dynamic DNS (in the case of homes) or are just static in the case of public
providers.

The other type of first-level DNS names are global services, and are just
`app.last-name.cloud`.  These keep things simple and memorable for anyone who is
offsite.  Behind the scenes, these just point to the site's DNS record where
they are hosted.  When a site moves, such as dynamic DNS updating, the services
move as well.

Within each site, private DNS is used extensively.  I assign each network in the
site a DNS subdomain, such as `lan.home.last-name.cloud` or
`iot.home.last-name.cloud`. If your DHCP server is able to respond to PTR record
requests, it makes it trivial to convert an IP into a location, network, and
device.

For public services hosted in the same site, private DNS steps in again and
CNAME's the public record into the detailed name of the host with the service.
For example, `emby.last-name.cloud` is pointed to
`emby.dmz.home.last-name.cloud` locally.

The downside is that things can get verbose, ie to talk to an IPMI interface on
a server, it's at `atlantis.bmc.oob.home.last-name.cloud`.  Longer than the IP
address, but I don't know the IP address off the top of my head.

## System Names

My theory behind system names is to usually be pragmatic.  Things are named for
the app they run, or role they fill.  As an example, my machine running Emby is named
`emby`. Likewise, the one running NextCloud is called `nextcloud`.  These names
communicate what the node does and makes it easy for people to remember where to
connect to (ie, to use Emby, connect to the node named `emby`).

If I have multiple app servers for redundancy, things are named `-01`, `-02`,
etc if multiple are active, or `-primary` and `-secondary` for failover
situations.  If a node is transient (ie gets created or destroyed
automatically), a unique hash is appended, such as `-a34d3c`.

These application nodes are cattle, not pets.  Their configuration is centrally
managed and repeatable.  If a node fails, I can spin up a new one in short order
and they have a single role: the app they're named after.  They are upgraded and
replaced often as part of app lifecycle processes, so they can come and go
periodically.

Where I break from pragmatism is when nodes become uniquely configured or
represent a high value thing.  Right now, these are my physical nodes and
internal monitoring.  Both can likely be replaced if needed, but these nodes are
very persistent and very rarely replaced.

Unique names can still communicate roles and groups of machines by the themes of
the names.  For example, my Proxmox hypervisors are named after Space Shuttles.
While the commonality isn't as obvious as `pve-01`, `pve-02`, etc, it's still
easy to see they're related.

## Advantages of Well Thought Out Names

The biggest advantage to this system, and the main reason why I went with this
strategy, is to let monitoring systems get information about a node quickly with
a single reverse lookup.  In the logs, I can get information about what the node
does, where it is, and what network it is in without having to look anything up.

If you keep things pragmatic, everything serves as a reminder as to where it is
and what its for.  Using a unique name for a unique system lets you not tie
nodes to particular services (if they handle multiple).

Using CNAMES and makes it fantastic for services behind dynamic DNS, an update
to the site's hostname updates all the related services by proxy.  It also lets
you quickly check where a service is hosted in case you forget.

## Summary

Obviously, naming things is a personal and unique adventure.  My word of advice
is to make a system and stick to it.  Change the system as you go along if you
need to.  As long as things are consistent, you're able to find stuff quickly and
get insight without much extra work.

Don't worry too much about predictable names revealing things about your
infrastructure, mostly because everything these names tell you, you can figure
out other ways.  Security by obscurity is not a good plan, and will just cause
you repeated headaches of trying to figure out information about a host.
