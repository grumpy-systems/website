---
title: "This Site's Stack"
date: 2022-11-22
tags: ["homelab", "tools", "how-to", "meta"]
type: post
---

This site isn't anything too special, but I figured I'd share how I host things
for others who may be interested in owning their words.

## Motivation For Self Hosting

I've run this website (in some form or another) for the last 6+ years.  The idea
was to share some stuff I do that I think is cool with others and maybe remind
myself of projects past.  I've always just shared written content (for now), and
there's a million different ways to get your words out there.

Sharing content on social media sites has come more recently, but this site
still serves as an anchor for my content.  Even more so in the past few months,
social media platforms have shown that they are not a certain thing.  Accounts
get suspended, ownership changes tank services, rules change, etc, so having a
solid place to put content is worthwhile.

Ultimately, I wanted this site to be one constant.  You can always find me here
and find my projects, regardless of what other environments may do.  I don't
make any money off my content so it's not a huge deal if things get lost or
shutdown, but seeing others lose their work due to account issues or frustration
with a platform served as motivation to own my content.

If you are a content creator, I encourage you to keep things in
platform-independent ways.  For me, my content is mostly written word so that's
what I'll highlight here.

## This Site

To get to the meat and potatoes, this site is built using
[Hugo](https://gohugo.io/).  Hugo is a golang based tool to convert markdown
into a static website, and it's the perfect fit for my use case.  Here are the
things I like about it:

* **Small Sites** - I've used programs like WordPress in the past for my site,
  but these frameworks seem overly complicated for a basic site like this.
  Likewise, it seems like every week there's a new security vulnerability
  discovered in either the core of WordPress or a plugin, so security always
  seemed like it was risk.
* **CDN Friendly** - One challenge with hosting a site is dealing with traffic,
  especially if it is unpredictable.  A post may reach a massive audience with
  no warning and drive lots of organic traffic to your site.  Having a CDN can
  help with this, but using something like Hugo where _everything_ can be cached
  by the CDN makes the site able to handle incredible loads with little cost.
* **Neutral Format** - The posts are all stored in Markdown, which is a pretty
  easy format to move around.  I can take them and use them in other frameworks,
  convert them, etc without much fuss.
* **Git Tracked** - The entire site is tracked via Git, so it's stupid simple to
  backup and copy if the need arises.

Hugo can support more features like RSS, XML, and JSON formats too so you can
export articles or crawl things easily.  It's also incredibly fast at building a
site and generates predicable, easy to host results.  If you haven't looked at
Hugo, you might give it a whirl!

Hugo though needs two things to make it really "work": A way to build the site,
and a place to host the site.

## Building The Site

Building a hugo site is easy, you just run `hugo build`, but that's not fun
enough for me.  I employ a Drone CI server to automate the builds and deploys
whenever I make changes to the site.

With Drone, this is pretty easy as there's a Drone plugin specifically for building Hugo sites.  In fact, here's the drone file for this site:

```yaml
---
kind: pipeline
name: build
type: docker

steps:
- name: submodules
  image: alpine/git
  commands:
  - git submodule init
  - git submodule update --recursive

- name: hugo
  image: plugins/hugo

  settings:
    hugo_version: 0.68.3
    validate: true
    extended: true
    url: https://grumpy.systems

- name: deploy
  image: appleboy/drone-scp
  settings:
    # some settings redacted
    source: public/*
    strip_components: 1
  when:
    branch:
      - master
```

Basically, Drone does 3 steps:

1) **Clone the project**:  We need to also clone in the submodules, as the theme for
   this site is stored in a submodule.
2) **Run Hugo**:  We can set some options on the fly, but at its core this step
   just generates the static site we'll upload.
3) **Copy the Files**: We then copy the files up to the remote server, but only
   when a commit is on the `master` branch.

This job runs whenever I push changes, but also runs at a fixed time each day to
let me schedule stuff for release.  Hugo by default doesn't include posts with a
date in the future, so by setting one I can delay a post's release and have it
automatically update when its time comes.

## Hosting the Site

The other thing Hugo needs is a place to store it's files.  The beauty here is
since Hugo is just making static HTML pages, there are _tons_ of options.  In my
case, I use a pretty vanilla Nginx server that hosts a number of other sites
too.  You can use services like Amazon S3, Backblaze B2, or others though to
have a fully cloud-based solution.

Also since the site is just HTML and static assets, there's no PHP, Python,
Database, etc required.  You literally just need a basic web server to run
things.

For some added benefit and to act as a nice cushion, I run my site behind a CDN
(Cloudflare).  I'm just using their free tier, but it's plenty for this basic site.

With a CDN, and fairly liberal cache settings, posts on this site are rarely
actually fetched from my origin server, and in cases of high traffic things have
kept up without much fuss.

## Closing Thoughts

I realize this site is basic, but keeping it basic helps me focus less on
moderating the onslaught of spam comments and software patches and just have
something that "works".  Since it's all self-hosted, I also don't run the risk
of being de-platformed or losing my work due to an error outside my control.

Hopefully, if you're looking to create new content and share it you put in some
extra work and keep things for yourself.  The point (for me at least) is just to
share what I think is cool and what I work on, not to drive clicks or views to
sites where I see no return or benefit.
