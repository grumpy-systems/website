---
title: "Resizing Lvm Partitions on Centos"
date: 2016-10-26
tags: ["dev-ops", "how-to", "linux"]
---

One of the things I’ve done for my employer is resize partitions on a few CentOS
machines that already had customer data on them.  The default CentOS setup
didn’t work exactly for our needs, so resizing the /root and /home partitions
were our chosen course of action.  Overall the process is pretty simple, but I’m
writing it down here since it takes the concatenation of a two different
processes to get things done.

_Note: This guide mentions CentOS, but this works for any system running LVM.  I
personally have used these steps many times on various Debian and Ubuntu
machines without any issues._

## The Goal

The default CentOS partition setup uses LVM and allocates 50GB for / and
remaining disk free space for /home.  In our case, we stored large amounts of
data outside of /home, so we really wanted that reversed so / is the larger
partition.  We didn’t notice this setup until after we had migrated a lot of
client data to the new server, so reinstalling was not really an option.
Thankfully, LVM makes resizing the partition really pretty painless.

## Prerequisites

You’ll need a Live CD to do this.  My go to live CD is Lubuntu, but you can use
something much lighter weight since you’ll only need the command line.  I also
recommend having a machine to practice on before doing anything on production.
It’s also very wise to backup the entire machine before starting, just in case.
Something to keep in mind: you cannot resize XFS partitions, so you’ll have to
have used EXT4 when installing in order to follow this procedure.

Since these machines were in production, doing this as fast as possible was our
goal.  The entire process took me about 10 minutes after a few practice rounds.

## The Process

_Just like in your old science class, I recommend reading the entire procedure
before starting to get an idea of each step and practicing on a different
machine._

Before you start, log in to the machine and issue df -h to see where the
underlying partitions live.  Make a note of these, since we’ll need them later.

Once you’re ready, boot into your live CD.  This varies based on your setup, but
your live CD should give you the option to boot without installing.  You can
safely do this since the live CD won’t even mount your local hard drives and
therefore cannot touch the data on them.

Once booted, open a terminal and login as root (sudo -i for Debian / Ubuntu live
CD’s).  There are a few command to issue to get the resize to complete:

```bash
# Perform a check of the file system that will shrink
e2fsck -f /dev/mapper/volume-to-shrink

# Resize the filesystem.  Replace the 50G with the new size of the volume.
lvreduce --resizefs -L 50G /dev/mapper/volume-to-shrink

# Once that is complete, extend the new file system.  +100%FREE tells lvextend to use all unclaimed space.
lvextend -l +100%FREE /dev/mapper/volume-to-grow

# Perform a check of the volume to grow
e2fsck -f /dev/mapper/volume-to-grow

# Resize the actual file system
resize2fs /dev/mapper/volume-to-grow
```

Then reboot back into the normal operating system and re-issue df -h to double check that the partitions were resized how you expected.

## Gotchas

In our case, we were running the machines on VMWare.  This posed two problems
when trying to boot off the LiveCD.  The first was that we had to set the
startup delay to be able to enter to boot menu.  The second was that when we
started the VM, the console took longer to connect than the VM would pause on
startup, so we could never enter the boot menu and boot off the CD.  The
solution to this was to power off the VM, set the startup delay, boot the VM
fully, then issue a reboot command from within the VM to get it to restart and
keep the console alive.  If you miss the boot menu and land in Grub, you can
quickly press c to get a grub command line.  Then issue reboot to reboot without
having to wait for the machine to start fully.

We also ensured we weren’t resizing a partition to be smaller than the amount of
data on it, so I have no clue if these commands will prevent you from doing that
and potentially loosing data.
