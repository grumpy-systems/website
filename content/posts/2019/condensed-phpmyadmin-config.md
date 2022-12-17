---
title: "Condensed PHPMyAdmin Configuration"
date: "2019-12-02"
tags: ["dev-ops", "how-to", "code"]
aliases: [
    "/2019/12/condensed-phpmyadmin-configuration/"
]
---

This is something that bothered me when adding more than one server to
PHPMyAdmin.  The default configuration is very verbose, and largely isn't needed
for simple use cases.

In my case, I boiled down the config options I use most frequently, and changed
the format to be more inline.  The format doesn't look too good on the site, but
it is pretty clean once in a wider editor.

```php
$cfg['Servers'] = [
    1 => [
        'host' => 'xxx',            // MySQL hostname or IP address
        'port' => '',               // MySQL port - leave blank for default port
        'socket' => '',             // Path to the socket - leave blank for default socket
        'ssl' => true,              // Use SSL for connecting to MySQL server?
        'ssl_key' => null,          // Path to the key file when using SSL for connecting to the MySQL server
        'ssl_cert' => null,         // Path to the cert file when using SSL for connecting to the MySQL server
        'ssl_ca' => '../rds.pem',   // Path to the CA file when using SSL for connecting to the MySQL server
        'ssl_ca_path' => null,      // Directory containing trusted SSL CA certificates in PEM format
        'ssl_ciphers' => null,      // List of allowable ciphers for SSL connections to the MySQL server
        'ssl_verify' => true,       // If the name on the certificate should be verified.
        'connect_type' => 'tcp',    // Weather to connect via 'tcp' or 'socket'
        'auth_type' => 'config',    // Authentication method (valid choices: config, http, signon or cookie)
        'user' => 'xxx',            // MySQL USer
        'password' => 'xxx',        // MySQL Password
        'AllowRoot' => false,       // Allow root to login
        'AllowNoPassword' => false, // Allow users to login without a password.
    ],
    2 => [
        'host' => 'xxx',            // MySQL hostname or IP address
        'port' => '',               // MySQL port - leave blank for default port
        'socket' => '',             // Path to the socket - leave blank for default socket
        'ssl' => true,              // Use SSL for connecting to MySQL server?
        'ssl_key' => null,          // Path to the key file when using SSL for connecting to the MySQL server
        'ssl_cert' => null,         // Path to the cert file when using SSL for connecting to the MySQL server
        'ssl_ca' => '../rds.pem',   // Path to the CA file when using SSL for connecting to the MySQL server
        'ssl_ca_path' => null,      // Directory containing trusted SSL CA certificates in PEM format
        'ssl_ciphers' => null,      // List of allowable ciphers for SSL connections to the MySQL server
        'ssl_verify' => true,       // If the name on the certificate should be verified.
        'connect_type' => 'tcp',    // Weather to connect via 'tcp' or 'socket'
        'auth_type' => 'config',    // Authentication method (valid choices: config, http, signon or cookie)
        'user' => 'xxx',            // MySQL USer
        'password' => 'xxx',        // MySQL Password
        'AllowRoot' => false,       // Allow root to login
        'AllowNoPassword' => false, // Allow users to login without a password.
    ]
];
```
