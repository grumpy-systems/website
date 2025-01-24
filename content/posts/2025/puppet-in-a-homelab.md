---
title: "Puppet In My Homelab"
date: 2025-03-28
tags: ["how-to", "homelab", "linux"]
type: post
draft: true
---

I'm a firm believer in the "Cattle, not pets" philosophy with my homelab.  As
much as I can, I'd like my configuration to be repeatable and automated so that
nodes can be recreated or configurations updated without having to edit things
by hand everywhere.

There are a number of tools that can do this, things like Ansible and other
scripts and solutions, but I settled on Puppet for a number of reasons, besides
the fact that I was familiar with it from work.

The biggest two are that Puppet is declarative, and it seems like other tools
are much less so.  I don't care much about the semantics of how something comes
to be, I just want to declare the final state and in most cases let Puppet or a
module handle the rest.  The other big reason is I wanted nodes to be self
sufficient, and self update at least daily without my intervention.

## My Road To My Current Setup

In the past, I [ran puppet without a
server](/2021/puppet-without-a-puppet-server/) quite extensively.  This worked,
but had a ton of flaws:

* It relied on all servers knowing everything about everything.  There was one
  repo things were stored in, and it was cloned globally including secrets or
  potentially sensitive config.
* I had no good ways to store secrets.  These couldn't be stored on all nodes
  for obvious reasons, so I was still left with a lot of manual config or
  storing config on nodes again, which I was trying to avoid.
* I didn't like lack of automation or support fo modules.  For basic things,
  this was mostly fine but as things got more complex using modules became more
  of a need and having nodes manage themselves for updates also became a need.

