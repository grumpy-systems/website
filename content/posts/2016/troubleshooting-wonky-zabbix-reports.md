---
title: "Troubleshooting Wonky Zabbix Reports"
date: 2016-08-11
tags: ["linux", "lessons-learned"]
type: post
---

I rely on Zabbix to keep tabs on all of my machines and to make sure all of The
Storehouse is working perfectly.  It’s always troubling to wake up to 30+ emails
from Zabbix and is pretty good cause for alarm.  Turns out, these things were
fairly innocuous and the sign of a pretty simple issue and related to the backup
of that VM.  I’ll try to outline the steps I used to diagnose and lessons I
learned along the way.

## Symptoms

Like I said, I would get a plethora of emails most mornings from Zabbix showing
that things had “broken” during the night.  I noticed a trend in these emails:

### All At The Same Time

All of these emails were timestamped withing 1 minute of each other.  Checking
the times they came in vs the envelope time revealed no large difference there,
a minute or two for mail processing and for it to land in my inbox.  These
emails are both for problems and for resolutions, so usually about 16 problems
and they are immediately resolved in 1 minute.

### Consistently Repeatable

The first few times of waking up to this I went into full alarm mode and started
to check everything afraid that things had really gone far south.  I noticed
though, that these emails occurred about every night and at about the same time
each night (about 1:30 am).  The issues were usually of a common thread: Zabbix
agent on Host is unreachable.  This consistency pointed me close to the right
direction, as it reeked of a bad cron job.

### Widespread And Random

One of the more alarming things about these events were the sheer number of
systems affected.  Usually about 10 or 15 machines would show some kind of
fault, which works out to about 50% of my production environment.  Every time
these events occurred, a seemingly random group of machines would be affected.
There were not too many common denominators, different physical hosts, different
duties, etc.

## Looking At Cron

I started by looking at Cron.  The predictability drew me to it right away, as I
do have a number of large(r) backups that occur nightly, and I figured that
perhaps one of these jobs had bitten off more than it could chew and clogged
some things up for some time.  I looked around at my usual cron suspects, but I
didn’t find any that ran exactly at that time.  The unpredictability of machines
made it difficult to pinpoint one culprit, since cron runs a host of different
things at different times on each host.

Looking at the syslog wasn’t too helpful either.  Although I have centralized
monitoring, I do not have centralizing logging.  To check the logs meant to
login to each machine and grep /var/log/syslog for the times in question and see
if anything stuck out.  Usually the logs were perfect and showed no signs of
either a failure on the node or a job that would be causing the issue.

## The Bigger Picture

Eventually my search led me to look at things on a bit larger scale.  I started
looking at datacenter tasks that ran at that time, specifically what my Proxmox
nodes were attempting to do at that time.  Nothing appeared worrying, except one
particular backup.  Not only do I run backups of specific directories and drives
on some VM’s, I also backup the entire VM daily.

Looking at what times these ran wasn’t alarming right away, the latest one
started at about 1 AM.  Isolating things down a bit further showed that the VM
holding up the show was the Zabbix machine.  Bingo!  Looking over logs showed
that that VM usually started backing up about 1:30, and it took anywhere from 5
to 15 minutes to dump.  The fix was pretty simple, I just stopped backing up
that VM.

Sidenote, when I say I stopped backing up the VM I really mean the complete VM
image.  The database was already backed up daily, and since Zabbix is a pretty
easy and non-critical (production isn’t down) package to install, it made sense
to just keep the database backed up and to sacrifice the VM in the event of a
failure.

## Lessons Learned

That is why we’re here after all.  Here’s what worked and what didn’t:

### I Need Centralized Logging

Why I’m not running this is a very good question, but having this would have
saved me the headache of trying to pinpoint everything my servers were trying to
at that time.  As it turns out, the issue was visible in the syslog of the
Proxmox node, but that’s one of the later places I looked.

### Common Sense Rules

Zabbix is really cool and can do cool things, but it can become a crutch to try
and replace good system administration.  In my case, Zabbix was symptom and not
the test.  Had I assumed Zabbix was correct, I would have never found the
underlying issue.

### Logs and Notifications Work

I have a dedicated account just for keeping email logs of backups and cron jobs.
99.9% of the time these emails get marked as read by Thunderbird’s mail filter
and filed away for 90 or so days then deleted, never to be viewed by human eyes.
That 0.1% of the time is crucial and made the seemingly endless barrage of daily
emails worth it.  The emails were a fantastic tool for checking completion times
of jobs and getting some basic output of each job to make sure it was running
OK.

### Be Judicious About Backups

I once heard that everything dealing with computers is compromising.  This was
no exception.  It sounds really great on paper to backup entire VM’s, including
their large database, every day but practically this turns out to be quite a
challenge.  In my case, I was already backing up the database itself, so backing
it up again with the node didn’t make too much sense.
