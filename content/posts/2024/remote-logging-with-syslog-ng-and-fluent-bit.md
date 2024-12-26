---
title: "Remote Logging with Syslog-ng and Fluent Bit"
date: 2024-12-27
tags: ["homelab", "how-to", "linux"]
type: post
---

One good practice for most environments is centralized logging.  This is
recommended in a number of security benchmarks, but the idea is largely to keep
logs outside a device that can get compromised.  If a device does get taken
over, even if it's wiped clean the logs and traces of what went wrong can
hopefully survive.

Even in my homelab, I still see benefit.  Some network gear, namely my Unifi
switches and Access Points keep very good logs but they are reset every time a
device reboots.  Alongside this, having logs in one place is a great benefit
just for visibility into what's going on.

## Why `syslog-ng`

When looking for a solution, though, I wasn't too impressed with some of the
more complete frameworks like Loki and Graylog.  These all looked really
wonderful and would be a dream to use, but I ran into issues with each one I
looked at:

* Some didn't support plain syslog.  For virtual machines and things running
  Linux installing an Agent is no big deal, but for other devices that speak
  just plain syslog, I'd need another tool to convert the data.
* Some needed you to define the data structure of all the logs files before it
  became useful.  For a lot of logs like access logs, templates are built in and
  ready to use.  But for others, I'd be losing a lot of the benefit of the
  advanced tool.
* These tools were very, very heavy.  System requirements needed several GB of
  memory and lots of CPU, which seemed excessive since I didn't plan on using
  this log tool every day.

There's a much simpler solution, though, and that's `syslog-ng`.

If you look at basic packages that take logs in and write them to a folder, the
two big players are `rsyslog` and `syslog-ng`.  Both were good choices, but I
went with `syslog-ng` simply because the configuration file seemed easier for me
to understand.  It was fairly flexible in defining and input, filter, and output
then chaining all of those together.

This program is quite basic, though, as it just takes logs in and writes them to
files.  Tools to view logs and do more detailed analysis are outside the scope
of `syslog-ng` and this guide.

## Setting Up `syslog-ng`

The great part of `syslog-ng` is it's pretty widely available and is probably
already in your distribution's repos.  After installing, we'll need to set up a
few things.

First, edit the `/etc/syslog-ng/syslog-ng.conf` file.  I replaced all the defaults with this file:

```
@version: 3.38
@include "scl.conf"

# Syslog-ng configuration file, compatible with default Debian syslogd
# installation.

# First, set some global options.
options {
  chain_hostnames(off);
  flush_lines(0);
  use_dns(yes);
  use_fqdn(yes);
  dns_cache(yes);
  owner("root");
  group("adm");
  perm(0640);
  stats_freq(0);
  bad_hostname("^gconfd$");
};

########################
# Sources
########################
# This is the default behavior of sysklogd package
# Logs may come from unix stream, but not from another machine.
#

# External Source
source s_external
{
    # Typical BSD Syslog
     syslog(
        flags(no-multi-line)
        ip(0.0.0.0)
        keep-alive(yes)
        keep_hostname(yes)
        transport(udp)
# TLS Options
#        tls()
    );
};

destination d_ext
{
  file("/var/log/remote/$FULLHOST_FROM/$YEAR/$MONTH/$DAY/$PROGRAM.log" \
    owner(root) group(adm) perm(0644) dir_perm(0755) create_dirs(yes));
};

# Send the remote logs to the local file paths
log {
  source(s_external);
  destination(d_ext);
};

###
# Include all config files in /etc/syslog-ng/conf.d/
###
@include "/etc/syslog-ng/conf.d/*.conf"
```

There are a few things to note here:

* Lines 8-19 are global options, and we're enabling PTR lookups for IP
  Addresses.  In my network, each IP address has a descriptive PTR record (or
  reverse DNS) that gives a canonical hostname.  We use that to set the hostname
  for each host's directory to keep things uniform and informative.
* Lines 29-41 set up the input for remote logs.  We don't enable TLS since all
  our logs just travel over a local network, but it isn't a bad idea.
* Lines 43-47 set the destination.  We write our logs to `/var/log/remote`, then
  organize based on hostname and date.  There are a number of variables
  (`syslog-ng` calls them macros) you can use as well:
    * `FULLHOST_FROM` - The FQDN of the ip that sent us the logs.
    * `YEAR`, `MONTH`, `DAY` - The date pulled from the timestamp on the logs.
    * `PROGRAM` - The program field in the log file.  More on this later.
    * More are listed [in the
      docs](https://syslog-ng.github.io/admin-guide/110_Template_and_rewrite/000_Customize_message_format/004_Macros_of_syslog-ng.html).
* Lines 50-53 chain the input and output together.  If you want other inputs or
  outputs, you can repeat this for each.

When you restart `syslog-ng` it should be listening and accept logs if you send
them in.  By default, this is UDP port 514.

You can test by setting up a device with a ready-made syslog integration and you
should start to see files created in `/var/log/remote`.

## Setting up Fluent Bit

Now we need to forward logs into our syslog machine, but this gives us a bit of
a challenge again.  Programs like `syslog-ng` and `rsyslog` can accept logs from
files, but I wasn't too thrilled with their `journald` integration.  All of my
machines are running Debian 12, so `journald` is a must as most of the logs are
only available there.

Setting up things to input, modify, and send logs and do so in a way that could
be automated via Puppet lead me to an old friend from work, Fluent Bit.  Fluent
Bit is a lightweight log parsing and forwarding agent that can do a lot of
things, including syslog.

To run this, we'll need to add a repository to the machines to make the software
available.  [Their
docs](https://docs.fluentbit.io/manual/installation/getting-started-with-fluent-bit)
have a lot of guides for specific distros, including oneline installs.  If
you're on Debian like me, run this:

```bash
curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
```

To configure the agent, modify `/etc/fluent-bit/fluent-bit.conf`:

```
[SERVICE]
    # Flush
    # =====
    # set an interval of seconds before to flush records to a destination
    flush        3

    # Daemon
    # ======
    # instruct Fluent Bit to run in foreground or background mode.
    daemon       Off

    # Log_Level
    # =========
    # Set the verbosity level of the service, values can be:
    #
    # - error
    # - warning
    # - info
    # - debug
    # - trace
    #
    # by default 'info' is set, that means it includes 'error' and 'warning'.
    log_level    info

    # Parsers File
    # ============
    # specify an optional 'Parsers' configuration file
    parsers_file parsers.conf

    # Plugins File
    # ============
    # specify an optional 'Plugins' configuration file to load external plugins.
    plugins_file plugins.conf

    # HTTP Server
    # ===========
    # Enable/Disable the built-in HTTP Server for metrics
    http_server  Off
    http_listen  0.0.0.0
    http_port    2020

    # Storage
    # =======
    # Fluent Bit can use memory and filesystem buffering based mechanisms
    #
    # - https://docs.fluentbit.io/manual/administration/buffering-and-storage
    #
    # storage metrics
    # ---------------
    # publish storage pipeline metrics in '/api/v1/storage'. The metrics are
    # exported only if the 'http_server' option is enabled.
    #
    storage.metrics on

    # storage.path
    # ------------
    # absolute file system path to store filesystem data buffers (chunks).
    #
    # storage.path /tmp/storage

    # storage.sync
    # ------------
    # configure the synchronization mode used to store the data into the
    # filesystem. It can take the values normal or full.
    #
    # storage.sync normal

    # storage.checksum
    # ----------------
    # enable the data integrity check when writing and reading data from the
    # filesystem. The storage layer uses the CRC32 algorithm.
    #
    # storage.checksum off

    # storage.backlog.mem_limit
    # -------------------------
    # if storage.path is set, Fluent Bit will look for data chunks that were
    # not delivered and are still in the storage layer, these are called
    # backlog data. This option configure a hint of maximum value of memory
    # to use when processing these records.
    #
    # storage.backlog.mem_limit 5M

@INCLUDE conf.d/*.conf

[FILTER]
    Name record_modifier
    Match *
    Record hostname ${HOSTNAME}

[OUTPUT]
    name  syslog
    match *

    host            remotehostip
    port            514
    mode            udp
    syslog_format   rfc5424

    syslog_appname_key appname
    syslog_procid_key procid
    syslog_msgid_key msgid
    syslog_message_key message
```

There's a few options to set:

* Line 5 - I set to flush logs every 3 seconds, but adjust this as you want.
* Line 95 - Set the IP or hostname of your `syslog-ng` machine.

Besides those, this file also will add a `hostname` field to each log it
forwards, and look for configuration files in `/etc/fluent-bit/conf.d`.  In my
case, I use puppet to set up logging for services, and each entry just creates a
new file in that directory.

## Getting Logs

In my setup, I have two sources of logs: files and journald.  You can do a lot
more with Fluent Bit, check [their
docs](https://docs.fluentbit.io/manual/pipeline/inputs) for all their inputs.

For a `journald` log source, I use this config:

```
[INPUT]
    Name            systemd
    systemd_filter  _SYSTEMD_UNIT=$UNIT
    Tag             $NAME
    Read_From_Tail  on

[FILTER]
    Name    modify
    Match   $NAME
    Rename  MESSAGE message
    Add     appname $NAME
```

Update `$UNIT` on line 3 with the SystemD unit to watch, for example
`puppet.service`.  Also replace all the `$NAME` entries with some descriptive
name.  We use this to set an `appname` field for the syslog protocol, but we
also use it to match the filter to allow for multiple sources without conflict.

For log files, I use this config:

```
[INPUT]
    Name    tail
    Path    $PATH
    Tag     $NAME

[FILTER]
    Name    modify
    Match   $NAME
    Rename  log message
    Add     appname $NAME
```

Update `$PATH` with the log file to watch, and `$NAME` in the same way as
`journald` logs.

Write a file for each log to `/etc/fluent-bit/conf.d`, and name each file
something like `app.conf`.  Restart fluent-bit and you should see logs on the
`syslog-ng` machine.

If you need to troubleshoot, you can add another output section to output into syslog:

```
[OUTPUT]
    name stdout
    Match  $NAME
```

Replace `$NAME` with the name set elsewhere, and you should see logs in Fluent
Bit's output with each field called out.  Each input can have different fields,
so if you're adding another type you may need to overwrite fields or change them
with filters similar to what I did above.

## Purging Logs

You should now have logs flowing into the `syslog-ng` machine that you can tail.
These logs will continue to be written, but after some time we would like to
compress and clean them up.

I use two crons to do this, I compress logs that are older than 1 day to make
sure they're done being added to.  I then clean files older than 90 days.

On the syslog server, add this file to `/etc/cron.daily/log-cleanup`:

```bash
#!/bin/bash

set -e

DIR="/var/log/remote"

find $DIR -mtime +90 -print -delete
find $DIR -type d -empty -print -delete

find $DIR -mtime +1 -name '*.log' -print -type f -exec gzip {} \;
```

Be sure to make the file executable with `chmod 0755
/etc/cron.daily/log-cleanup`.  This will clean, compress, and remove empty
directories to keep your log folder clean.

## Wrap Up

After all this, you should have a central place for logs for your entire
network.  All the logs are in `/var/log/remote`, so it's an easy task to back it
up further or put it on a larger disk.
