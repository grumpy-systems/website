---
title: "Adding a Firewall Rule to Debian 9"
date: 2017-10-17
tags: ["dev-ops", "linux"]
aliases: [
    "/2017/10/adding-a-firewall-rule-to-debian-9/",
]
---

Not too long ago in the Linux world, firewall rules were complex.  iptables did
its job very well, but managing rules was daunting for a newcomer.  Debian 9
introduces some changes that make it pretty simple to add a firewall rule.

Usually firewall rules are taken care of automatically, when you install a
program it takes care of opening up the required ports for itself.  In some
cases, software can conflict and that is what happened in my case.  Virtualmin
blocked the port for Zbbix (10050), since it overwrote all the firewall rules.

To add a new rule, we’ll use the newer `firewall-cmd` command.  To add a rule,
run `firewall-cmd --permanent --zone=public --add-port=10050/tcp` replacing
10050 and tcp with your port the protocol to open.  When done, reload the
firewall with service firewalld restart and your new rule should be applied.

That’s it!  Really!  If you Google how to add Firewall rules, you’ll see loads
of examples for creating init scripts that add iptables rules when your machines
starts, but firewall-cmd does all that heavy lifting now.
