---
title: "TryHackMe: Vulnversity"
date: 2021-07-06T21:05:08-05:00
tags: ["security"]
---

_Meta Information: This is a room I recently completed on TryHackMe.  I figured
I'd do a write up of what I found, how I got in, and things that a potential
sysadmin would want to do to fix their server. I'm writing this from the
point-of-view of a independent security consultant._

## Description of Server

The machine in question appears to be an Ubuntu Linux machine, with a number of
open ports and protocols:

| Port | Application | Notes             |
| ---- | ----------- | ----------------- |
| 21   | vsftpd      |                   |
| 22   | ssh         |                   |
| 139  | samba       |                   |
| 445  | samba       |                   |
| 3128 | squid       |                   |
| 3333 | apache      | Non-Standard Port |

For the purpose of this write up, only the Apache HTTP server was investigated.

## Test Methodology

The penetration testing was performed using Kali linux and the tools associated
with it.  The machine was probed and attacked over a VPN connection, but it is
assumed that the machine would represent an internet-facing machine with no
firewalls or security layers in place other than those present on the machine
itself.

## Apache Server Penetration

The Apache server appears to be serving a public website advertising a
university.  No obvious framework or content generator could be determined.

First, a scan was performed using a directory fuzzing program (`gobuster`) to
discover directories not immediately visible accessible by the normal website
frontend.  An internal upload form (`/internal`) was discovered.

The form appears to implement server side verification for file extension types,
and another fuzzer (`burpsuite`) was used to determine allowed file types.
`phtml` files were allowed, so a reverse shell payload was uploaded as a `phtml`
file.

The upload form placed the payload file in `/internal/uploads`, where it could
then be executed and create a shell session for the `www-data` user, who was
running the PHP process.

Using local enumeration tactics, a single user was found on the server (`bill`),
and this user's home directory was able to be read by the `www-data` user,
yielding the user flag.

`linpeas`, a privilege escalation recon script was uploaded and ran, and it
showed that `/bin/systemctl` was available to our `www-data` user and could be
freely executed.  Another PHP reverse shell payload was uploaded and installed
as a service file, allowing root access to the server.

## Recommendations

### Protect The `systemctl` Executable

This executable was available to the `www-data` user, and allows trivial root
access by use of the `suid` flag.  The permissions on this file should be
changed to block access to only the root user of the system, and the `suid` flag
removed.

### Require Authentication For `/internal`

This form is unsecured and allows uploads to the server from any address.
Access controls should be put in place immediately to prevent unauthorized use.

### Prevent Apache PHP Execution

Once our payload was uploaded, Apache executed the PHP file without question.
This should not be allowed by default.

### Filter User Uploads

In this case, we were able to upload a `php` shell payload, but other malicious
files could be uploaded to the server.  If allowing user uploaded files to be
served publicly, care should be taken to ensure the file is valid for its
intended use, such as ensuring it is truly an image file.

### Adjust User Home Directory Permissions

The `www-data` was able to view the contents of `bill`'s home directory without
any additional privilege escalation.  If sensitive files are being kept in the
home directories, permissions should be adjusted to block public reading.

## Wrap Up

I'm still learning, so I'm sure there are more things wrong with this machine
that I missed.  I'm also sure there's more I can write about, I'll probably
revisit the room once my skills are better and see what else I can find.
