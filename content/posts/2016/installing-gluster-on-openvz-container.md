---
title: "Installing Gluster on OpenVZ Container"
date: 2016-12-03
tags: ["dev-ops", "linux"]
type: post
---

Setting up OpenVZ containers to be able to use a FUSE filesystem is pretty
simple, but it takes a bit to figure out exactly which steps you need to
follow.  There are a myriad of tutorials online (and here's yet another), but
this one focuses specifically on Gluster, a distributed network file system.

With Storehouse, we use Gluster to act as our storage backend for most of our
customer data.  By default, our OpenVZ containers could not mount the volume
directly, since FUSE is not enabled.  To work around this initially, we just
mounted the Gluster volume using NFS, which is built into Gluster.  This worked,
but it loses the advantage that the native FUSE client gives of being able to
communicate directly with nodes that have the data, rather than through a single
NFS processes that then can communicate with each Gluster node.

The setup is pretty simple:

### 1 - Power down the container

### 2 - Issue these commands on the host system (in our case, the Proxmox host that runs our container).  Replace ContainerID with the numeric ID of the container from Proxmox

```bash
vzctl set ContainerID --devnodes fuse:rw --save
```

### 3 - Start the container and issue these commands.  These give the FUSE device the correct permissions

```bash
chmod g+rw /dev/fuse
chgrp fuse /dev/fuse
```

### 4 - Create the FUSE group and add user(s) to it.  Since FUSE isn't installed or setup by default, you have to add each user who should be able to use FUSE to a new FUSE group on your system

```bash
# Create the group
groupadd fuse
# Add each user to the group
usermod -a -G fuse username
```

### 5 – Install gluster

```bash
# On our debian systems:
sudo apt-get install glusterfs-client
```

### 6 – Mount! (or add a line to /etc/fstab)

```bash
# Mount directly
mount -t glusterfs gluster_node:/vol /mnt
```
