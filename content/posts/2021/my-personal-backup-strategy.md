---
title: "My Personal Backup Strategy"
date: 2021-10-07
tags: ["how-to", "linux", "dev-ops"]
---

I'm pretty protective of my data.  I like to make sure all my important file are
backed up, and I employ a 3-2-1 backup strategy for basically everything.

## What are 3-2-1 Backups

This is a term that is floated around frequently when talking about backups.  It
basically boils down to these rules:

1) You have 3 independent copies of your data.
2) Of those 3 copies, 2 of them are on different systems (Different servers,
   different SANs, etc).
3) One of those copies is stored offsite.

Sounds easy, right?  Well, it usually is.

Another thing I find critically important is encrypting the offsite backup. This
makes it so that if the offsite data is compromised in any way, it's encrypted
already.  It also adds the challenge of storing a new encryption key, but this
is easily overcame and the benefits are worth it.

## How I take Backups

All my critical data is backed up a few different ways.  Each has it strengths
and weaknesses, but together they make a solid strategy.

### Level 1 - ZFS Snapshots

All of my data lives in a TrueNAS server, which leverages ZFS for all its
storage.  I take automated snapshots every few hours of all critical data as a
quick restore path.

TrueNAS, ZFS, and Samba play seamlessly into the Windows "Restore Previous
Versions" option you get when right clicking on a file.  This way if you
accidentally delete something, you can quickly restore it with a simple right
click.

These backups are only stored for a day or two, and are meant as a quick "undo"
button.

### Level 2 - Snapshot Backups Onto New Pools

ZFS Snapshots are really great, but they're by default stored on the same disk
pool as the primary data.  If that pool is damaged or destroyed, the snapshots
go too.

To work around this, I take a snapshot backup using Restic (more later) to
different pools in TrueNAS.  This way if I lose an entire ZFS pool, the data
exists elsewhere.

Also, since local storage is cheaper and faster than anything cloud based, these
are the longest backups I retain.  I keep daily backups for a week, and weekly
backups for 12 weeks.

### Level 3 - Offsite Backups

The next level of protection are my backups offsite.  For this, I also use
Restic (although a different configuration set) and send data to Backblaze B2.
I like B2 as it is cheap storage without the complex pricing of AWS Glacier.

## Putting it All Together

To run the actual backup jobs, I've employed a Jenkins server that runs on my
network.  This is likely overkill and a misuse of Jenkins but it has a number of
pretty slick features, like being able to notify me of failures only rather than
blasting me with lots of emails each day.

You can schedule things via a normal Cron job too, as long as it runs
automatically and has some method of notifying you of failures.

The actual program running the backups is called [Restic](https://restic.net/).
It's a program that takes snapshot backups and has features like encryption and
de-duplication built in.  There's lots of software packages you can use to run
your backups, and each has their strengths and weaknesses.

## ARW

To manage Restic, I wrote a simple bash script that I call ARW (another Restic
wrapper).  Restic is great, but you have to invoke it with a number of flags to
get everything working right.  For repeatability, I coded these flags into
environment variables and use ARW to run everything.

This works similar to Duply, which is a similar wrapper for Duplicity.  It reads
profiles in `~/.restic/`, and wants each profile to have these files:

```plain
.restic/
├── local
│   ├── env
│   └── exclude
└── offsite
    ├── env
    └── exclude
```

You should also note that ARW doesn't create these files for you.  You have to
do that yourself, but it's two files.  I believe in you.

### env

The first file, `env`, is the environment variables to pass into Restic.  Restic
has variables for various options and authentication, and ARW adds a few extra.
As an example, here's one for an offsite backup:

```bash
# This file contains common restic options for the offsite backup

# Variables used directly by Restic
export RESTIC_REPOSITORY="xxx"
export RESTIC_PASSWORD="xxx"
export B2_ACCOUNT_ID="xxx"
export B2_ACCOUNT_KEY="xxx"

# Variables used by ARW
export SOURCE="/srv"

export PURGE=" --keep-daily 10"
```

The only two variables used by ARW are `SOURCE`, which is the directory you want
to back up, and `PURGE` which is a series of flags passing into [restic
forget](https://restic.readthedocs.io/en/latest/060_forget.html).

The full list of Restic Environment variables is
[here](https://restic.readthedocs.io/en/latest/040_backup.html?highlight=environment#environment-variables).

### exclude

Exclude is a simple list of directories to exclude from the backups.  One
directory per line.  You also need to have this file there even if you aren't
excluding anything.

This is passed directly to Restic as the `--exclude-file` option, and supports
cool stuff like
[globbing](https://restic.readthedocs.io/en/latest/040_backup.html#excluding-files).

### arw

This is the `arw` file:

```bash
#!/bin/bash

set -e

PROFILE=$1
COMMAND=$2

CMD=/usr/bin/restic

EXTRA=""

source ~/.restic/$PROFILE/env

if [ "$COMMAND" == "backup" ]; then
    EXTRA=" --exclude-file $HOME/.restic/$PROFILE/exclude $SOURCE"
fi

if [ "$COMMAND" == "forget" ]; then
    EXTRA=" --prune $PURGE"
fi

$CMD $COMMAND --verbose $EXTRA "${@:3}"
```

To use it, specify a profile and command.  The commands is anything supported by
Restic, and the profile is the  directory you put `env` and `exclude` in.

Here are some examples:

```bash
# Initialize the remote storage
arw local init

# Run a backup
arw local backup

# Purge your backups based on the rules you set up
arw local forget

# Restore the latest files to .
arw local restore latest --target .
```

If you're brand new to Restic, the [quickstart](https://restic.net/#quickstart)
is a good resource.  Basically all of the CLI flags and options are just passed
directly into Restic.

## Wrapping Up

Overall, this strategy is what works for me.  It may not work for you, and
that's OK.  I feel safe knowing that things are backed up a few different ways
and things like family photos are safe should the worst happen to my house.

Remember, always test your backups!
