---
title: "Monitoring a Mount Point With Zabbix"
date: 2017-03-29
tags: ["dev-ops", "linux"]
type: post
---

A subtle issue I ran into was the issue that Proxmox VE would sometimes unmount
a GlusterFS volume and would fail to backup.  This issue was a bit sneaky
though, since the PVE backup program wouldn't execute it wouldn't send an email
notifying me of the failure.  This would make it so the backups would fail
silently for some time, until I happened to login and see the errors in the
cluster's log.

To combat this, I decided to make sure that the Gluster volume is mounted via
Zabbix.  This isn't configured out of the box, but is really easy.

**Thanks to Kristian for a more robust Zabbix configuration!**

First, we need to setup a new user parameter to let us check if the fs is
mounted.  Create `userparameter_mount.conf` in the
`/etc/zabbix/zabbix_agentd.d/` dir on every machine you want to check the mount
point on:

```bash
# Given two arguments, a mountpoint ($1) and an option ($2), this UserParameter
# will return 0 if the mountpoint is mounted with (at least) the options
# specified, or 1 if not. You need to supply both arguments. If you don’t
# really care about any options, supplying ‘rw’ for a read-write filesystem is
# a good fallback. Multiple required mount options can be supplied as a comma
# separated list, as long as it is surrounded by double quotes (e.g.
# vfs.fs.mounted[/,”rw,relatime”]).
# findmnt prints source as output, but we don’t care about it in this context.
UserParameter=vfs.fs.mounted[*],findmnt -nr -o source -T $1 -O $2 > /dev/null && echo 0 || echo 1
```

Restart the Zabbix agent on the machine, then, login to your Zabbix frontend and
create a new item to watch the mount point.  In my case, I added the item to a
template.  Under Items, select to add a new item and set it up like this:

```text
Key: vfs.fs.mounted[/mnt/gv0,”rw”])
Application: Filesystem
```

You can opt to set different monitoring intervals and retention periods, but for
me the default was fine.  You can set the name to anything you’d like.  Update
the path to the path of the mounted directory and set an option to check for.
The user agent file verifies not only that the FS is mounted, but that it is
mounted with certain options (basically meaning that it’s mounted correctly).
If you just want to make sure that things are mounted, “rw” is a good fallback.

Now we need to create a trigger to let us know if the value changes.  To do
that, go to triggers and create a new one.  Set the name to anything you’d like,
in my case I called it ‘GV0 is not mounted on {HOST.NAME}.’  Click Add next to
the expression to add the logic that triggers the alarm.  For the item, navigate
to the host or template and select the item you created before.  For the
Function, choose ‘Last (most recent) T value is = N’ and set N as 1.  This will
fire the trigger if the item is ever set to 1, meaning the FS isn’t mounted.

After that you can pick your severity and you’re ready to rock!

### Optional: Set Up Value Mapping

An optional step is to setup a value map in Zabbix so the 1 and 0 value coming
from the Zabbix agent is translated into human readable status names like
“Mounted” and “Not Mounted.” To add this, create a new value map by clicking the
“Show Value Mappings” link next to the field “Show Value As.”  In there, you can
create a new mapping and set 0 for “Mounted” and 1 for “Not Mounted.”
