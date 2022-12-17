---
title: "Firewalld in Debian 10"
date: 2021-08-24
tags: ["how-to", "linux"]
type: post
---

In the past, I showed how to add a [firewall rule in Debian
9](/2017/adding-a-firewall-rule-to-debian-9).  For Debian 10, these instructions
still work but installing the `firewalld` package is a bit more involved.

## Why

There is a bug in `iptables` (which is how firewalld applies rules) that causes
it to crash on start up.  Thanks to this [GitHub
Issue](https://github.com/saltstack/salt/issues/55110#issuecomment-546735717), I
was able to track this down to the specific version of `iptables` that ships
with Debian 10 (`1.8.2`).  The good news is `1.8.3` fixes this issue, and that's
available in the backports!

## Fixing The Issue

Debian Backports are packages that have been updated to newer versions since the
release of Debian.  This gets into some of the packaging policies for Debian,
which I won't dive into.  This is a tradeoff many distributions make, run
slightly older software for the advantage of thorough testing and
compatibility.

In this case, we'll use backports to install version `1.8.3` of `iptables`.

To enable backports, create a new file, `/etc/apt/sources.list.d/backports.list`
and add this single line:

```text
deb http://deb.debian.org/debian buster-backports main
```

Then run `sudo apt update` on your system.

To install the updated `iptables` version, run:

```bash
sudo apt install iptables/buster-backports
```

This will upgrade a few other packages, but this is all OK.  Once completed,
restart `firewalld` again to fix its startup issue:

```bash
sudo systemctl restart firewalld.service
```

That's it!  To check if `firewalld` is running, you can use `firewall-cmd
--state`.  It should return `running`.
