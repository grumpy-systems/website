---
title: "Ramblings on Shitty Consumer Internet"
date: 2024-05-01
tags: ["homelab", "random"]
type: post
---

This is a post that's largely going to be me complaining about shitty cable
internet that I've lived with since its inception.  Making the change myself,
and now seeing others complain in forums has really soured me to most of the
connectivity options out there.

I won't name the specific company, but a lot of this complaining will be focused
around my experience with them and the myriad of issues I faced, both technical
and non-technical.

## My History

For reference, I've had some form of internet delivered over coax since the very
early days of it being available.  Our original Surfboard modem was a beige box
with only a Coax and Ethernet connector on the back, and I think it only
connected at 10 mbps on the Ethernet interface.

Since then, the local CATV system was sold and standards increased to
deliver 1+ gbps speeds to consumers on the very same piece of cable.  I've also
moved, but $CABLE_ISP has been the only ISP I've ever known, since DSL was either
always the more expensive but less reliable option or, more recently, not
offered altogether.

In the last few months, a local fiber ISP finally completed their construction
in my market and I _finally_ was able to have another choice.  I couldn't be
happier with the change, and I'm so happy I want to write down all the reasons I
didn't like my old ISP in case I ever forget how good I have it now.

## "What made you look for other options?"

As always, when you leave $CABLE_ISP they want to know what made you unhappy.
The poor soul on the other end then got the Reader's Digest version of this
list.

In all, it's not _one_ thing that made me leave.  It was the collection of all
of these, plus a new provider at less than half the cost.

### Bandwidth Caps Are Highway Robbery

I paid for a 1 gbps connection to the outside world, but felt like I couldn't
use it without constantly looking over my shoulder.  $CABLE_ISP gives you a
_generous_ 1.25 TB of bandwidth (they even increased that since 2020), that no
_normal_ user would _ever_ exceed.  Right?

If I saturate 1 gbps (which I can't, more later), it'd take just over 3 hours to
run my bandwidth cap out.  Unlimited plans exist, but it's a significant jump in
your monthly bill.  Some ISPs also require their equipment to take advantage of
unlimited [^1], and others still threaten customers with disconnection if they
don't curtail their usage [^2].

I see two reasons for implementing these caps:

* I want more money, and you have money in your wallet.
* The network is undersized for the customers and speeds it tries to serve.

To the first point, $CABLE_ISP is really good at wanting more money.

Most types of networks (fiber, coax, plain ethernet, most wireless) cost the
same regardless of how much data is being moved on them.  Data has no weight,
it's minute pulses of electricity or light, so if a piece of fiber is operating
at 10 kbps or 10 gbps, it's the same cost to string it between two points and
maintain it, save for tiny amounts of electricity to generate those pulses.

A network, though, has a finite capacity.  To compound this, most Coax networks
are shared capacity, meaning that the N gbps pipe put on the cable is shared
between _all_ the users that are signed up.  Modern cable networks are divided
so the groups of subscribers sharing this pipe is smaller and smaller, but in
some cases several hundred users may be sharing one upstream connection.

Adding these caps motivates customers to reduce their utilization, and make the
shared bandwidth go just a little bit further without raising the sticker price
of a plan or upgrading the network in the field.

Modern hardline Coax (the stuff on the poles and in the ground) can transmit up
to 28 gbps [^3]. Sure, it costs money to upgrade systems that were built out in
the early days of all this, but _that's what I pay you for_.  The taps and
equipment neighborhoods I've lived in were _never_ replaced while I lived there
that I can recall.

As my act of rebellion, I tuned rate limiters on my long running data jobs
(backups, archival, etc) so they can run 24/7 and the total bandwidth lands just
under the 1.25 TB cap without going over.  I really wanted to automate this
further, as some months my data usage was quite low and I wanted to uncap my
seed box just to use up more data.

### Network and Routing

$CABLE_ISP's network was ... odd.  I lived in multiple cities in Kansas.  Kansas
City was less always than 200 miles away, and lots of providers have a POP
there. Looking at who participates in [KCIX](https://www.kcix.net/), you can see
big names like Google Fiber, Hurricane Electric, Netflix, Fastly, Cloudflare,
Google Cache, Amazon, and a host of smaller providers.

$CABLE_ISP sent all the traffic to Dallas, TX until just recently, though.  I
have a dedicated server in KC, and traffic had to transit nearly 1,000 miles to
go 1/5th that distance as the crow flies.  While this may make sense, as
$CABLE_ISP's overall network has a more Southern focus, it led to interesting
congestion problems that quickly became evident.

$CABLE_ISP operates an Ookla Speedtest server in Wichita, KS, and if you were
nearby you could get the advertised rates, or at least within about 80%. Outside
the Wichita Metro, you can get advertised rates to in your immediate area, for
example a local WISP provider that's only a few hops away.  If you try to go
down to Wichita, though, those links were severely congested and you consistently
got about 1/3 to 1/4 of the advertised rates.

This did change towards the end of my time with them.  They seemed to now have a
network presence in KC and would at least reduce the latency and hops needed to
get there (and a good portion of the Internet as a result), and speeds generally
improved on the new routes.

While I didn't get to the level of automated speed test monitoring, practical
download speeds were about 1/10th of the connections speed, even when using
multiple streams such as when downloading a torrent.

### Latency and Reliability

While we're on the topic of network engineering, let's talk about the
reliability -erm- unreliability of the network.  I _often_ had outages that
lasted around 30 minutes that weren't caused by final mile equipment.

When these outages occurred, I could ping the first or second hop outside of my
network, but nothing beyond that.  While I understand equipment left out in the
elements for years degrades and can fail without much warning, the half-complete
traceroutes indicate that it's probably a router a few cities over that failed.

When things did "work", latency spikes and dropped packets were very, very
common.  Base packet loss of about 5% was normal, and it could spike up to
20-30% for hours at a time.  We'd get a helpful message in our ISPs app about
congestion causing issues, but this occurred pretty routinely so either no action
was taken or it was woefully ineffective.

Keep in mind too, this occurred in _multiple cities_.  Multiple cable plants.
This isn't a bad drop or a bad piece of cable, this is either a fundamental
mis-engineering of their network or things being oversold at a staggering rate.

### Caching

This honestly was something that I didn't even know existed until I inspected my
network traffic deeper after changing to my new ISP.

My new ISP has a few IPs that live in their network and address space and are
cache servers for large services like Facebook and Google.  A good portion of my
traffic to YouTube, for example, is served by a server 2 hops from my network's
edge.  This obviously improves latency and the overall experience, and I assume
Google (and other large services) and ISPs find it mutually beneficial to place
cache servers in provider networks. 

This is something I never observed with $CABLE_ISP.  Inspecting traffic, ISP
owned addresses _never_ showed up in my list of frequent fliers, meaning that
the closest cache servers were, again, 500+ miles away and accessible across
congested links.

It seemed like $CABLE_ISP's network was designed in a very centralized
hub-and-spoke model with Dallas being on of the big hubs, but improved caching
closer to subscribers could likely solve at least part of their congestion
issues as well.  How many duplicated copies of the same data is getting sent and
contributing more to the congestion seen?

### The Customer Experience

The individual people I dealt with at $CABLE_ISP were usually friendly and tried
to help as much as they could, they were just set in an environment where it
almost seemed like they wanted the customers to be dissatisfied.  They were
given limited levers, or were dealing with problems that were caused by people
much higher up in the company.

The entire time I was a customer, I felt like $CABLE_ISP's main goal was just to
extract more money from me.  It always seemed like the answer was some new flag
or feature to add, and that was always $30-100 per month.  Providing Internet
felt like an afterthought, and now that they've launched contract cell phone
service, that feeling is only amplified.

## Why is it shitty, though?

There are a few smaller reasons of why things got to be this way, but the
largest is simple: **most of these providers operate in an effective monopoly**.

I say "effective" because lots of markets have multiple options, but one choice
tends to stand out for various reasons:

* Other providers "exist" but stopped offering copper based services, namely
  DSL.  Copper phone lines seem to be on the way out, and with that the services
  they ran.
* Other providers are significantly more expensive and operate with other
  technical limitations that make it unusable in some cases.
* Other options just plain suck.  Some options are better than complete
  isolation, but just barely.

I had accepted the shitty routing and service I got as just part of life;
problems that if a company with over a $20 billion dollar market cap can't
solve, no one can.  I expected the same problematic service with my new ISP and
was honestly shocked at how much better all of these problems were.

Consumers let companies get away with much more in a monopoly because they
either can't see the greener grass, or even if there is greener grass there's no
way to get there.  Even had I realized that the service I got could have been
improved, until my new ISP built out their network there was no other providers
I could change to for various reasons.

Networks this large require significant investment and space in congested urban
right-of-ways tend to stifle the ability for new providers to spring up, and I'm
sure without external funding as part of a recent federal spending bill, my ISP
wouldn't have done their new build out for some time.

In a lot of places, monopoly networks exist and are generally OK.  What makes
those different is one key thing, though: **public utilities are regulated**.
Internet, while many have argued is essential for most aspects of life anymore,
isn't classified as such and not subject to the same oversight.  The FCC in
recent times has improved some transparency, but they rely on consumers being
able to actually make a decision, rather than their hand being forced due to the
local monopoly.

ISPs are frequently companies with some of the lowest customer satisfaction
ratings [^4], and there's no shortage of forum posts with disgruntled customers
shaking their fists at the sky.  Clearly, not all customers are there because
they're satisfied and happy.

## What can we do about it?

I didn't realize how much of a difference a new ISP could make.  Smaller ISPs
rely on customers expressing interest in new markets before they're able to
justify a new build out.  If you're not happy, I'd encourage checking if nearby
ISPs have ways to express your interest.  In my case, this interest didn't
commit you to service should you change your mind.

Municipal networks that are operated by a local town or city also seem like a
great idea.  Cities often need fiber to connect various buildings, traffic
signals, parks and more throughout the city and have the capability of
installing and maintaining large networks already.

The few cities in Kansas with municipal fiber networks seem to have a decent
price for their offering, though I've never actually used any of their services.
Small town politics can also be a significant factor as well, not only for the
building of the network but in its operation.

Building networks is also very expensive.  My small town has had drilling and
splicing crews working here for the past year to get things installed, and
they're still not done.  While customer subscriptions pay back this initial
investment, securing funding is an important step, and lots of industries and
governments can make this hurdle a bit easier to clear.

Probably the whole reason I'm writing this, though, is to share that the grass
can be greener.  If you have a shitty ISP like I did, it's worth the hassle to
make the change.  Initially, I only had a few things that drew me to the new ISP
(cost and the local feel of the company), but now I don't think you could
convince me to leave.

If you're in a market with a monopoly, it sucks.  Being vocal and actively
keeping an eye on new options that may be nearby might entice a new company to
build in your area, but it's largely outside any one person's control.

[^1]: https://www.reddit.com/r/Comcast_Xfinity/comments/12zw6c7/unlimited_data_internet_plan_is_only_unlimited_if/
[^2]: https://arstechnica.com/information-technology/2015/04/verizon-warns-fios-user-over-excessive-use-of-unlimited-data/
[^3]: https://broadbandlibrary.com/the-untapped-capacity-of-coaxial-cable/
[^4]: https://theacsi.org/industries/telecommunications-and-information/internet-service-providers/