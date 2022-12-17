---
title: "Securing Apache Sites With Saml"
date: "2019-10-25"
tags: ["tools", "how-to", "code"]
---

So I recently have fallen in love with single sign on.  I really like
centralized user management, and being able to adapt it into many different
application is really sweet.  Plus, it makes compliance people happy!

One feature I like is the ability to secure arbitrary Apache websites with it
using a plugin called Mellon.  Basically this acts like the native apache
authentication, but rather than present a window for a username and password, it
redirects you to your SSO provider to login.

One reason I like this is that it blocks every request to the application and
forces users to authenticate.  This not only takes the burden of authentication
away from the application, it also protects any unknown endpoint that may exist
on the application.

Think about it: you setup an application and maybe forget that there's an API
endpoint.  Or there's a vulnerability in that endpoint that allows people to
bypass authentication.  If we allow Apache to enforce that all users are logged
in, no one can even query those endpoints with already being authenticated.

Alongside this, apps that don't integrate with SAML or have (or really have a
need for) user authentication can now be secured too.  Think about an internal
documentation site or similar.  Things need to be kept private, but users aren't
really needed or supported on the site.

Mellon and SSO take care of all of these.  Once you know what to do, it's pretty
easy to set up even.

## Some Cons

Nothing is without fault, and this authentication method has its faults.  This
authenticates a user before they even get to the application, so if the
application has a login screen the user will essentially have to login twice
(Once into the SSO provider, once into the application itself).  This is less
than ideal, obviously.

## SSO Providers

One nice things about SSO and SAML is that it's a standard, so theoretically any
SSO provider will work.  And there are a lot of them out there.  I use
JumpCloud, as it has a free tier that we fit into nicely here, but has the room
to expand as needed.

Other names include Okta and even Google, but I'll focus on JumpCloud since
that's the IDP (SSO provider) I used.

## The Magic Script

Most everything you need to get setup is actually taken care of by a simple script, but this script isn't readily apparent in the Mellon docs.  The docs for Mellon I found were very overly verbose, which is good for understanding the options available but bad for simple use cases and people that aren't intimately familiar with SAML.

The script is available here, and is part of the official Mellon repository so
rest assured.  Using it is simple, just invoke it with two arguments, an
identifier for the service and the URL to login at.  For these, I just use the
URL of the site I'm securing:

```bash
bash mellon_create_metadata.sh https://site.internal.sthse.co https://site.internal.sthse.co/saml
```

If you follow this guide, the second URL will be correct.  If you modify the
apache config coming up, you may need to update that though.

1) It generates the X.509 certificates needed to authenticate with the SSO provider.
2) It generates a very handy metadata file that can be use to automatically
   configure the service.

The metadata file is a standardized file that can be passed between SSO
applications and SSO providers to communicate various options and protocols in
use.  Without this, we'd have to manually figure everything and that can be
tricky.

## Apache Config

On the Apache side, the mod_auth_mellon module is required.  In Debian and
Ubuntu this is available in the repositories.  We then need to configure our
site to actually require the users to authenticate, and tell Apache information
about our SSO provider.

The configuration block I used is below.  A few paths and options will need
modified to meet your needs, but these should be fairly easy.

```apache
# This defines a directory where mod_auth_mellon should do access control.
<Location />
   # Documentation on what these flags do can be found in the docs:
   # https://github.com/Uninett/mod_auth_mellon/blob/master/README.md
   MellonEnable "auth"
   AuthType "Mellon"
   MellonVariable "cookie"
   MellonSamlResponseDump On
   MellonSPPrivateKeyFile /path/to/generated_key.key
   MellonSPCertFile /path/to/generated_cert.cert
   MellonSPMetadataFile /path/to/generated/metadata.xml
   MellonIdpMetadataFile /path/to/idp-metadata.xml
   MellonEndpointPath /saml
   MellonSecureCookie on
   # session cookie duration; 43200(secs) = 12 hours
   MellonSessionLength 43200
   MellonVariable "proxyweb"
   MellonUser "username"
   MellonDefaultLoginPath /
   MellonSamlResponseDump On
</Location>
```

This is pretty straight forward, it just requires every user hitting the site to
authenticate before proceeding.

## JumpCloud Configuration

The last thing we need to configure our SSO provider (JumpCloud in this case).
Thanks to our metadata file, this is pretty easy.

Login to the administrator console and create a new application.  For the type,
select Custom SAML App.

This is where things get confusing if you aren't familiar with SAML.  The only
things you'll need to fill in here are the Display Label (what the application
is called to your users), and the IDP entity ID.  This second field is an
identifier for the SSO provider, and I use the URL of the site here.

Upload the metadata file that was generated, and the remaining fields should
auto populate.  You'll also need to upload the generated certificate file here
too.

Set the IDP URL to something more descriptive and activate the service.  

We'll then need to export the metadata file from JumpCloud to send to our
server.   You can do this by going into edit the application and clicking the
small "export metadata" link.  Upload this file to your server in the path set
in the Apache configuration.

Once complete, be sure to add users that should be able to access the
application so they can log in.

## Done

After that, just restart Apache and view the site.  You should be directed to
the SSO login screen and, if allowed in the JumpCloud config, load the pages.
If you aren't assigned to the application in JumpCloud, you'll get an error when
you attempt to login.

This also works in the reverse, you can access the application from the
JumpCloud user console too!
