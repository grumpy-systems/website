---
title: "Fix Virtualmin Proxy with Let's Encrypt"
date: 2021-06-14
tags: ["how-to", "linux", "dev-ops"]
---

This is a minor inconvenience that I've dealt with for far too long.  When using
Virtualmin as a reverse proxy, it doesn't handle Let's Encrypt verification
records correctly and forwards them to the upstream service.

In my case, this would cause certificates to issue correctly initially, but then
fail to renew after three months is up.  Since _every_ request that hits the
server was getting sent to the upstream server (including any requests to
`.well-known`), the HTTP challenge will always fail.

The issue is quite simple to fix, and just requires a few lines of Apache Config
added to each virtual host.

```apache
ProxyPass /.well-known/acme-challenge/ !
ProxyPassReverse /.well-known/acme-challenge/ !
```

Add that before the `ProxyPass / http:// ...` lines in the configuration to have
Apache bypass the proxy for acme challenges.

If you're using Virtualmin, you can edit this by opening the site you want to
change, then go to Services > Configure Website.  Then select "Edit Directives."
If you've setup the proxy using the Virtualmin UI, the `ProxyPass` line you'll
need to put it in front of will be at the very end of the file.
