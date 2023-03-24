---
title: "What could a TikTok ban look like technically?"
date: 2023-03-23
tags: ["random"]
type: post
---

The leadership of the US seems to be chasing down banning TikTok from the United
States, and today had a hearing with the CEO of TikTok.  It got me thinking that
should this ban go forward, what would it look like and how easy would it be to
bypass?

__Disclaimer:__ This post is meant as a thought exercise and in now way should
be read as any sort of deep technical analysis of plans congress may have.  It's
just me thinking out loud.

## My Opinion On Things

I'll start with my opinion and try to keep it contained to this section alone.
I'm a bit biased overall because I do create some content for TikTok, but I
don't get any sort of compensation or incentive to do so.  I'm primarily a user
who happens to post things every now and then.

I view this entire argument as quite disingenuous.  The hearings today seemed to
focus on privacy and safety issues that all social media apps face, not just
TikTok, and that would be solved with well thought out privacy laws to protect
US consumers.

The only real argument that may hold some merit is the fact that TikTok is owned
by a Chinese company, and there are implications as to the influence Chinese
leaders have on the app, its content, and the privacy of users.  Based on
personal experience, I can say the content I see on TikTok is largely of the
same caliper of that I find on YouTube or Facebook.  During the balloon
incidents there were even a number of posts jabbing at the Chinese that were
clearly allowed to exist.

Privacy is an issue on any social media app, and given that US law enforcement
has already found use in the data that is bought and sold legally from social
media and data brokers[^1], I'd be shocked if other governments (including the
Chinese) haven't caught on to the fact that US consumer data is widely
available.

All this is to say: If privacy was the main concern here, the solution would be
to focus on building new privacy laws instead of censoring a platform.  Banning
this one app will, as I see it, reduce the security and privacy of consumers as
they may use less-than-optimal ways to access content.

## Banning An App

While new in the US, social media apps being banned in countries is really
nothing new overall.  Countries have blocked social media (or even access to the
internet) during times of unrest[^2], so the technical challenges there have
been solved in some cases.  Blocking something in the US might pose some
additional challenges, though, but here's some ways things could get shut down.

_As this list goes on, things get more and more invasive.  It goes without
saying that the later options are absolutely insane and please don't take these
as any sort of prediction._

### 1) Unlist The App

Apple, Google, and other mobile OS maintainers have fairly closed-off gardens in
their app stores that distribute only approved apps, so just removing the app
would be an easy bar.  Removing apps is common, though usually it's for security
issues or malware, and could be an easy step to take to block the bulk of people
accessing the app.

Side-loading apps, though, is trivial in most cases.  With a few clicks in
Android loading a custom APK is easy and fast.  Other platforms may be more
difficult or require jail breaking, but running custom software is, again,
nothing new.

### 2) Break DNS

The first truly technical measure could be to block TikTok's DNS from operating
in the US.  There's a few ways to do this, some getting more draconian.

The first would be probably the easiest (relatively speaking), which is to seize
the `tiktok.com` domains used to operate.  Since the `.com` root servers are
operated by Verisign (who operates in the US), they could easily be compelled to
hand over the domains and allow them to be routed into the void by the
authorities.  This has been done before, although usually to take down botnets
or other malicious or illegal sites.  This won't stop TikTok, as there are a
multitude of top level domains outside the control of the US (heck, even on for
North Korea), so they'll just update should `.com` be blocked.

The next way, and increasing in draconian-ism, is requiring public DNS servers
to de-list those domains.  This would require the buy-in of all the public DNS
name server operators (there's a lot), and likely spring up a cottage industry
of DNS servers that _do_ list these banned domains.  I won't even touch on
enforcement and private DNS servers, as most routers anymore have some DNS
lookup functionality that would require updating.

If the government wanted to go full crazy, they could set up a public DNS server
that you are _required_ to use, a-la the great firewall.  This obviously is a
terrible idea for a number of reasons and I sincerely hope this never is a
thing.

While a low bar to enact, no matter how you break DNS it can be bypassed given
enough time and effort.

### 3) Block Networks

Breaking DNS keeps TikTok hidden, but if you use a different DNS server or
otherwise bypass those restrictions, you can still talk to the TikTok servers.
If the authorities _really_ wanted to block TikTok (even if the server operates
in a different country), they could block routing to TikTok's ASN entirely.

Blocking stuff at a BGP level is, actually, quite common to mitigate DDoS
attacks in some cases and to enact widespread internet censorship in others.
The latter would pose a number of challenges to the US:

1) TikTok operates outside their ASN if they're in a shared hosting environment,
   on a CDN, or otherwise operating on someone elses network.  You can't enact
   this level of block and expect to get all of TikTok and have no innocent
   casualties.
2) There are a ton of network operators in the US.  TikTok's ASN peers with 7
   different providers right now[^3], but peering policies can change and
   interconnections can spring up.  Of those providers, some are based wholly
   outside the US and not subject to our laws, so it'd be impossible to block
   fully.
3) If just one provider doesn't bend, the blocks are useless.  I'm sure some
   company will take a sympathetic view or simply refuse to block networks on
   moral grounds, further eroding any success there.

Blocking networks like this has been done in other countries, but usually there
are only one or two providers with peers outside the country, so it's a pretty
low bar to enact these types of restrictions.  The effectiveness even in those
cases is limited, and is usually met with cries for boosting VPN or TOR access
for those on the other side.

Blocking TikTok's network in the US would be easy to work around using TOR or a
VPN that terminates outside the US.  Again, we've seen that the effectiveness of
these blocks is marginal and going after bypass things like VPNs would cause
even more outcry.

### 4) A Great Firewall

Ironic, isn't it?   Censoring a Chinese company with a Chinese idea?

## End Users

One thing that I would like to mention is that by banning the app, officials are
likely to decrease privacy and create more opportunity for average users to have
data stolen.  If TikTok is removed, a "wonderful" cottage industry of proxies,
fake apps, sketchy guides, and lackluster VPN provers will spring up.  Folks who
don't care about security or privacy and instead see this as a way to make a few
extra dollars.

End users may fall for proxies or VPNs that _do_ crawl and sell data, and
(depending on how they're set up) might have unencrypted access to _all_ the
traffic sent back and forth.  To the end user with little knowledge of the
security implications of such services, the opportunity for malicious services
would be great.

It's easy for those used to using VPN services to add another thing to our list,
but keep in mind that 150 million Americans use TikTok, and the vast majority of
them may fall for even the most obvious scam.

## Final Thoughts

Again, this is presented as a thought exercise and not a guide of whats to come.

There are a myriad of legal questions that would also need to be answered here,
and should this ban move forward I'd say we're venturing into uncharted waters.
The members of congress at the hearing today seemed to lack basic technical
knowledge, so I'm doubtful of the effectiveness of any law they craft.


[^1]: https://www.eff.org/deeplinks/2022/08/inside-fog-data-science-secretive-company-selling-mass-surveillance-local-police
[^2]: https://www.forbes.com/sites/siladityaray/2022/09/22/iran-blocks-nearly-all-internet-access-as-anti-government-protests-intensify/
[^3]: https://bgp.he.net/AS138699