---
title: "The Cost Of Homelab Backups"
date: 2022-12-22
tags: ["homelab", "datahoarder"]
type: post
---

If you ave a homelab, you've probably collected a few TB of data that needs
backed up.  Recently in [/r/datahoarder](https://www.reddit.com/r/datahoarder)
and [/r/homelab](https://www.reddit.com/r/homelab/) I've seen a lot of posts
that ask about backups.  I've talked about my strategy in the past , but I
figured I dive a bit more into offsite backups.

If you're not familiar with why you should be keeping backups or some general
rules of thumb, I have some information [over
here](/2021/my-personal-backup-strategy/).  Basically, you should _always_ keep
backups of your data and those backups should include offsite copies in case the
worst happens to wherever your lab lives.

I'm not going to get into the specifics of backups, but know that you need to
take backups!

## Offsite Backup Providers

There are a lot of options for keeping your data somewhere else, but the big
idea here is to be geographically separate.  Depending on your level of
paranoia, this can be something like a few miles away, a thousand miles away, or
a few continents away.

Here are the options we'll compare:

### AWS S3

The big-name provider choice, this is AWS's data storage service that can store
any amount of data at a fixed rate.  It has multiple access tiers that determine
your cost but also how long it takes to read data.  Some tiers have instant data
access, but Glacier tiers require you to request a data read and then AWS will
make it available in a few hours.

### Backblaze B2

Backblaze is a company that's been doing cheap data storage for a long time, and
offers a object storage service like S3 called B2.  It has the same interface as
S3 but has only one tier.

### Buddy's House

If you have friends or family that live nearby, you can put a NAS or external
hard drive there and back up to it.  If they also need backup space, you can
probably arrange a mutual swap where you put a NAS at their house and they put
one at yours.  Depending on how nice your friends are, you can do this for free
but are on the hook for hardware and troubleshooting, especially if the friend
isn't tech-savvy.

### Colocation

Same idea as the friend's house, but your friend happens to own a data center
and is much more focused on money.  Lots of data centers can rent you 1 or 2 U
of space for a reasonable price where you can stash a NAS and backup to it.
Again, you're on the hook for hardware and driving over there to install and
maintain it.

## Costs

For any backup, we need to consider a few aspects that may contribute to the
cost.  If you _just_ store data things are simple, but in my case I do a few
test restores per year and check a random subset of data each month, so we need
to consider more factors.  These are the major costs I consider in this post:

* Monthly Storage Fees - This is the simple Cost per GB the provider charges to
  store your data.
* Data Transfer In and Out - The costs to upload (usually free) or download
  (usually not free) data back out of the cloud.
* Appliance Fees - If you need a lot of data fast, some providers can ship you a
  device with your data on it.  Some providers do this for free, others charge.

I'll break down costs for common events for each of the providers we're
comparing in each section.

### Data Storage and Checks

This is the most basic thing an offsite backup does.  For this section, I'm
looking at the cost to store 5 TB of data and read back 10% of it (500GB) as a
check each month.

AWS is an easy first choice, with S3.  If you go for the Standard storage tier,
they'll charge $0.023 per GB.  If you go with Glacier Deep Archive, that drops
to $0.00099 per GB.  If your backup program cant tolerate the delayed reads, you
can look at something like One Zone Infrequent Access, which runs $0.01 per GB.

As we read the data out to check it, we'll be billed for outbound bandwidth,
which is $0.09 per GB for AWS if you're leaving AWS.  If you're using Glacier,
you'll also have to request the data to be restored to a readable state, which
is $0.02 per GB.

Backblaze B2 has one rate of storage, $0.005 per GB, so it's pricing is simpler
but more expensive on the surface.  Data transfer is $0.01 per GB.

The Colocation and and Buddy System vary in cost and bandwidth charges, as your
colocation provider may impose data limits or your buddy's internet connection
may have data caps they can't exceed without cost.

If we look at just storage, here's where we stand.  This assumes storing 5 TB
and reading back 500 GB as a check each month.

|                    | AWS (Standard) | AWS (Glacier) | Backblaze | Buddy / Colocation |
| ------------------ | -------------- | ------------- | --------- | ------------------ |
| Storage Cost / mo  | $115           | $4.95         | $25       | $0 + hardware      |
| Data Transfer / mo | $45            | $45           | $5        | $0                 |
| Data Restore / mo  | $0             | $10           | $0        | $0                 |
| **Total Monthly**  | **$160**       | **$59.95**    | **$30**   | **$0**             |

As you can see, while AWS seems cheaper at first, adding in our restore costs
quickly puts it over the edge.  Also, while the Buddy system is $0, keep in mind
the initial hardware required + the maintenance that now falls on you.

### Full Restore (Downloading It)

If you need to do a full data restore, the simple way is to download the entire
data set back out.  We'll be billed for bandwidth as we are with our checks, so
things can get expensive quick.  Again, we're looking at our 5TB data set.

|                | AWS (Standard) | AWS (Glacier) | Backblaze | Buddy / Colocation |
| -------------- | -------------- | ------------- | --------- | ------------------ |
| Bandwidth      | $450           | $450          | $50       | $0*                |
| Restore        | $0             | $100          | $0        | $0                 |
| **Total Cost** | **$450**       | **$550**      | **$50**   | **$0**             |

When transferring large amounts of data from your buddy's house, you might run
into data caps set by the ISP, so the cost may be variable here.  For the cloud
solution, Backblaze is the winner here too.

### Full Restore (Mailing It)

Another option for a full restore is to have the provider send you the data via
a hard drive and a parcel service.  AWS and Backblaze can do this for you, they
write your data to a rugged hard drive and mail it to you with 2 day shipping.

For AWS, they charge a fee for the device rental ($60 for their smallest) + data
transfer out per GB ($0.03).

Backblaze has a similar way, and they charge you a deposit on the hard drive of
a $189 deposit that is refundable if you return the drive.  They limit you to 5
drive refunds per year though, and each drive can hold 8TB.

For the buddy system, you can do the same thing by going and picking up the
drive.  Colocation you can do this too, but you may be limited to buisness hours
to access things.

|                | AWS (Standard) | AWS (Glacier) | Backblaze | Buddy / Colocation |
| -------------- | -------------- | ------------- | --------- | ------------------ |
| Appliance Cost | $60            | $60           | $0*       | $0                 |
| Transfer Out   | $150           | $150          | $0        | $0                 |
| **Total Cost** | **$210**       | **$210**      | $0        | $0                 |

While it seems silly, when moving more than a few TB of data, this is by far the
fastest way, especially for limited home connections.

## Overall Thoughts

B2 is the winner in this comparison.  Backup restores and checks are important,
and while the cost per GB of storage is more, you easily recoup that difference
with the fees AWS adds for restores.

If you have a friend or way to keep a NAS offsite, that's even cheaper per
month, though keep in mind that you're now on the hook to maintain this device.
