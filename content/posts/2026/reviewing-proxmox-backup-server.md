---
title: "Running Proxmox Backup Server"
date: 2026-01-02
tags: ["linux", "homelab", "how-to"]
type: post
---

I'm approaching about a year since I reconfigured my backup strategy to rely on
Proxmox Backup Server.  Initially, I was drawn to the deduplication Proxmox VE
 backups could make use of, but upon trying it, I decided to migrate my entire
backup stack to it.

## What's Proxmox Backup Server (PBS)

If you've never seen it before, PBS is an appliance that you deploy on your
network to store and manage backups for a variety of sources.  It couples nicely
with Proxmox Virtual Environment for VM backups, but it has a host agent for
Linux distributions that you can use to backup arbitrary files.

The idea is that this runs on a dedicated hardware appliance with it's own local
disks, but there are some ways around that and we'll get there.

Some other key features that may be useful:

* Offsite sync
* Scheduled verification
* Deduplication and encryption
* Web based file restores
* Access controls and permissions you can set
* Tape and Removable disk backups

## How I Run It (And The Mis-steps)

Right now, I run my main instance on my Truenas machine as a custom application
that runs a Docker container.  There's an unofficial release that bundles [PBS
into a Docker
container](https://github.com/ayufan/pve-backup-server-dockerfiles), and so far
I've had no issues running multiple copies of that image.  The storage is a
mount pointed to a directory on the Truenas machine, which gives local data
storage where I was already storing backups.

If you're planning a deployment, here are some things I found along the way:

* **Don't use NFS** - This seems like an easy step, but the performance is
  nearly unusable.  PBS uses a chunkstore with lots of small files, so things
  like garbage collection will take weeks even with just a few TB.  iSCSI may
  work around this, if you have the ability to run it that way but I didn't
  really try this.
* **ZFS is the way to go** - If you're planning hardware, PBS can configure ZFS
  in the UI, so using an HBA and taking advantage of this would be better than
  say a hardware RAID controller or some other software RAID.
* **You don't need much hardware** - The PBS server itself isn't very
  heavyweight, at least for me.  Most of the operations are bottlenecked by the
  disk performance, and the only CPU bottleneck I run into is during
  verification where data is being hashed.
* **Be careful if running it as a VM** - If you just want to run it as a VM in
  your Proxmox VE environment, keep in mind you may have a chicken-and-egg
  situation for restoring.  If the appliance breaks, you'd need some other way
  to restore the PBS server itself.  A simple local backup may be the answer
  there, but make sure you have some plan.

I may migrate this into a virtual machine and iSCSI, the benefit would be that
PBS has the ability to use detachable storage (think USB hard drives) as
datastores, so I could use some drives to make a cold storage backup as well.
That's for another day though.

## Configuration

Once installed, there's not a ton of configuration you'll need to do.  You'll
need a datastore, which is a central repository for the backups.  If using
Docker, use a bind mount to pass a host directory into the container and just
select that.  If you're using hardware or something else, you'll need to
configure it appropriately.

I keep everything separated in namespaces as well, so I made one for each set of
data I back up.  You can restrict API tokens to specific namespaces, so I can
keep the token used for Server A from being able to even see backups for Server
B.

### Permissions

You'll probably want some API tokens and permissions as well.  This all lives
under Access Control and there's a few things types of things that all play into
each other here:

* **Users** - Each API token needs to be tied to a user, and permissions from
  this user will restrict the token.  We'll get into that.
* **API Tokens** - Basically a generated password token you can use for specific
  systems, but you can also restrict these permissions per token.
* **Permissions** - ACLs that let the User and Token control specific things.

In my case, I created a user that will contain all the backups for my systems. I
called it "Homelab" or something generic, and set a 64 character password.  I
then created a permission and granted this user the `DatastoreBackup` role to
the `/datastore/Local` path (update `Local` with the name of your datastore).
This lets this user _at most_ list and create backups in the datastore but
nothing more.

I then create an API token under that user for each system.  I also create a
complimentary permission for the `/datastore/Local/Namespace` path with the
`DatastoreBackup` role.  This lets that system create new backups and list
backups _just for that system_.  Since each of my machines backs up to its own
namespace, this keeps servers from even seeing backups for other machines.

One important thing that deserves its own section is the concept of Roles and
how much of an advantage this is for security.

Consider you have a machine that has an API token with `DatastoreBackup` in it's
own namespace.  If that machine gets compromised, the actors find your backups,
and try to delete them as part of some grand ransomware scheme, they _can't_.
Assuming there's no other vector at play, your backups are generally safe in
those cases.

Couple the above with unique encryption keys with each machine, and you can have
multiple layers of safeguards in place to prevent a machine from getting data
from other machines.  In an environment like mine where some machines are
significantly more private than others, preventing data leaks in this way is
key.

### Verification

Another thing you may want to configure is verification jobs.  This will read
all the data needed for a backup and verify it's checksum to ensure it's a good
copy.  A job will check any new backups and any backups over a certain age you
configure.

In my case, I run this daily during the overnight hours.  Backups can still be
taken during that time, but you'll probably see a performance hit just with the
disk activity needed to do the verification.

One thing to note, you may see an advanced option to verify backups as soon as
they're taken, but this will cause multiple verification jobs to all run at the
same time and really bog down performance.  A scheduled job that runs daily is a
good compromise because it quickly verifies things, doesn't need to run forever,
but does it one backup at a time and doesn't overload the system.

### Prune & GC

You'll probably want to remove data after some time, and that's where pruning
and GC comes in.  Pruning removes the backup from the index but doesn't actually
clean data, GC removes the unreferenced chunk files.

For prunes, there's no harm in running these often and you can configure
retention based on Namespace, or with more complex group filters.  These jobs
take only a few seconds to run in my case, so I run them daily in the evening.

You can only have one GC job, though, since it applies to the entire chunkstore.
There aren't many options other than a time, and I run mine weekly.  This scans
all the backups and removes the chunks that are no longer referenced.  It's
important to prevent disk usage from always increasing, and will take a few
hours at least when it runs.

### Encryption

If you want, you can encrypt data as well.  To do this, you'll need a key
generated by the `proxmox-backup-client` program:

```
proxmox-backup-client key create pbs.key --kdf none
```

You can pass that file when creating backups to encrypt them, but keep in mind
you'll need to provide the file to also decrypt and restore backups.  I keep a
copy in an offsite password manager, and generate one per system as a further
method of isolating things.

## Syncing

A big feature of PBS is it's ability to sync to other PBS machines elsewhere.
In my case, I have one instance running in my lab and another running on a
Synology NAS offsite that is used for offsite backups.

To set them up, you first need to configure the remote system in the "Remotes"
section in the sidebar.  You'll need a username/password or API token with the
correct permissions for the remote machine.

Then in the datastore, you can add push or pull jobs to sync data.  Push jobs
copy data from the local to the remote, pull takes from the remote and downloads
it locally.

When adding a job, the options are fairly self-explanatory.  You can use groups
and namespaces to filter data, set a source or target and schedule the sync.
Syncs are pretty efficient, so running them every few hours doesn't hurt.

## Running Backups

If you're using the `proxmox-backup-client` program, running a backup is pretty
easy but I also created a Puppet module to manage some scripts.  In my case, I
create a `/etc/pbs/backups/name` script that gives me an easy one-liner to
trigger backups.  This is an example:

```bash
set -e

export PBS_PASSWORD="API Token"

set -x

proxmox-backup-client backup <Filename>.pxar:<Path> \
    --repository '<API Token ID>:<DataStore>' \
    --ns <Namespace> \
    --change-detection-mode=metadata \
    --keyfile /etc/pbs/pbs.key
```

There's a lot of variables, though:

* **Filename** - An arbitrary filename for the pxar file that contains the
  backup.  I make it the same as the backup name I use internally.
* **Datastore** - The name of the datastore on the PBS machine where the backup
  should go.
* **Path** - The path you want to backup
* **Namespace** - The Namespace where the backup should be stored.
* **APIToken and API Token ID** - The Token keypair used to authenticate
* **Keyfile** - If you're using encryption, this is the file generated earlier.
  Exclude this to not encrypt the backup at all.

## That's It!

Be sure to keep an eye on things, I think PBS sends emails when things fail but
those aren't a very reliable system.

Beyond the odd failed job, though, the system has been solid for a year now and
is tracking around 6 TB of data with a deduplication factor of 50+ (meaning
300TB worth of raw backup data).  I've restored numerous files without issue,
and although I haven't had a real catastrophic failure since setting it up, it
seems like a very reliable system overall.