---
title: "LVM Basics"
date: 2021-10-17
tags: ["how-to", "linux", "dev-ops"]
---

This is a quick how-to showing my procedure for setting up new drives with LVM.

## What is LVM

LVM stands for Logical Volume Manager and is a newer way to manage partitions
and disks in Linux.  If you've never used LVM, it makes adding partitions,
resizing things, adding disks, and more easy and slick on Linux.

Basically, it's an abstraction layer between your disks and partitions.  You can
have partitions span multiple disks, change them around on the fly, move them
around, etc without any of the fuss of before.  Additionally, you can give
groups and volumes useful names rather than arbitrary drive letters.

Part of the complexity with LVM is the layering and terminology.  There are a
few extra steps and abstractions you need to setup before you can really use
LVM.  Here's a quick breakdown of the layers:

* `pv` or Physical Volume - A physical drive or partition you want to put LVM
  on.
* `vg` or Volume Group - One or more `pv`'s that will contain volumes.  You can
  use just one, or span things across multiple drives for added capacity.
* `lv` or Logical Volume - A partition or area you'll create a filesystem and
  put data.

As a rule, I use LVM on all my new installations and set it up on any extra hard
drives I add to a machine.

## tldr;

If you're impatient and just want the commands, here they are:

```bash
##
# Setting up a new drive with LVM, adding a volume
##

# Find the device you want to use
lsblk

# Create the PV on that device
pvcreate /dev/<device>

# Create the VG
vgcreate <lv name> /dev/<device>

# Create a single volume taking up the whole volume group
lvcreate -l +100%FREE -n <lv name> <vg name>

# Create a volume with a certain size
lvcreate -L <size> -n <lv name> <vg name>

# Once done, you're new volume will be available at /dev/<vg name>/<lv name>


##
# Resizing an newly-extended virtual drive to use the rest of the space
##

# Extend the VG
pvresize /dev/<device>

# Extend the LV
lvextend -l +100%FREE /dev/<vg name>/<lv name>
resize2fs /dev/<vg name>/<lv name>
```

## Adding a New Drive

In the past, I've gone over how to [resize
partitions](/2016/resizing-lvm-partitions-on-centos/), but here I'll show how to
create an LVM volume on a brand new disk.

To get started, I add a new empty disk to my virtual machine.  This works on
physical disks as well as virtual disks, so if you're on bare metal hardware
this procedure will work just as well.

### Create a PV

The first step is to create a Physical Volume or `pv`.  This is what represents
a physical drive in LVM.

To figure out what drive letter was assigned to your new drive, I use `lsblk`:

```bash
$ lsblk

NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0 55.4M  1 loop /snap/core18/2128
loop1                       7:1    0 70.3M  1 loop /snap/lxd/21029
loop2                       7:2    0 61.8M  1 loop /snap/core20/1081
loop3                       7:3    0 67.3M  1 loop /snap/lxd/21545
loop4                       7:4    0 32.3M  1 loop /snap/snapd/12704
loop5                       7:5    0 32.3M  1 loop /snap/snapd/13170
sda                         8:0    0   32G  0 disk 
├─sda1                      8:1    0    1M  0 part 
├─sda2                      8:2    0    1G  0 part /boot
└─sda3                      8:3    0   31G  0 part 
  └─ubuntu--vg-ubuntu--lv 253:0    0   20G  0 lvm  /
sdb                         8:16   0  120G  0 disk 
sr0                        11:0    1 1024M  0 rom 
```

In the example above, you can see that I have a few `loop` devices, my primary
disk `sda`, and the new `sdb` drive.

To create the actual `pv`, use `pvcreate`:

```bash
pvcreate /dev/<device>
```

There aren't any options to pass in there, and it won't normally ask you for
confirmation.  If LVM finds a filesystem on that disk, it will ask before
overwriting.

### Create a VG

The next layer is a volume group, and this is the first layer you get to name.
These can be single drives or collections of disks that your volumes will live
on.

Here's how you create a VG:

```bash
vgcreate <name> /dev/<device>
```

If you want the VG to span multiple drives, just repeat the `/dev/<device>`
portion for all the drives.

### Create a LV

The final piece of the puzzle is creating a Logical Volume.  This is where
you'll create you're final filesystem.

```bash
# Create a single volume taking up the whole volume group
lvcreate -L+100%FREE -n <lv name> <vg name>

# Create a volume with a certain size
lvcreate -l <size> -n <lv name> <vg name>
```

## Using the LVM Device

Once you've created the logical volume, it's time to start using it.  There's a
couple of places you can go to access the device, but I tend to favor
`/dev/<vgname>/<lvname>`.  For example, if you have a `vg` named `data` and the
`lv` named `backups`, you would use `/dev/data/backups`.

That replaces the old partition scheme of `/dev/sda1` or similar, and as you can
see is much more intuitive and useful.

Once created, you'll need to create your filesystem of choice and add the entry
to `/etc/fstab` like normal.

## Adding Space

If you're like me and run virtual machines, you'll inevitably run out of space
and need to expand the drive.  Thanks to LVM, this process is now a breeze.

First, extend the disk in your hypervisor.

Next, use `vgextend` to make the `vg` take up the rest of the new space:

```bash
vgextend <vg name> /dev/<device>
```

Once that's done, follow the steps [over
here](/2016/resizing-lvm-partitions-on-centos/) to resize the LV.

If you aren't expanding the root disk, you don't even have to take the machine
offline.  you may need to skip the `e2fsck` steps if the filesystem is still
mounted, but that step is optional.
