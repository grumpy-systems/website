---
title: "Smart Failover With Redis Sentinel and Keepalived"
date: 2017-12-18
tags: ["dev-ops", "how-to", "linux"]
---

Through some Google-fu and some other great tutorials, I’ve successfully setup a
groups of Redis machines with automatic failover detection via keepalived and
sentinel.  This sounds mundane, but lets you setup another layer of protection
for your Redis cluster without lots of extra configuration.

## Background – Redis Sentinel and Keepalived

Redis Sentinel makes it pretty easy to setup a group of replicated Redis
machines and elect new master nodes when others are offline.  Sentinel is nice
because it actually checks if the Redis instance is running and responding to
requests.  This makes it nice for clients, who can now be assured that the
master node set by sentinel is truly active.

Many clients support sentinel out of the box, including several PHP clients.
These query the sentinel server to check with node is master then connect to the
master node.  In some cases though, you have to rely on another service, such as
keepalived in this case, to float an IP address between the redis nodes so
clients can always connect.

The problem arises when Redis fails on a machine, but keepalived is in the dark
about the failure.  Keepalived in its default configuration only checks if the
node’s interface is up, so Redis could be failed on a node or a different node
elected master and clients connecting to the virtual IP are connecting to the
wrong host.

## Solution – Keepalived Monitor Scripts

The solution is elegantly simply and built right into keepalived, monitor
scripts.  Basically, these are scripts that run periodically and tell keepalived
if the current node should be promoted or demoted based on more advanced
criteria outside of what keepalived monitors.

To enable this, we first need to create a script that will run and check if a
redis instance is the current master of a pool.  We do this with a simple shell
script

```bash
#!/bin/bash

# This is a helper script to check if the current redis instance is the master of the replication scheme.
# This accounts for cases when the local redis instance is down. Since that means this node can't be the master, we handle
# that gracefully.

REPLICATION_DATA=`redis-cli -a $1 info replication 2> /dev/null`

if [ $? -ne 0 ]; then
 exit 1;
fi

# Check the data for master information
echo $REPLICATION_DATA | grep -q 'role:master'

exit $?
```

Basically, this script just checks the replication status and returns 0 if the
node is master, and 1 if the node is not master.  For reference, the script is
called as `check_master redis-cli-password`  In our case, we require
authentication, so we add `-a $1` to the redis-cli command to handle it in one
go.

Now we need to setup keepalived as we would before.

```conf
vrrp_instance redis_failover {
  state BACKUP
  virtual_router_id 100
  interface ens18
  priority 100
  authentication {
     auth_type PASS
     auth_pass ....
  }
  virtual_ipaddress {
    xxx.xxx.xxx.xxx
  }
  track_script {
    redis_failover_track
  }
}
```

The only real change in that file is the track_script section, which tells
keepalived to run the script we setup in the next file.

```conf
vrrp_script redis_failover_track {
  script "/usr/bin/redis_is_master ...."
  interval 30
  weight 50
  fall 2
  rise 2
}
```

This is the config that actually tells keepalived how to handle the script.
Basically, we give it which script we’d like to run, set how often we’d like it
to run (`interval`), the change in `weight` and `rise` and `fall` which describe
how many failures are required before the node is promoted or demoted.

## Theory of Operation

Basically, keepalived uses the script to either promote or demote the server by
setting a new priority.  When the server is promoted, the value of `weight` is
added to the default priority of 100, making it 150.  Since Redis only elects
one master at a time, only one node will have a priority of 150 and will become
the master of the vrrp pool.

When the script exits with an exit code of 0, the node is promoted.  Whenever a
non-zero exit code is returned, the node is demoted.

This way, your Redis clients only have to connect to the virtual IP address and
they’ll always be connecting to the master node and will be able to issue
writes.