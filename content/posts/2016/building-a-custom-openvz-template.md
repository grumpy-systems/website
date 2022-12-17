---
title: "Building a Custom OpenVZ Template"
date: 2016-07-27
tags: ["linux", "tools"]
type: post
---

One of the things I’ve thought would be handy for much too long was setting up a
custom template for my virtual machines.  I don’t do anything too crazy, but I
use LDAP and some other utilities that I continually have to setup and configure
on every machine.  The ultimate in convenience would be to create a new virtual
machine and have all the environment specific config done, so I can get right
into building it out.  Creating a template sounds like a headache, but I found
it to be actually quite simple.  Here’s my take on the template creation
process.

## Setup

I used my Proxmox VE environment to do the creation.  This is based on OpenVZ,
but Proxmox introduces it own set of quirks if you try to interface with a more
vanilla OpenVZ system.  I’ll also be basing the template off of a stock standard
Debian 8 template, [this
one](https://wiki.openvz.org/Download/template/precreated) from OpenVZ to be
specific.

## Nitty Gritty

The first step is to setup a container that we’ll modify to meet our needs.
This is pretty self explanatory, but most of the options when creating the
container are irrelevant.  Since we won’t be modifying the script that actually
sets up the new containers based on our template, it will still accept the root
password and hostname from the creation window like before.

## Things You’ll Want To Do

In my case, I wanted a very minimal template since my virtual machines end up
doing any number of things.  If you’re planning on making a template for a
specific type of server then you’ll want to install the common software here.
Something to keep in mind is that this is a template after all, so if you
install every package you’ll ever use it can become quite large and you might
end up spending time removing packages and files, which defeats the purpose of
setting up a template!

Some things you’ll probably always want to do:

* Set Your Timezone: In my case, everything is in one timezone so setting my
  local timezone makes sense here.
* Update Your Packages: This seems a little dumb on the surface since the
  packages will inevitably be out of date when you use your new template.  This
  can’t really hurt anything though, as long as you remember to update the
  packages again once your virtual machine is setup.
* Install Remote Monitoring: I use Zabbix to track all of my machines, so
  installing the Zabbix agent and configuring it to connect to my monitoring
  server makes sense.
* Configure Proxies: If you have any local proxies, you can configure them here.
  In my case, I just have a proxy for apt that every machine uses.  If you don’t
  have some sort of proxy for your package manager, you should probably set one
  up.
* Reset rc.local: The default Debian template comes with an rc.local file that
  finishes some setup on the machine, mainly generating a new set of SSH keys
  for the server.  You’ll want to move the rc.local (which should be mostly
  blank or comments) to rc.local.orig and create a new rc.local with the file
  below.  Feel free to add in other actions you want your machine to perform on
  first boot.

```bash
#!/bin/sh
rm -f etc/ssh/ssh_host_*
/usr/bin/ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key
/usr/bin/ssh-keygen -t dsa -N '' -f /etc/ssh/ssh_host_dsa_key
/usr/bin/ssh-keygen -t rsa1 -N '' -f /etc/ssh/ssh_host_key
/usr/bin/ssh-keygen -t ecdsa -N '' -f /etc/ssh/ssh_host_ecdsa_key
/usr/bin/ssh-keygen -t ed25519 -N '' -f /etc/ssh/ssh_host_ed25519_key
service ssh restart

umask 022
mv -f /etc/rc.local.orig /etc/rc.local
```

I also installed some software specific to my environment like LDAP and
fail2ban.

## Making The Template

When you’re happy, power down the template using the shutdown command or the
OS’s halt command.  Once it’s offline, remove any network interface that are
setup.  Since the wizard that creates machines based off your template will try
and add one anyway, removing the initial one here removes potential duplication.
You’ll also want to make a note of the VMID, since we’ll need that to select the
correct private area.

Then SSH into the PVE Server (the physical machine) and navigate to your
container’s private area.  On a default installation this is at
/var/lib/vz/private, but if you’re using NFS or a RAID array, it might be
different.  CD into the dir that matches the ID of the machine you want to
template. Then tar the machine into a new template:

```bash
tar -cvzpf /root/tarname.tar.gz .
```

Be sure to include the last period!  You can name the template anything you
want, but Proxmox likes things in the following format:

```bash
osname-version-description_arch.tar.gz
```

In our case, our template name is

```bash
debian-8-storehouse_x86_64.tar.gz
```

In my case, I’m putting things into /root so I can download them and install it
on each of my PVE machines.  You can also put it directly into
/var/lib/vz/cache/ to have things ready to go right away.

## All Done

When you’re done tarring things, everything is ready to rock!  In my case I
downloaded the file to install it manually on all my PVE hosts as well has to
have a copy for my records.  These files aren’t that small, mine turned out to
be about 275M, so you could also use SCP to transfer them directly to each host
if you want.

To create a new machine based on your template, just create a container like
normal and select your new template!

Many thanks to James Coyle for a [wonderful walk
through](https://www.jamescoyle.net/how-to/293-how-to-make-a-new-openvz-template-from-an-existing-template-for-proxmox)
of the template creation process.
