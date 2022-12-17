---
title: "Promxox/Rclone Offsite Backup"
date: 2021-09-27
tags: ["how-to", "linux", "dev-ops"]
type: post
---

One of the most important parts of keeping data safe is offsite backups.  One
excellent tool for this is Rclone, a tool that copies data to local and remote
locations with ease.  I don't use Rclone for all my backups, which I'll get
into, but I use it for some cases and it's a great tool.

## Why I Use Rclone

I operate a dedicated server where the hardware is managed by a third-party.
This server runs Proxmox, and I take backups of all the virtual machines daily.
This protects the machines from something happening to the VM itself, but it
doesn't protect against the dedicated server failing.

As an example, if the RAID drives (also, RAID isn't a backup) fail or if the
server itself is damaged for some reason (like a fire), the backups kept on that
machine would be gone as well.

Proxmox has a method for taking snapshots of machines at an interval and can
manage the periodic purging of data, but I wanted to keep the data offsite in an
S3 bucket too.

Typically, I like my backup software to have the ability to snapshot data.
Rclone out of the box doesn't really support this, but I compensate for this
with the lifecycles of my backups.

## The Lifecycle of my Backups

Each day, Proxmox takes a snapshot of all the machines running on it.  These
snapshots are placed on a local RAID volume, and Proxmox manages an internal
retention strategy.  Basically, it keeps daily backups, then a few weekly ones.

Rclone steps in after the Proxmox runs its backups and copies the data into an
S3 bucket.  Rclone doesn't worry about removing anything from the S3 bucket, as
all of that is handled by lifecycle policies in the bucket.

As Proxmox purges the backups, they're retained in the S3 bucket for about 90
days before finally being purged.  This gives me a nice balance of having
locally available backups for quick restoration, and more complete offsite
backups.

This isn't a true "snapshot" backup, as if the file on the local side is
overwritten it would be overwritten on the S3 bucket.  You can enable versioning
to combat this too, but I don't worry about this particular scenario happening.

## Setting up Rclone

There's a few steps needed to get everything to work.  I won't go into the
Proxmox Backup process, as it's fairly easy and doesn't require much explaining.

The first step is to configure Rclone.  Rclone provides a nice wizard for this
that you can follow by running `rclone config`.  In our case, we want to create
two "remotes": one called `crypt` that will handle the encryption of the data,
and an `s3` remote that actually pushes the data offsite.

This isn't super intuitive, but makes sense if you think of the backup like a
chain.  We create the `crypt` endpoint, which in turn points to the `s3`
endpoint.  This means any data we copy into `crypt` will make it up to `s3`
after being encrypted.

There are a multitude of options you can set for both Crypt and S3, and I won't
go into all of them.  Most are self explanatory or have a sane default.

When all setup, you should have a file in `~/.config/rclone/rclone.cfg` that
looks like this:

```cfg
[crypt]
type = crypt
remote = s3:<your bucket and path>
filename_encryption = off
directory_name_encryption = false
password = <encrypted password for the file encryption>

[s3]
type = s3
provider = AWS
env_auth = true
region = us-east-2
acl = private
storage_class = ONEZONE_IA
```

When setup, you can run a backup with this snippet:

```bash
rclone copy /mnt/pve/<storage>/dumps crypt:
```

If you're watching the output, you can use the `--progress` flag too to get nice
progress output.  There are also many more flags to limit bandwidth and other
fun things, take a look at the [rclone
docs](https://rclone.org/commands/rclone_copy/) for more.

One thing of note, is that this won't remove any data from the S3 bucket.
You'll need to enable [lifecycle
management](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html)
to clean out old backup files.

## Protecting The Configuration

One thing that is important to do now is to backup the configuration file.
Since you've encrypted your files, you'll need this key for your backup to be of
any use.

You can download this file and store it locally, but my preferred way is to
place it in my Last Pass vault.  It's encrypted and stored off any machine I own
in case of a disaster in both places at the same time.

## Restore Files

When it's time to restore files, first restore the configuration (if it's not on
the machine already).  You then run `copy` just in the other direction:

```bash
# Copy everything from the past 2 days
rclone copy crypt: . --progress --max-age 2d

# Copy a specific file
rclone copy crypt:<file> . --progress

# Copy everything
rclone copy crypt: . --progress
```
