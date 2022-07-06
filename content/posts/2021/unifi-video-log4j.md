---
title: "Addressing the log4j Vulnerability in Unifi Video 3.10.13"
date: 2021-12-11T00:03:41-06:00
tags: ["linux", "security", "how-to", "homelab"]
---

If you've been on the Internet at all today, you've probably heard that there is
a pretty nasty RCE issue with `log4j`, a logging package for Java applications.
The CVE is [CVE-2021-44228](https://nvd.nist.gov/vuln/detail/CVE-2021-44228),
and is a pretty scary RCE bug that is already being exploited in the wild.

_Update: I originally had comments in this post stating Ubiquiti should update
the NVR software.  I've since learned it's officially deprecated and won't be
receiving any updates._

_Update 2: Method 1 highlighted below was found to not actually mitigate the
threat, as the version of log4j included doesn't support the flag.  I've been
running Method 2 for some time and have had no issues.  I recommend doing that._

_Update 3: As far as I know this does not address the subsequent DoS
vulnerability (CVE-2021-45105)._

The [Unifi
Controller](https://community.ui.com/releases/UniFi-Network-Application-6-5-54/d717f241-48bb-4979-8b10-99db36ddabe1)
is already confirmed to use the afflicted version, and a new release has already
been patched.

Since the Unifi Video NVR product is not supported anymore (they've shifted
focus onto the dedicated hardware products and Unifi Protect), there is no
update in the works for this older software. If you're like me and still have
one of these installs around, you're probably wondering if it's affected and how
to fix it.

**Yes, 3.10.13 contains an un-patched log4j version that is affected by the CVE.
If you have a Unifi Video server and it's exposed to the Internet, you'll likely
want to patch your system.**

## Method 1: Disable Lookups

**This does not mitigate the threat (see update 2 above).  It's included just
for historical reasons**

This method sets a soft flag that prevents `log4j` from doing the external
lookups that cause so many issues.  There's a [community
post](https://community.ui.com/questions/Mitigating-the-Java-Log4J-exploit-in-UniFi-Video-on-Debian-Ubuntu/c59621d2-3cbf-48aa-9780-76477e0b1d39)
that highlights the same workaround, and credit is due to them for sharing the
solution as well.

To patch things, edit `/usr/sbin/unifi-video` and find the `JVM_OPTS` section.
This is around line 231 in the file.  Searching for either `JVM_OPTS` or
`JVM_EXTRA_OPTS` should get you pretty close.

Add this line _before_ the `JVM_OPTS` line:

```bash
JVM_EXTRA_OPTS="-Dlog4j2.formatMsgNoLookups=true ${JVM_EXTRA_OPTS}"
```

Save that file and restart Unifi Video:

```bash
service unifi-video restart
```

### What This Edit Does

`/usr/sbin/unifi-video` is a pretty long wrapper script for starting the Java
process, MongoDB process, and some other processes to make Unifi Video work.  We
add the `log4j2.formatMsgNoLookups=true` option to JVM when it starts the Unifi
Video JAR, which effectively mitigates the vulnerability.

## Method 2: Remove the JndiLookup Class

_This protects against both
[CVE-2021-44228](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-44228)
and
[CVE-2021-44228](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-44228)._

This is a bit more of a complex solution, but removes the vulnerable code from
the application entirely.  I've run this setup on my local instal without issue
for some time now, so I'm confident in its stability.

This method is taken from
[VeraCode](https://www.veracode.com/blog/security-news/urgent-analysis-and-remediation-guidance-log4j-zero-day-rce-cve-2021-44228),
and seems to work just fine on Unifi Video.

First, let's take a backup of the jar we're going to modify:

```bash
cd /usr/lib/unifi-video/lib
cp log4j-core-2.1.jar /root/log4j-core-2.1.jar.bak
```

Next, let's remove the JndiLookup class from the `log4j-core` package:

```bash
zip -q -d log4j-core-*.jar org/apache/logging/log4j/core/lookup/JndiLookup.class
```

Restart Unifi Video as normal:

```bash
service unifi-video restart
```

### What This Does

This patches the JAR file used by Unifi Video itself to not include the lookup
class at all.  This class, as far as I am aware, is the source of the vulnerable
code.  This removes the class entirely from the `log4j` library.
