---
title: "Custom Debian ISO"
date: 2021-09-07
tags: ["how-to", "linux", "dev-ops", "code"]
type: post
---

If you're installing Debian on a regular basis, or want to automate the
installation a bit more, building a custom Debian installation ISO can be quite
handy.  You can automate some of the more tedious parts of the installation,
install extra packages and run additional setup, or even completely automate the
installation!

## Why?

In my case, I'm working with some automated provisioning using Puppet and
Packer.  Most of the time, you can start with a pre-installed operating system
and work from there. However, for other provisioners, like VMWare, Qemu, and
Proxmox, you need a raw ISO image.

Packer can also type in installation commands and run through the setup in a
hybrid-automatic way, but this required quite a bit of custom syntax, timing
issues, and wouldn't be very portable if things in the Debian installer should
change.

The ideal solution for me was to create a fully-automated installation process
that could be called on a blank virtual machine, and is where the idea for an
automated Debian installer iso came from.

## How?

The tool is actually built into the Debian installer and is called `preseed`.
It takes a configuration file with answers to all of the built-in installer
questions and substitutes things in automatically.

In order to make this fully automated, we also repackage the ISO file with our
customized `preseed.conf` file already installed.  You don't have to go this
far, you can specify `preseed.conf` files on HTTP servers and other external
locations at boot time, but I wanted a fully automatic process.

## The Code

Doing this is pretty straightforward, and I even made a system to do this
automatically.  The scripts I wrote download the latest ISO, verify its
checksum, then extract and repackage it with the required files to make things
automated.  I've placed an example of all of this on
[GitHub](https://github.com/grumpy-systems/debian-iso).

When finished, a single ISO file is output, and booting this ISO will launch a
fully automated installation.  It's important to note that this installation
will _not_ ask you any questions and overwrite anything that's on the first hard
drive.  It also sets an insecure root password that you should immediately
change.

### Preseed Config

The magic file that tells `preseed` what to do is `preseed.cfg`.  This file is
taken directly from the Debian example and options modified to fit our needs.
You can modify this file further, and set different options as you see fit.

### Installation Scripts

Another feature of this code comes in handy for something you can't do with the
vanilla installer, run scripts automatically on the new system.

Running these scripts directly from `preseed.conf` can be a chore, especially
with IO redirection and arguments.  To work around this, I created a helper
script that runs any number of scripts setup in `install.d` at the end of the
installation.

These scripts are also bundled in the ISO file, and executed after the final
installation step of the Debian installer.  This lets you access the new system,
it's just in `/target`.  I have an example file there that automatically sets up
a new sudoers file.

To add more scripts, just add more shell script files into that directory.
There are no arguments when running them, so they'll need to be self-sufficient.

### Isolinux

The final piece of the puzzle we need to modify is Isolinux.  Isolinux is the
bootloader used to load the installer and Linux Kernel, and we need to tell it
to load our preseed file.

There are ways to do this manually without changing anything in Isolinux, but
again I wanted a fully automatic process.  I added `isolinux.cfg` to create a
simple prompt that will give the user a 10 second timeout before booting the
automated installer.

## The Build Process

If you choose to build this, you'll need to run things as `root`.  This is
because the ISO contains a lot of root-owned files, which will lead to some
issues during cleanup if you aren't root as well.

Also, I used Apache Ant to coordinate the build process.  You'll need that to
use the `build.xml` file included.  Some other packages you may need are
`bsdtar` and `gensioimage`.

When you start the build, it first checks to see if there's an ISO locally
available and download one if not.  This comes straight from the Debian release
mirror and will be the latest `netinst` image.

The downloaded ISO is then extracted.  Our files for the `preseed` install as
well as the patched `isolinux.cfg` files are all installed into the ISO, then
it's rebundled.

When things are done, you have an iso in `build/preseed.iso` that you can use to
boot your virtual machine.
