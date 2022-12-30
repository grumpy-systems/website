---
title: "My Thoughts On LastPass and Their Recent Breaches"
date: 2022-12-30
tags: ["linux","tools"]
type: post
---

If you've poked your head outside in the last few weeks, you've noticed that
LastPass had a security breach where customer vaults were exposed and
downloaded.  I've been hanging around in
[/r/lastpass](https://reddit.com/r/lastpass) and seeing the mixed reactions has
been interesting.

## Why I'm Leaving

I'm leaving LastPass, and had been looking at solutions for the last few months.
While the security problems are the last nail in the coffin, I'll share why I'm
leaving besides the breach.

### UI

The biggest thing that was driving me off LastPass was the UI.  I put logins in
folders, and store a few hundred logins for servers, sites, etc.  Keeping things
in folders, even when the folders are collapsed, takes up a ton of space in the
UI and just looks bad.  As I grew into more folders, this problem just got worse.

The UI on sites seemed to also break things.  The buttons they impose into the
boxes usually didn't work as UI elements on the page broke things.  If you work
on a page with lots of fields, the extension will freeze the page while the
extension figures it out.

Alongside that, the autofill never worked right and it would fill fields that
were unrelated.  I had this bite me on my router configuration multiple times,
as it would autofill my root password for service passwords when updating
things.

Yes, I know I can turn those autofill off, but overall autofill wasn't horrible,
so disabling it everywhere was overkill.

### Offsite Vs Onsite

LastPass (and any cloud password manager) has a pretty big target on it's back.
We trust them to do security, and most seem to be OK in this regard.  The
thought always lingered of keeping things onsite though.

A good number of my passwords are for local servers and things that aren't
accessible outside my house, so moving things to a local solution was always a
big draw.  If I don't need the password outside my house, why store it outside
my house?

Solutions like KeePass or a self-hosted VaultWarden instance always had a big
plus in that regard, as the only way for a person to get my passwords would be
to compromise my home.

### Open Source

I'm a big believer in open source solutions, so using a closed source solution
like LastPass always felt odd.  I prefer security stuff to be open (prevents
security through obscurity), so finding an open source solution had been a goal
of mine.

## Security Issues

Aside from the UI and quality of life issues I faced, the biggest reason for me
leaving was the distrust I started to feel.  I've heard a lot of allegations,
and with the breaches things just reached a tipping point.

### Breaches

So it's hard to talk about why I'm leaving and not bring up the elephant in the
room: their recent breaches. I figure it's a matter of time before every cloud
password manager gets hacked, and LastPass's time seems to have come a few times
now.

While I appreciate them disclosing the breach (not sure if this is because of
legal requirements or their good will), the messaging seemed ... corporate.
Sure, there's investigations and legal liability here, but it seemed too much
like them trying to spin things rather than tell us what happened.

Some people have praised LastPass for their transparency, I see it is doing the
bare minimum.

What these breaches also did was highlight a some other security concerns others
have, some that are quite severe.

### Secure Storage

I'm not a security expert, but I know enough to be dangerous.  The marketing
surrounding the breaches advertised higher-than-minimum encryption, but this
post from [Almost
Secure](https://palant.info/2022/12/26/whats-in-a-pr-statement-lastpass-breach-explained/)
paints a very different picture.

The biggest red flag from that article isn't even alleged or unconfirmed:
LastPass's post says they use 100,100 iterations of PBKDF2.  The _minimum_
recommended now is over 300,000 iterations, and this minor detail has a profound
impact on the time it takes to brute force things.

Alongside that, the post alleges that this was as low as 1 (single) and that
some customer vaults may still have these weaker setting as they were never
re-encrypted.  Alongside passwords that were never forced to update
requirements, this paints a pretty dire picture of the security posture of the
company.

A company, mind you, that the entire reason I give them money for a subscription
is because _I trust they do the right thing_, and they've confirmed that in at
least once case they are not.

### Unencrypted Fields

Another issues I have was the unencrypted fields in the vault.  Basically only a
few things are _actually_ encrypted, but things like site names and URLs are
not.  These are still quite sensitive, as now someone may be able to do a very
targeted phishing attack.

The amount of data that is unencrypted was staggering, as I expect things to be
under near-total lock and key.

## What I'm Doing Now

I'm not panic changing my passwords, though I am changing them.  It's an easy
way to make sure the data in my vault is mostly useless should it get decrypted.

I'm also moving off to a local VaultWarden installation, as it fixes basically
all my gripes.  Being an open source solution with the ability to sync devices
is a perfect fit.  I also am able to use site passwords outside my house as the
apps sync data and don't require a constant connection to operate.
