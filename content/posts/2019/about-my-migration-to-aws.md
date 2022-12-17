---
title: "About My Migration to AWS"
date: 2019-01-19
tags: ["dev-ops", "lessons-learned", "startups"]
---

After a long a deep think, I've decided to retire my physical hardware and
migrate all of my machines to Amazon Web Services.  It wasn't an easy choice,
and I feel like I need to spend some time explaining why, just get some things
off my chest.

## Reason #1 - Our Hardware is End Of Life

Most of the reasons we're moving are related to our hardware approaching the end
of its useful life.  Depending on your perspective, this point may have even
been reached long before now.

We run 3 servers, all of which are over 5 or 6 years old.  They've been
fantastic machines and we've gotten well over our money's worth out of all
three.  Overall they still work without issue, but with their age they've
started to develop some performance and reliability issues that are becoming a
concern.

The obvious answer is to buy new hardware, but doing that introduces more issues
and further reasons why we're switching.

### Physical Hardware Introduces Constraints

One of the battles I have long fought internally is what hardware to buy next.
Aside from the fact that servers are a fairly large investment (more so with
small operations like us), there are a couple of different routes to go.

If you shop for new or used servers, you realize quickly that the number of
configuration options can get ridiculous quickly.  Along with these options,
many of them can't be changed in the field.  This means that you're essentially
locked into decisions you make now (2.5" vs 3.5" hard drives are one prime
example).

With Storehouse being as small as it is, we're still working to figure out what
balance of storage to CPU works best for us, and exactly what our needs are now
and what we anticipate them to be in the future.  With these uncertainties, the
decisions as to which servers to buy becomes more and more difficult, and the
repercussions become more and more pronounced.

### Physical Hardware is Really, Really Expensive

One of the drawbacks of buying physical machines for such a small company is the
sheer cost of these machines.  New servers are instantly out of the question, as
even basic machines start several thousand dollars without any additional
options selected.  Used servers are a very viable option, but new performance
issues arise, and newer technologies that would directly benefit us aren't
available on the older platforms.

Not only are servers expensive, network gear is equally expensive.  This is
where we run into more issues, since with our clustered filesystem network
performance is paramount.  Being able to purchase switches and network cards
that are able to handle our anticipated capacity in some cases costs more than
the servers themselves.

## Reason #2 - Management

A realization I came to in the past few months was the amount of time I was
spending on managing infrastructure.  I felt as if more and more of my time was
spent troubleshooting why servers weren't online instead of developing new
features of bug fixes for Storehouse.

A lot of the problems we were facing were also nothing new.  Tasks like setting
up highly available database servers took enormous amounts of time simply
because I hadn't done that before and had to learn as I went.  Services like AWS
offer real solutions to these problems and make it pretty simple to setup new
services and ensure they are redundant and able to scale to meet future needs.

Most (if not all) of our outages were caused by human error.  A lot of cases
were simply that quirks with the setup of our machines came to light at
inopportune times.

## Reason #3 - Redundancy

Being able to run services in a redundant manner across different physical
platforms is a must now.  Hardware fails, and I'll be the first to say that
we've been extraordinarily lucky in that we haven't had any major failures in
our run (quickly knocks on a wood table).

Setting up physical stuff to be redundant takes a lot of extra planning, work,
and a lot of extra cost in some cases.  Letting someone else take care of the
nitty gritty details has proven already to be a real benefit.

Large, global services like AWS have a distinct advantage because data and
machines can be located around the world and the work of interconnecting them in
a highly available manner is already taken care of.

## My Thoughts

A lot of people are moving to cloud services like AWS, but you don't see
anything from them.  A lot of the emotions I'm feeling related to this move are
nostalgic.  There are a lot of fists that happened in that data center: our
first servers, our first revenue, the list goes on and on.

Looking forward though, I'm excited to have even more firsts with AWS.  There's
still a lot we'll need to learn and a lot we'll need to manage, but it's
relieving to take some of the pressure off by letting them handle most of the
low-level configuration and management.

My plan is to eventually return to a physical data center, but as a compliment
to our offsite infrastructure rather than our primary platform.
