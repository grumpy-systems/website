---
title: "Using HTTPS In Your Homelab, And Why It's Important"
date: 2023-01-19
tags: ["homelab", "how-to", "linux"]
type: post
---

When you have a homelab, you're going to start having a number of internal
websites and services you use.  You'll learn to live with HTTPS warnings when
navigating to these sites, but these warnings can still be a problem.  What if
we wanted to have valid HTTPS everywhere?

## HTTPS Primer

HTTPS encrypts your traffic so things that intercept it (routers, attackers,
etc) can't decode it, and it does this even with an invalid or self-signed
certificate.  On a local network, this usually isn't a big deal.  We trust most
everything on the network so the risk of someone snooping on our traffic is
pretty low.

HTTPS also tries to validate the authenticity of the remote site, and this is
really what the warning in your browser is telling you about.  This requires a
bit more complexity though, since how can we trust a site we've never visited
before?

To solve this HTTPS uses a series of certificates and what are called
Certificate Authorities or CAs.  The CAs are institutions that issue
certificates that are trusted by your computer or browser and sign other
certificates.  When a site presents its certificate, it usually will have a
chain that leads back to a CA certificate your computer trusts, and therefore
communicates that the site should be trusted too.

A more practical example would be friends introducing each other.  There's a new
person, Bob, asking for your address.  You've never met Bob, but Bob says he
knows Alice.  You've met Alice before and trust her, so you ask Alice if she
really knows Bob.  She tells you the Bob you've met is the correct Bob, so
you're able to trust him and give him information.

While you and Bob haven't met before, you're able to confirm using a chain of
trust that Bob really is Bob.  In the example, Bob would be the site, and Alice
is the certificate authority.

## Why In A Homelab?

As I mentioned before, even with a self-signed certificate, encryption is still
working.  What I'm really talking about here is the verification aspect of HTTPS
that we can use.  I'm also only speaking about _internal_ sites that aren't
accessible from the outside world.

Having trust certificates comes with a few benefits for the "classic" attack
scenarios:

* **No more warnings** - Having a habit of clicking through an HTTPS warning is
  not a good habit.  If you have users that may not understand the risk, or
  carry over the behavior into other sites, this can become an issue.
* **Validates Identitiy** - Sure, it's a Homelab and the threat of rogue DNS is
  probably quite low, but it's still nice to know that you're typing passwords
  or credentials into the server you mean to.

But it also thwarts a new attack vector, especially on mobile devices and
networks that use internal DNS: spoofing on other networks.

The idea here is that my phone may try to connect to
`https://internal-service.test.local` on networks _other than_ my home network.
Usually this hostname simply won't resolve outside my home, but perhaps through
a DNS cache or malicious intent it does to some random address in the world.

If we don't have a trusted certificate and had to tell the app to trust any
certificate, my phone might connect and start sending credentials or sensitive
information. However, if we configured trusted HTTPS certificates everywhere,
the random server or spoofed site won't have the proper certificate and our
device won't connect.

These risks are, admittedly, quite low, but it's better to be over-prepared and
mitigating them is pretty easy.

## Method 1 - Let's Encrypt

Let's Encrypt is the most ubiquitous free certificates out there.  Basically, if
you have a public DNS record or public site, you can get certificates through
their automated issue process.  You can even now do wildcard certificates to
cover multiple sites.

Let's Encrypt has two methods it uses to validate the domain before issuing a
certificate, and you need to have one of these working.

In the first method, Let's Encrypt sends an HTTP request to the host name on the
certificate (`service.example.com`), and expects a certain challenge response to
come back.  This means you need to have Public DNS and a server that listens on
port 80 and is accessible by the world.

The other method uses a challenge DNS record.  This bypasses the need to have a
public server at the address, but does mean that only certain DNS providers are
supported, as DNS records need to be created and removed by `certbot` (the tool
that does the renewals for you).

This makes it a bit more fiddly for a homelab, since you might not be able to
self-host websites on your connection or you might not have public DNS setup,
but if you have these it's pretty easy to run.

I won't delve too much into actually setting up and running `certbot` because
there's a lot of documentation already out there on how to use it.  Let's
Encrypt's [getting started guide](https://letsencrypt.org/getting-started/) is a
good resource and covers lots of use cases.

## Method 2 - Internal CA

This is a bit more involved, but also is a lot more flexible.  Let's Encrypt
requires automation since the certificates are only valid for a few months.
Every 3 months (or sooner), you'll have to renew things which can be a chore,
especially if you have to manually upload everything.

An Internal CA bypasses this, but also won't be trusted by other browsers or
computers.  If you have a public site or a site that others connect to, this
method won't work.

The process is pretty simple, but will vary based on your setup:

1. Generate a certificate authority.  Basically, this is just a certificate for
   signing other certificates.
2. Install that CA certificate into the computers.  Anything that access these
   services and you want to it show as trusted will need the CA certificate
   installed.
3. Generate site certificates and keys.  These are the certificates that will go
   to the HTTPS site.

### Generate The CA Certificate

First, generate the private key for your CA.  You'll be prompted for a password
to secure your private key that you'll need to remember!

```bash
openssl genrsa -des3 -out ca.key 4096
```

After a few moments, you'll get a new key that will be the basis of our internal
CA.  With this key, you can generate any trusted certificate, so do not lose it
and do not share it.

Next, we need our root certificate.  This is the public side of the CA that
we'll install into our client computers.

```bash
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.pem
```

During this step, you'll be prompted for the metadata for your certificate. This
will be things like the country, locality, name, etc.  You can put anything in
these values but I like to keep mine accurate.  Also, not all the fields are
required.  If you don't want to share something (like an email address), just
skip it.

Once complete, you'll have two files: `ca.key`, the private key, and `ca.pem`,
the certificate.  Keep these files somewhere safe and secure as you'll need them
in the future, along with the password.

### Install The Certificate

This step varies depending on the OS you are running, but you'll need to add
`ca.pem` to all the client devices that will connect.  If you don't know how,
just look up `Install CA Cert on <os>`.

For Debian and Ubuntu, follow these steps:

* Copy the certificate into /usr/local/share/ca-certificates/
* Run `sudo update-ca-certificates`

The certificate should work on most modern systems, so feel free to add to as
many machines as you need.

### Generate Certificate for Client Machines

First, generate a private key and a Certificate Signing Request:

```bash
openssl genrsa -out site.key 2048
openssl req -new -key site.key -out site.csr
```

When running the second command, you'll be asked many of the same questions as
when creating your CA certificate.  The only thing that you _need_ to put in
correctly on this round is the Common Name, and this should be the DNS name of
the site (ie `internal.grumpy.cloud`).  The extra options are not required.

This generates what's called a Certificate Signing Request or CSR, and this is
what ordinarily would be sent to the certificate authority to sign.  This file
contains all the metadata for your new certificate they need to actually issue
the certificate.  Since we're our own CA though, we'll just use the file in the
next step.

Now we create the site's certificate using our CA certificate:

```bash
openssl x509 -req -in site.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out site.pem -days 365 -sha256
```

You'll be prompted for the password of your CA private key, and once complete
will have the site's public certificate.  The private key and public certificate
are the two components you'll install on the server.

## That's It!

Now that your server is using the new key, navigating to it in a browser with
the CA certificate added will show the normal trusted icon and not have any
verification warnings.
