---
title: "GlusterFS Client Log Files Are Huge"
date: 2016-08-11
tags: ["linux"]
type: post
---

This is an issue I recently fixed on our GlusterFS installation, but I didn’t
see anything directly on Google for lazy people like myself.  The issue is that
the log files in /var/log/glusterfs are HUGE.  Ours ended up being > 30 GB after
about a day and ended up causing issues since the filesystem of our container
filled up.

Our log files were lots of:

```text
[2016-08-24 13:51:20.776255] I [dict.c:370:dict_get] (-->/usr/lib/x86_64-linux-gnu/glusterfs/3.5.2/xlator/performance/md-cache.so(mdc_lookup+0x2ff) [0x7fd05c6e4c6f] (-->/usr/lib/x86_64-linux-gnu/glusterfs/3.5.2/xlator/debug/io-stats.so(io_stats_lookup_cbk+0x114) [0x7fd05c4ce6d4] (-->/usr/lib/x86_64-linux-gnu/glusterfs/3.5.2/xlator/system/posix-acl.so(posix_acl_lookup_cbk+0x1e6) [0x7fd05c2b9926]))) 0-dict: !this || key=system.posix_acl_access
[2016-08-24 13:51:20.776281] I [dict.c:370:dict_get] (-->/usr/lib/x86_64-linux-gnu/glusterfs/3.5.2/xlator/performance/md-cache.so(mdc_lookup+0x2ff) [0x7fd05c6e4c6f] (-->/usr/lib/x86_64-linux-gnu/glusterfs/3.5.2/xlator/debug/io-stats.so(io_stats_lookup_cbk+0x114) [0x7fd05c4ce6d4] (-->/usr/lib/x86_64-linux-gnu/glusterfs/3.5.2/xlator/system/posix-acl.so(posix_acl_lookup_cbk+0x232) [0x7fd05c2b9972]))) 0-dict: !this || key=system.posix_acl_default
```

Our /etc/fstab line looked like:

```fstab
atlantia.sthse.co:/gv0    /mnt/gv0    glusterfs    _netdev,acl,defaults    0    0
```

It’s a simple fix, the default log level (INFO) is much too verbose, and outputs
much more than it needs to into the logs.  Fixing this is a simple update to
/etc/fstab:

```fstab
atlantia.sthse.co:/gv0    /mnt/gv0    glusterfs    _netdev,acl,log-level=WARNING,defaults    0    0
```

Notice the addition of the log-level=WARNING.  There are different log levels,
depending on how much data you would like that are listed in the mount.glusterfs
man page.

Platform is Debian 8.5, glusterfs-client version 3.5.2-2+deb8u2,
glusterfs-common version 3.5.2-2+deb8u2
