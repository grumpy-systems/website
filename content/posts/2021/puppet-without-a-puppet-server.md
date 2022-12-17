---
title: "Puppet Without a Puppet Server"
date: 2021-08-04T21:28:15-05:00
tags: ["how-to", "linux", "dev-ops", "code"]
type: post
---

One tool that is pretty neat for anyone who manages more than one machine is
Puppet.  In it's simplest form, Puppet is designed to codify actions you may
take on your server and run them automatically.

The typical deployment for Puppet relies on a central Puppet server (the
"Puppetmaster"), and clients distributed around your network.  What if, say, we
wanted to run Puppet without this central server?

## Why

Puppet is great, and a centralized Puppet server is equally great.  For my small
home environment though, it just seemed like overkill.  In all, I run less than
10 machines and don't really have a ton of extra resources to spare.

Additionally, Puppet Clients rely on certificates and certificate authorities to
authenticate to the central server.  While very manageable and sensible, it can
be somewhat daunting to a new user.

## What Puppet Does

I use Puppet in my home lab to manage common settings that I want on every
machine.  These are things like ensuring SSH is blocking root logins, making
sure programs like Sudo are installed, and making sure the machine is configured
to use my Apt Mirror.  All of these things are fairly trivial to set up on their
own, but once you manage multiple machines and need to make a change across all
machines, it can become quite a chore quickly.

Puppet allows me to write a series of manifest files that define how a system
should look when it's set up, ie which user accounts should exist, specific
files I want defined, etc, and run those actions across all my machines.  This
way when I need to make a change to a common configuration component, I can make
it in once place and push the changes out automatically.

Running Puppet without its central server doesn't really introduce any major
drawbacks.  For simple provisioning I find it to be a quick and easy middle
ground between manual setup tasks and the task of setting up a centralized
server.

## Demo Code

I put a demo of how all of this works on
[GitHub](https://github.com/grumpy-systems/puppet-without-a-server), so feel free to
use it as a jumping off point for your setup.

**This code is intended only to work with Debian based systems, so you will need
to modify it if you are on another platform.**

If you haven't used puppet before, it's a great idea to look at their
[documentation](https://puppet.com/docs/puppet/7/puppet_index.html) and
specifically their [resource
types](https://puppet.com/docs/puppet/7/resource_types.html), which are the
specific actions you can have puppet take.

The repository contains a `manifests` and a `modules` directory, both of which
are required.  The `manifests` directory is where you define puppet manifest
files that define what actions to take.  `modules` contains reference files for
your manifests.

As an example, I've included a simple manifest that creates a `hello-world.txt`
file in `/etc`.

### Configuring the Demo

There's a couple of things you'll want to change if you fork the demo code.
Specifically, these are some URLs that should point to the repository you're
setting up.  References exist in `README.md` (the example init invocation) and
in `init.sh` and `update.sh` (in the `REPO` variable).

### Running the Demo

If you do want to run the vanilla demo, you can use this example:

```bash
curl -s https://raw.githubusercontent.com/grumpy-systems/puppet-without-a-server/master/init.sh | bash
```

Run that as root to download, initialize, and run the demo.  Also feel free to
inspect `init.sh` before running, as it's always good practice.

### How This Code Works

First, you'll want to run `init.sh` to kick things off.  The example above
simply downloads the script and immediately runs it via `bash`.  This script
does a couple things to get ready:

* Install the Puppet apt repository and install the `puppet` executable.
* Install `git`, as that's how we download and update the various files for this
  system.
* Clone the code to `/var/local-provision`.
* Run puppet.

The real magic in running puppet is this line:

```bash
puppet apply --detailed-exitcodes --modulepath=$DIR/modules $DIR/manifests
```

That tells puppet to run and points it at our local modules and manifest
directories, which it uses to configure the system.

There's also an `update.sh` file, which is designed to run periodically and keep
the system updated as needed.  This step is completely optional, and you can use
this tool just for setting up machines if you want.

## Wrapping Up

This system is a pretty quick-and-dirty way to provision new servers on your
network and, to me at least, is a nice middle ground between automation and
full-blown configuration management solutions.  I've started to use this to make
all my systems uniform and take care of common security and maintenance tasks
that otherwise would require me to run things individually.

I hope you get some mileage from this!
