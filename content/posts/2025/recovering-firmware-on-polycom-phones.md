---
title: "Recovering Firmware Failures on Legacy Polycom Phones"
date: 2025-04-25
tags: ["homelab", "how-to"]
type: post
---

I have a very, _very_ old Polycom Soundpoint IP 321 in a drawer.  This phone
works, and was really only replaced after I migrated to 3CX.  Since migrating
back to a local FreePBX install, I wanted to use the phone in our basement for
an extra landline.

I fumbled through the menus of the phone to reset the configuration and found an
option called "Format Filesystem" and pushed it thinking that would reset the
config.

## What Just Happened

This button does exactly as it implies: it formats the filesystem.  Including
the firmware!  Now when the phone starts, you get an "Application not present"
error and it's stuck in a boot loop.

The idea is that the phone on its next boot would go out to it's provisioning
server and download a new firmware file.  If you don't have a provisioning
server, the phone has nothing to boot and sit in a loop.

With the phone being as legacy as it is and Polycom now being Poly and acquired
by HP, you'll quickly learn the process is less than straightforward.

## Phone Provisioning

IP Phones are designed to be deployed by the hundreds quickly.  A key part of
this is the idea of a provisioning process to roll out config and even firmware.
Provisioning would be handled by your PBX and you'd simply enter the serial or
MAC address of the phone, assign it to a user or profile, plug it into your
network and it'd boot and work with no further intervention.

What's happening under the hood varies by phone, but the process for the Polycom
is this:

The phone boots and attempts to get a DHCP lease.  DHCP can pass out extra
options alongside an IP address, and one of these can be a provisioning server.
This server can run FTP, HTTP, or even TFTP.

The phone reaches out to that server and tries to load a config file specific
for that phone's serial number.  This would normally have things like extensions
to configure and other setting specific to that phone.  If it can't find a
config file specific to itself, it'll download a generic one off the server.

The phone can update firmware this way too.  It'll look for some specific files
when booting and update its bootloader or firmware automatically.

If the phone can't find the provisioning server, it just uses whatever config it
had last and boots.

## Legacy!

If you get yourself in this pickle years ago, there are a number of ways to fix
it.  Polycom operated a server that you could enter into the phone and it'd
self-rescue, but that server has been shut down for a long time.

You can find the latest firmware downloads for these legacy phones, but in my
case the phone would say the application is not compatible and refuse to load
it.

There are a few other sites that do similar things, but these also have their
issues but piecing together a few things we can make it work.

## Recovery

Enough theory, this is how I dug myself out:

### 1) Set up a provisioning server

A provisioning server is actually just an HTTP server, so a live CD with Nginx
works.  You don't need to worry about DHCP options since we can set things in
the phone manually.

The only thing it needs is a few MB of disk space, but no SSL or any extra
config is required.  For our rescue instance, I threw a live CD on the same
subnet and just did everything as root in `/var/www/html`.  Don't do this long
term, we only need this while we boot the phone and recover it.

### 2) Set the phone up

We need to tell the phone about our new server.  As the phone boots, there
should be a "Setup" soft key with menu options for DHCP and the like.  Disable
DHCP and navigate to "Server Settings".  Set the protocol to HTTP, set your IP
address of your live CD and clear the username and password.

The phone will probably need its default password of `456`.

As the phone reboots and starts, if you watch the access log of your live CD you
should see requests coming from the phone now.  If you do, the phone is looking
for it's provisioning data.  If not, troubleshoot before moving on further.

__Why don't I run a provisioning server?__  Well, this site is behind Cloudflare
and requires HTTPS.  I have no idea if the old phone supports the modern flavors
of TLS required, if it can use SNI, or if support would break.  Also, you might
have to modify the files a bit or otherwise vary things for your specific phone.

### 3) Get Firmware

This is the "hard" part, but I'll help you out.  In my case I needed firmware,
but I also needed to update the bootloader to be compatible.  We also need to
composite a few things.

The first is the firmware files.  I got those from
[ProVu](https://blog.provu.co.uk/polycom-recovery-resolve-a-formatted-file-system/).
Their site _almost_ works, the config file redirects to a broken HTTPS link
which the phone and any browser can't handle.

To get the config files, I nabbed them from the factory firmware file
[here](https://downloads.polycom.com/voice/voip/sip_sw_releases_matrix.html).

I've bundled it all up in a Tar file
[here](/downloads/PolycomRecoveryFirmware.tar.gz), download that to your live CD
and extract it in `/var/www/html`.

### 4) Watch the phone and logs

If the phone is still in its reboot loop, the next boot it should update the
bootloader.  The phone's screen will show you the progress there.

After that update and reboot, the phone will then update the application
(firmware).  It will then reboot again and should go to an idle screen.  If you
reach that point, the phone is fully updated and you should be able to configure
it via the web UI.

Watching the logs for Nginx will help as you can see the phone make requests and
see if any files are missing its needing.  I tried this with my IP 321, but it
_should_ work for others.  I have no way of testing, though.

Once the phone is booted and you've configured it in the web UI, you can tear
down your provisioning server since its not needed anymore.
