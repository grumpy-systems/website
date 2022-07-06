---
title: "MySQL (MariaDB) Galera Cluster Restart"
date: 2017-02-05
tags: ["dev-ops", "how-to", "linux"]
aliases: [
    "/2017/02/mysql-mariadb-galera-cluster-restart/",
]
---

This is a scary problem when you're recovering from an outage of your database
machines.  If you're running a Galera cluster and they all go offline, you'll
need to do a bit of work to restart the cluster and make it safe.

Galera relies on the fact that there's at least one node running in your cluster
at all times.  If your entire cluster goes offline, you won't be able to start
it again, even with the --wsrep-new-cluster option.  The process to restart it
is simple, but requires some manual intervention.

First, get the contents of grastate.dat on all the cluster nodes.  On Debian and
Ubuntu, this is at `/var/lib/mysql/grastate.dat`.

The output should resemble:

```text
# GALERA saved state
version: 2.1
uuid:    1ea21a3a-e76c-11e6-96a4-a291688a9d43
seqno:   -1
safe_to_bootstrap: 0
```

The line we’re concerned about is seqno.  Find the node with the highest
sequence number, or if they’re all the same (-1 for a graceful shutdown) pick
any node.

Edit that file on the node you’ve selected and set `safe_to_bootstrap` to 1.
Start that node with the `--wsrep-new-cluster` option.  You should be able to
bring online the remaining nodes and have a cluster once again.
