---
title: "Please Don't Sell Space In Your Homelab"
date: 2023-01-03
tags: ["homelab", "linux", "startups"]
type: post
---

Hanging out in subreddits like [/r/homelab](https://reddit.com/r/homelab/),
[/r/servers](https://reddit.com/r/servers), and
[/r/datahoarder](https://reddit.com/r/datahoarder), I see this question asked
too many times:

{{< blockquote >}}

I have extra space in my home server, how can I sell this for other people to
use?

{{< /blockquote >}}

My answer (and a lot of other people's answer): **don't**.

## We're Really Not Trying To Ruin Your Dreams

If you come across this post, or if this was sent to you, know that we aren't
doing this for the sole purpose of ruining your day.  We tell you this because
playing with other people's services and money introduces a host of potential
issues, stuff that a lot of people aren't able to solve on their own.

Personally, I work for a medium sized hosting company in their support
department, so I see the challenges we have to solve every day.  Challenges that
you _have to_ solve for your idea to work and not open you up to a ton of legal
risk.

I promise I'm not trying to gatekeep, but if you have to ask for basic help in a
forum, you won't be able to solve these challenges.

## Why It's A Bad Idea

When you go down this road, you have a ton of challenges you have to solve.  If
you play with other people's data and money, you're going to have to solve
nearly all of these problems.

### Before You Even Start

* **You'll need hardware** - "But I already have _a_ server!" you yell into your
  screen.  No, you'll need more.  If you have your customers on one server and
  it fails, what now?  Do your customers just sit offline for a week while you
  build a new server?
* **You'll need better internet** - Your residential ISP isn't going to be OK
  with you doing this.  You'll need a business class connection at a minimum and
  preferably one with lots of bandwidth.  Also, what's your plan if this fails
  for a few days?
* **You'll need public IPs** - You need to be in possession of a public IP for
  all your customers, because hosting customers aren't happy with CG-NAT.  ISPs
  will sell these to you, but at a cost.
* **You'll need a better location** - Your basement isn't a very good
  datacenter.  Business want their stuff in places with redundant power, backup
  generators, higher priority on the power grid during outages, redundant fiber
  into the building, fire suppression, tight physical security, etc.
* **You'll need legal protection** - We'll dig into this more, but depending on
  what your customers do there may be legal risk for you.
* **You'll need a way to bill people** - If you collect money, you'll need tax
  registrations, business filings with your locality, bank accounts to collect
  fees, invoicing and billing software, etc.  All very much in the realm of
  possible but more chores for just a few dollars per month.
* **You'll need to figure out how much to charge** - The services you're
  competing with have this down to a science and can be quite cheap.  If you go
  against them, you'll need to understand how much _you_ need to charge to break
  even and understand what your customers would be willing to pay for what
  you're offering.
* **You'll need remote access** - If you sell someone a VPS, they will need to
  install an operating system, reboot it, and manage certain things offsite.
  Sure, you can do this for all your customers by hand, but this won't scale
  past a few customers.  You'll need a way for them to log in and manage or
  troubleshoot things.
* **You'll need good insurance** - And probably a good lawyer.  You're running a
  business now so you need to ensure that you're protecting yourself and your
  personal assets in case things go very wrong.

### Scary Stuff

Those legal protections I mention?  Not optional.

Depending on the law, people doing these things might cause your ISP to drop
your connection or (worse) land you in legal trouble.  You need to have plans on
how to mitigate these issues (if you can), and have appropriate legal experts
make sure you aren't opening yourself up for prosecution.

Also, this is just stuff _I've seen_ at my job.

* **People launching DDoS Attacks** - You have a cheap server with a cheap
  internet connection, why not use it for some help in a DDoS Attack?
* **Torrents or pirating** - A seedbox would be a nice addition to your homelab
  after all.
* **Proxies for other things** - Customers might use your IP to proxy all sorts
  of weird and nasty traffic.  This lands you in hot water with sites that track
  down your IP.
* **Crypto** - Sure, you might have 20 NFT's of weird looking primates, but are
  you accounting for all your customers using all their allocated CPU all the
  time?  If you over provision to make more money, this will impact all your
  other customers.
* **Very Illegal Things** - Things that require trigger warnings and obviously
  violate a ton of laws.  If you don't have the right boxes ticked, legally
  speaking, this can land you in prison.

Let's not mention the fun privacy laws too!  Do your customers host any data for
people in the EU, Canada, or California?  Process any payments on their site?
Congratulations! You now get to comply with all these laws that also come with
fines!

* **GDPR** - Company _ending_ fines if you screw this one up.
* **CCPA** - California privacy laws.
* **PIPEDA and CPPA** - For our friends up North
* **PCI** - Security related to payment cards.

These also come with some added benefits like mandated controls in your new
company, mandated reported, third-party audits, etc.

One thing to keep in mind too is seizure.  If your customer is doing illegal
things and attracts the attention of any three-letter government agencies,
they'll come take your server (and probably other things).  Feds have raided
datacenters and taken servers used in things like botnets, and they probably
don't care too much that your other customers share hardware.

### Now That You're Running

So you've passed the first gauntlet and set up your service.  Neat!  Now let's
run a successful hosting operations:

* **You need support** - Sure, this may be just you, but you need someone
  dedicated during the work day to help customers in case they have problems.
* **Your customers will blame you for everything** - Speaking from experience,
  hosting customers tend to like to blame the hosting provider.  Be ready to
  deal with people pointing fingers at everything but their bad code.
* **Backups and disaster recovery** - What happens if one drive fails?  Or all
  of them?  Do you have backups you can restore quickly?  What about fires or
  floods?  Ransomware?
* **On-Call** - If you have customers that expect certain uptime levels, being
  down overnight because you're asleep isn't an option.  You'll need to be
  available or have someone be available to help them.
* **Hardware Upgrades** - Customers might not want to run their apps on a 10
  year old processor.  Do you have money set aside to upgrade things?
* **Uptime and Reliability** - Your customers likely expect a high level of
  service, so you need to work to maintain that level of trust.  Business
  customers especially don't like wasting money, or even feeling like they're
  wasting money.

## Oh, and Security

This deserves it's own section because I cannot downplay how crucial this is
going to be.  Customers are **going** to run unpatched and insecure apps on your
servers and a few of them are probably going to get hacked.  It happens,
literally, every day.

### Isolation

The first thing is isolation.  Not only do you need to keep this all isolated
from the rest of your house, you need to keep your customers isolated from each
other.  Customers are going to run unpatched and vulnerable software and get
hacked, so it's crucial that one customer doesn't have the ability to compromise
the entire virtual host or other machines.

You also have to be very aware of the speculative execution issues lots of
processors recently had, because those have a very real and direct effect on
setups like this.  Those problems can leak customer data between their VMs.

Also, containers are likely out of the question.  If you give your customers
root (which you probably will if you host things as a VPS), it's possible to
break out of a container and move into the host system.  It's not something that
is trivial, but configuration problems can make it a pretty low hurdle.

### Patches and 0-Days

Keeping your setup updates is now mandatory.  Every piece needs to always be up
to date, because a small foothold can all it takes for someone to gain entry.

Your customers are also going to hound you for every CVE that hits the news,
even if you aren't affected.  You'll need to review them and either update
things quickly or let them know you aren't vulnerable.

If you _are_ vulnerable and something gets compromised, hopefully the isolation
you setup keeps it contained to a single customer.  If, say, you get your entire
host hit with a crypto locker and no backups, that's the end of your journey.

### Customer Data

You also now have data for your customers and your customers' customers in your
equipment.  Encryption at rest is mandatory, at a minimum.

This is also where those fun privacy laws kick in, because _you_ may be on the
hook for damages caused by lost or stolen customer data.

## Wrapping Up

Please don't sell space in your home server.

Some arguments can be made that by setting low expectations or hosting stuff
like game servers you can work around these issues, but the _vast_ majority of
them still remain.  Things like security need consideration regardless of what
you host.

If you're set on using up extra CPU cycles, here are some options:

* **Host more of your stuff** - Maybe you do need that extra media server of a seedbox.
* **Host stuff for friends** - Friends are different because you probably trust
  them.  A lot of the issues of customers taking advantage of you are mitigated
  by being friends.
* **Donate CPU cycles** - Projects like [BOINC](https://boinc.berkeley.edu/) and
  [Folding@Home](https://foldingathome.org) let you run workloads for academic
  research that can help other people too.
* **Downsize** - I know it's hard to talk about, but if your quad CPU, 2TB RAM
  monster can't run because it's too expensive and you need the money, get
  something smaller that's better suited for your workloads.
