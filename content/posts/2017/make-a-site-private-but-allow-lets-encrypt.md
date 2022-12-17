---
title: "Make a Site Private but Allow Lets Encrypt"
date: 2017-05-22
tags: ["dev-ops", "how-to", "linux"]
aliases: [
    "/2017/05/make-a-site-private-but-allow-lets-encrypt/"
]
---

This is a pretty straightforward thing I've wanted to do for some time.
Basically, I have a number of sites that I use internally that I wanted to get
certificates via Let's Encrypt, but I also wanted to keep them restricted to
only a few IP addresses.  The solution is quite simple and works perfectly.

We accomplish this with two .htaccess files.  One at the site root to restrict
IP address that can access the site, the second to disable that restriction on
the directory where the Let's Encrypt challenge is stored.

The first file lives at the document root and look like this:

```apache
Order Deny,Allow
Deny from all

# Replace this IP with the IP you want to allow access for.  Add multiple lines for different addresses.
Allow from 111.22.33.44
```

The second file lives in .well-known, which is where Virtualmin will store the
challenge files that Let’s Encrypt uses to verify ownership.

```apache
Order Deny,Allow
Allow from all
```

Since the only thing that lives in the .well-known directory is challenge files,
your main site is still protected!
