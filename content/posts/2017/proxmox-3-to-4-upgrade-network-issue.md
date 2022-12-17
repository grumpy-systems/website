---
title: "Proxmox 3 to 4 Upgrade Network Issue"
date: 2017-01-23
tags: ["dev-ops", "linux"]
type: post
---

This is a problem that showed itself when upgrading our Proxmox 3.2 Nodes up to
Proxmox 4.  About halfway through the upgrade, our network adapters suddenly
stopped being able to communicate with any local addresses, but could still ping
outside addresses.

The cause was a minor config change that gets added in pretty stealthy.  When
this happens, simply add the following line to the bridge config in
/etc/network/interfaces:

```text
bridge_vlan_aware yes
```

To make the entire config section resemble:

```text
auto vmbr0
iface vmbr0 inet static
    address  192.168.3.xxx
    netmask  255.255.255.xxx
    gateway  192.168.3.xxx
    bridge_ports bond0
    bridge_stp off
    bridge_fd 0
    bridge_vlan_aware yes
```

This was pretty subtle to find, but after completing the upgrade and logging
into the new Proxmox interface, it’s an option under the Network settings for
that host.
