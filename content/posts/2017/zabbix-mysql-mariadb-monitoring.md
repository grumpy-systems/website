---
title: "Zabbix MySQL (MariaDB) Monitoring"
date: 2017-01-31
tags: ["dev-ops", "how-to", "linux"]
type: post
---

This is another one of those things that is pretty straightforward, but requires
culminating information from a different sources in order to get things up and
running.  The goal here is to get Zabbix to monitor our MariaDB (MariaDB is a
drop in replacement for MySQL, I’ll refer to either as MariaDB here) server’s
status.  There’s a built in template, but a few other files and settings need
setup before you can get the juicy data flowing.

## Setup a MariaDB User

In keeping with Linux’s philosophy of minimum required permissions, it’s a very
good idea to setup a dedicated Zabbix user just for monitoring.  This way, you
can turn off all the read and write functions, letting the user only monitor the
server.  If you’re running an interface like phpMyAdmin, log in and setup the
new user, setting a username and password you like.

If you’re setting up the user from the CLI, issue these commands:

```bash
mysql -uroot -p -e"GRANT USAGE ON *.* TO 'zabbix'@'127.0.0.1' IDENTIFIED BY 'password'";

mysql -uroot -p -e"flush privileges";
```

These two commands will create the user using your databases root account
(you’ll be prompted for the root password).

## Setup Zabbix Client

There are a few files you need to setup to get the Zabbix client to monitor
MariaDB correctly.  First, create a file called u`serparameter_mysql.conf` in
`/etc/zabbix/zabbix_agentd.conf.d` and fill it with the follow contents:

```text
# For all the following commands HOME should be set to the directory that has .my.cnf file with password information.

# Flexible parameter to grab global variables. On the frontend side, use keys like mysql.status[Com_insert].
# Key syntax is mysql.status[variable].
UserParameter=mysql.status[*],echo "show global status where Variable_name='$1';" | HOME=/etc/zabbix mysql -N | awk '{print $$2}' # My line

# Flexible parameter to determine database or table size. On the frontend side, use keys like mysql.size[zabbix,history,data].
# Key syntax is mysql.size[<database>,<table>,<type>].
# Database may be a database name or "all". Default is "all".
# Table may be a table name or "all". Default is "all".
# Type may be "data", "index", "free" or "both". Both is a sum of data and index. Default is "both".
# Database is mandatory if a table is specified. Type may be specified always.
# Returns value in bytes.
# 'sum' on data_length or index_length alone needed when we are getting this information for whole database instead of a single table
UserParameter=mysql.size[*],echo "select sum($(case "$3" in both|"") echo "data_length+index_length";; data|index) echo "$3_length";; free) echo "data_free";; esac)) from information_schema.tables$([[$

#Default below
UserParameter=mysql.ping,HOME=/etc/zabbix mysqladmin ping | grep -c alive #My line
UserParameter=mysql.uptime,HOME=/etc/zabbix mysqladmin status | cut -f2 -d ":" | cut -f1 -d "T" | tr -d " "
UserParameter=mysql.threads,HOME=/etc/zabbix mysqladmin status | cut -f3 -d ":" | cut -f1 -d "Q" | tr -d " "
UserParameter=mysql.questions,HOME=/etc/zabbix mysqladmin status | cut -f4 -d ":"|cut -f1 -d "S" | tr -d " "
UserParameter=mysql.slowqueries,HOME=/etc/zabbix mysqladmin status | cut -f5 -d ":" | cut -f1 -d "O" | tr -d " "
UserParameter=mysql.qps,HOME=/etc/zabbix mysqladmin status | cut -f9 -d ":" | tr -d " "
UserParameter=mysql.version,mysql -V
```

This setups the MariaDB parameters and commands Zabbix will use to collect data.

Next, we need to give Zabbix the login information for our new user.  Create a
file called .`my.cnf` in `/etc/zabbix` and fill it with these:

```ini
[mysql]
user=zabbix
password=password
[mysqladmin]
user=zabbix
password=password
```

Replacing the username and password with the ones you created earlier.  Both
[mysql] and [mysqladmin] are required, so you’ll have to enter the user
information twice.

## Setup Zabbix Server

Setup the host in your Zabbix server like normal, but you can now select the
MySQL Server template bundled with the default Zabbix install.

That’s it!  You should start to see data flow into Zabbix for your perusal and a
few new triggers to check the server is indeed running.
