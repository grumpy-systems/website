---
title: "Staggering Chef Client Runs"
date: 2017-07-20
tags: ["dev-ops", "how-to", "linux", "tools"]
---

One of the new tools I've discovered is Chef to manage the configuration and
software on Storehouse's fleet of virtual machines.  Chef makes it really handy
to update and track config changes, since everything can be tracked using Git or
similar.  One issue we ran into was having `chef-client` run at the same time
for multiple machines.

This issue is kinda subtle, but makes a lot of sense when you think about it.
In our case, we wanted chef-client to run automatically and periodically to
propagate config changes to all of our machines.  I'm pretty good about running
chef-client manually when I make a config change, but it's possible that I
forget or overlook running it on a machine.  To combat this, I set a cron job to
run chef-client daily.

The problem with this cron job is that it set all the machines to run
chef-client at the same time.  Usually this isn't a problem, but if there are
config changes the server may have to rebuild caches or assets and would be
unable to serve requests for a minute or two.  Running everything at the same
time meant that all the machines would go offline at the same time, and cause a
brief outage while they all updated.

Another example of this issue is with our MariaDB cluster.  We manage the config
via Chef and have a recipe to update the file and restart MariaDB when the file
is updated.  When all cluster nodes run at the same time, and restart MariaDB at
the same time, the cluster goes down.

## Staggering Runs

The solution is straightforward: just stagger when clients run chef-client to
make sure groups of nodes that update at the same time can all go offline at the
same time without issue.  To do this, we tracked the time in the attached
LibreOffice Calc spreadsheet, and just assign machines to a group.  We then
updated our cron file to use an hour and minute set by the node's config in
chef, so we can control the time each node runs and updates.

[Example File](/downloads/chef-timings.ods)
