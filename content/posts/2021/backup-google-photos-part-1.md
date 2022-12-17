---
title: "Backup Google Photos (Part 1)"
date: 2021-04-01
tags: ["how-to", "homelab"]
type: post
---

One service that I've come to rely on is Google Photos.  For the last number of
years, I've had photos on my phone (which is now my primary camera for trips)
automatically backed up and categorized.  It's a slick service, but I feel most
comfortable having local copies of photos and keep them in a snapshot backup
system.

## Why I Did This

Google Photos is great, and I don't really have any issues with the service or
its availability.  I'm fairly comfortable keeping my primary photo copies there,
and it's really convenient.

What set off my fears though was [an episode of Reply
All](https://gimletmedia.com/shows/reply-all/2oh9ge) that shared a story of a
person keeping photos on a cloud service, then the cloud service falling under
and losing photos for some time.

Most of the photos I take are fairly low value, but a number of them are things
that I can't recover and have a lot of emotional connection.  Losing these
seemed unbearable, so I wanted to have an independent backup system.

I also have a local NAS that I keep most everything else of value on, and wanted
to loop these photos in to its daily snapshot backups as well.  This is probably
overkill, but it makes me feel better knowing that I have redundant copies of
family photos.

## How We'll Do This

I divided this into two parts:

1) Get the photos onto a local drive.
2) Copy them and organize them to match the naming schemes on my NAS.

I divided the tutorial into two parts as well to match each side, in case one is
more useful to you.

## Enter gphotos-sync

Google Photos has an API with oAuth, so really we just need an API client.  This
is the role of [gphotos-sync](https://github.com/gilesknap/gphotos-sync), as it
wraps the API calls into an easy CLI program we can use to download everything
(or some things) in a cron job.

To use this though, we need to setup some credentials to allow our application
to authenticate with our Google Account and pull the information it needs.
Google allows apps to have a fairly generous number of free API calls, and with
my modest library I haven't ran into that limit yet.

### Setting up the OAuth Application

_For more details on how to do this, follow [this excellent
guide](https://www.linuxuprising.com/2019/06/how-to-backup-google-photos-to-your.html)._

A brief overview of the process is:

1) Navigate [here](https://console.cloud.google.com/cloud-resource-manager) and
   create a new project for your setup.  Feel free to name it something you'll
   remember.
2) Navigate [here](https://console.cloud.google.com/apis/library?project=_) and
   select the project you've just created.  Search for the Google Photos API and
   enable it for that project.
3) Navigate [to the console home](https://console.cloud.google.com/) and create
   credentials for your application.  Create an OAuth ID and select "Other" for
   the application type.
4) Download `client_secret.json` and place it `~/.config/gphotos-sync/` on your
   system.

## Downloading the Images

For the next section, I decided to run the application in Docker.  This takes
care of all the installation of Python and the required dependencies, and I
already had Docker installed on the machine I planned on running this on.

You'll need a couple directories setup on your machine as well:

1) A directory to store the photos and some metadata that gets downloaded.
2) A directory to store the `client_secret.json` file.

You can set both of these up wherever.  The image directory should be empty, and
the config directory should just contain `client_secret.json`.

To start downloading, you'll need to run docker with a TTY the first time.  This
is needed to get the final authorization to actually link your app.  You can run
it like this:

```bash
docker run \
   --rm \
   -it \
   --name gphotos-sync \
   -v <image_directory>:/storage \
   -v <config_directory>:/config \
   gilesknap/gphotos-sync \
   --log-level INFO \
   --rescan \
  /storage
```

(Replace the placeholders with the full paths of the directories you setup earlier)

The first time it runs, it will prompt you to load a URL in your browser then
paste an authorization code.  Once the page loads and you sign in, you'll need
to approve access for your app to your account.  Google will give you a fairly
strong warning about this, since your app isn't actually verified or approved by
Google.

## Automate It

Once you have things running successfully manually, you'll naturally want to
have this run automatically.  You can use almost the same command as above
(except the `-it` option).

```bash
docker run \
   --rm \
   --name gphotos-sync \
   -v <image_directory>:/storage \
   -v <config_directory>:/config \
   gilesknap/gphotos-sync \
   --log-level INFO \
   --rescan \
  /storage
```

I put this in a script and called that script from Cron on a daily basis.

## That's it for Part One

At this point, you should have all the photos in your Google Photos account
downloaded in year based directories, and things symlinked into their respective
albums too.  When things run, the `--rescan` option tells `gphoto-sync` to fully
index everything again.

So far, I've had this script running for several months each day with no issues.
I've never had to authenticate the application a second time (except for moving
to new machines).

In the next few weeks, I'll share Part 2 where we copy albums to our NAS.
