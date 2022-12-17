---
title: "Keeping things updated with Apt-Dater"
date: 2021-12-30
tags: ["linux", "how-to", "dev-ops"]
type: post
---

One challenge of running servers, especially if you have more than a few, is
keeping all of the software up to date on them.  Patches are released
constantly, and keeping software updated is a major security concern.

One great tool that can help automate this is `apt-dater`, a text based utility
that lets you interactively update packages on systems.

## Installing

`apt-dater` is included in the main Debian and Ubuntu repositories, so you just
have to run `apt-get install apt-dater` on the host you'll use to update
systems, and `apt-get install apt-dater-host` on your servers.

### Sudo

You'll need to also configure your user to be able to run `apt` and `apt-get`
without a password if you're not logged in as root.  You can also just login as
root, which is easier but is a bit less secure.

There are a number of ways to accomplish this, but the most straightforward is
to just add a rule in `sudoers` for your user.  You can set up groups to allow
multiple users to run things too.

Create a new file in `/etc/sudoers.d` and call it anything you'd like, I call
mine `grumpy-apt`.  Fill it with these contents:

```plain
grumpy ALL= NOPASSWD: /usr/bin/apt, /usr/bin/apt-get
```

This allows the user `grumpy` to run just `apt` and `apt-get` without a
password.  This won't affect your other permissions, so you'll still be able to
run other commands with sudo with a password.  Replace `grumpy` with whatever
username you use.

Make sure the file is owned by root and has permissions of `440`, otherwise Sudo
won't load it.

```bash
chown root:root /etc/sudoers.d/grumpy-apt
chmod 440 /etc/sudoers.d/grumpy-apt
```

(be sure to replace the file names with what you called your file)

### SSH Keys

You'll need to also be able to login to your servers without a password.  You
can use `ssh-copy-password` to install your key using your existing password
quickly and easily.

## Configuring Apt-Dater

Once your servers are setup, you'll need to tell Apt-Dater which servers to
update.  This is done with a configuration file in
`~/.config/apt-dater/hosts.xml`.

_Note:_ My installation uses XML formatted configuration files, which is what
I'll highlight here.  Newer versions may use a different format, but refer to
the docs for whatever version you happen to install.  I believe XML will work
with newer versions.

`hosts.xml` is fairly simple.  It just contains a list of hosts and groups it
should look to update.  Groups are just used to consolidate things in the UI and
keep things organized.  It's purely cosmetic and you can set them up however
you'd like.

There's some examples in the file already, but this is the basics of how mine
was setup:

```xml
<hosts xmlns:xi="http://www.w3.org/2001/XInclude">
     <!-- Include global config file if available. -->
     <xi:include href="file:///etc/apt-dater/hosts.xml" xpointer="xpointer(/hosts/*)">
        <xi:fallback />
    </xi:include>

    <group name="KC 1">
        <host name="host1.dns" ssh-host="10.0.0.0" />
        <host name="host2.dns" ssh-host="10.0.0.0" />
    </group>
</hosts>
```

There are also options for things like `ssh-user`.  These are the comments from
the examples in the file:

```plain
    The following attributes are known:
    - name    : visible name of the host or group (required)
    - comment : text shown in 'host details' screen
    - type    : transport type (default: 'generic-ssh')
    - ssh-user: overwrite SSH username
    - ssh-host: overwrite SSH host (defaults to @name)
    - ssh-port: overwrite SSH port
    - ssh-id  : overwrite SSH identification file
```

## Using Apt-Dater

Once setup and your hosts are added, you're ready to use Apt-Dater.  Get started
by running `apt-dater` on your workstation.

When it first starts, you'll see a list of statuses, and your hosts will be
divided into each one.  You'll use the arrow keys, enter, and space to navigate
the list.  You'll also use some letter keys to perform actions, but we'll get
there.

Here are the most important states your server can be in:

- *Unknown* - Refreshing the needed updates has failed or hasn't yet been run.
  If the refresh did fail, you can use the `e` key to see the output and the
  potential errors.
- *In Refresh* - `apt-dater` and `apt-get` are working to get the list of new
  packages.  This can take a moment or two.
- *Up to Date* - All the packages are up to date, there's nothing you need to
  do.
- *Updates Pending* - There are updated packages ready to be installed.

If you are just starting, you'll want to refresh all your hosts as their status
can be cached from last time.  Navigate (using `up` and `down`) to the group
you'd like, or drill down to a host by pressing `space` to expand groups.  Then
press `g` to update the package data.

With all the commands I show here, you can run it on a single host, a group of
hosts, or all the hosts in a given status.  For example, you can highlight the
"Unknown" status group and press `g` to refresh all of them at the same time.

Once you have some updates to apply, you can navigate to the host or group and
use the `u` key to trigger the updates.  If you're asking to update an entire
group, `apt-dater` will ask for confirmation.

Once the updates start, you'll be in an SSH session watching the upgrades take
place.  You can sit and watch each host, or you can use `Ctrl+A` then `d` to go
back to the main screen.  The host you were connected to will now be under
`Sessions`.  To go back to the SSH session, navigate to the host and press `a`,
or press `n` from the main screen.  You can have many sessions open at once and
switch between them.

If you have multiple sessions and you disconnect from a host, `apt-dater` will
ask if you'd like to connect to the next open session or go back to the menu.

After the host is updated, it will automatically refresh and go back to the main
screen.  Once everything is updated, you can press `q` to exit.  If certain
words are detected, like `fail` or `error`, `apt-dater` will inform you that
errors were detected and ask what to do.  You can ignore these (`i`) or view the
full update output by pressing `l` to open `less`.  You can also connect (`c`)
to manually sort things out if needed.

## Other Things

If you have many machines, and especially if their publicly available, you'll
want to be subscribed to the security announcements mailing list for your
distribution.  This will give you fairly quick notification when security
updates are available and details on any potential exploits you may need to
watch out for.  Here are the ones for Debian and Ubuntu:

- [Debian](https://lists.debian.org/debian-security-announce/)
- [Ubuntu](https://lists.ubuntu.com/mailman/listinfo/ubuntu-security-announce)

Both of these lists generate a few messages per day, but the information is
worth knowing.

Also, by default `apt-dater-host` will install `needrestart`.  This package
restarts services after running an upgrade and I honestly find it to just be
annoying.  It frequently will cause `apt-dater` to think an error occurred while
updating and stop the smooth flow, so I've just removed it.
