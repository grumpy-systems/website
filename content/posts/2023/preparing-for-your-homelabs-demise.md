---
title: "Preparing For you Homelab's Demise"
date: 2023-02-07
tags: ["homelab", "tools", "how-to"]
type: post
---

_Trigger Warning: This post talks generally about human mortality and loss of
your home._

One ting I've recently started considering is how my Homelab can survive if I'm
not around.  At first, everything in the lab was pretty low value so losing
things wasn't a huge deal.  Recently though, I've started archiving family
photos and other important things that need to survive after me.

I'll outline the considerations and situations I took into account, then I'll
share some of the tools I used to plan.

## What I Plan For

I focus mostly on the data, because that's the biggest piece that both is easy
to back up and difficult to replace.  Protecting the physical hardware isn't a
major concern for this reason, as I can easily replace servers.

I also plan for not total disasters, but situations like things going offline
when I'm out of town.  My lab is responsible for home internet, and since
turning it on is slightly more complicated than just plugging in a router, I
make sure there's some information on how to get things going again.

## Planning

One important thing to understand is that during a disaster you can't design a
disaster recovery plan.  You need to have things setup beforehand and test them
regularly.

### Assigning Value

The first step is understanding what you store, and assigning values to how
important it is to you and how hard it is to replace.

For my data sets, I assign a few values to each one:

* **Sensitivity** - If this information gets leaked, how big of a deal is it?
  Is it already public data or does it contain things like Social Security
  Numbers?
* **Replicability** - Can this data be replaced if your primary copy is lost?
  Is it an easy process or hard process to do that?
* **Value** - This can be monetary value (ie it would cost me $x to run this
  simulation again) or sentimental value (ie pictures of past pets and
  relatives).

If something scores high on all of these, your protections and backup strategy
need to be more robust and tested.  Something that is low value and easy to
replace might see one level of redundancy while high value and difficult to
replace might see another.

Even if you're already keeping backups of everything, it's still important to
plan.

### Scenarios

You also need to understand what you're trying to protect against.  Destruction
of your lab due to fire, flood, tornado, earthquake, etc is one common scenario.
With these, it's worth understanding how much warning time you typically get (no
warnings, hours, days) as you might be able to take some actions and not others
when things start to go sideways.

It might also be worth considering who would be around at the time.  Are you
frequently out of town or is there someone that can come rescue servers?  Should
spending effort to rescue servers be your priority?

Another thing to consider is if your lab is destroyed, are your phone and laptop
gone too?  Are your recovery keys stored on those and you expect to always have
one?

### Your Demise

Another part of planning should be developing a plan for if you become
unavailable for some reason.  Maybe you're just out of town for the week, or
maybe you're run over by a bus.

If other people are going to want your data (family photos, important documents,
etc), you should share something with them to let them in even if you can't let
them in yourself.

## Disaster Levels

Once you've planned things, it's worth running through scenarios in your head. I
like scales, so I devised this scale.  Higher numbers indicate more distaster-y
disasters.

### Level 0 - Power Outage While Your Home

This isn't really a "disaster" but I include it to highlight all the things
you'll likely have if this happens. This is the most basic scenario because you
still have everything: your servers, a place to run them, you're home to take
care of restarting things, etc.

Most people wouldn't consider this even a disaster, but if you walk through what
you need to recover, you can start to get an idea of what others may need.

### Level 1 - Power Outage While Your Gone

The first variable we'll introduce is you not being physically around.  The
scenario in my head is you're out of town for work, so the family is still home
and expecting things to mostly work.

The key point here is making sure you have the means to instruct someone either
in real time or through documentation on how to restore power.  Is your setup an
old desktop that just needs powered on, or is it a complicated multi server
setup like mine?

Also think about what may be missing, namely storage and Internet.  If you store
your documentation on your lab and it's down, how do you get it out?  If there's
no internet, are you able to video call or do live instruction?

### Level 2 - Server Failure or Destruction

The next variable is introducing failures in your servers and storage.  The
equipment may or may not run, but the data is long gone.

The key here is making sure that recovery keys have at least one backup copy
that you're able to use to seed your servers again.  This can be a copy on a
local laptop or written on some offline media you keep around, but it assumes
the primary keys on the servers are now toast.

Examples of this would be a flood, wildfire, or other disaster where you're able
to save a personal device or two but the main lab is left behind.

### Level 3 - Total Destruction

The next level assumes your servers are gone _and_ your personal devices are
gone.  This complicates things quite a bit because we have a few new factors:

* **Storing Keys Offsite** - Your backup encryption keys and configuration needs
  to be saved somewhere safe that also isn't vulnerable to these disasters.
* **Seeding Access** - If you store passwords in the lab, how do you get the
  most critical ones back out?
* **Two Factor** - If your two factor codes are stored on your phone, is there a
  way for you to get them back out?

Examples of this level would be a fire, tornado, or other GTFO type situation
where life and limb are all that matter.

### Level 4 - Your Lab is Gone And You Are Gone

Like level 3, but now the added challenge is someone else must do this.  This
means your documentation needs to be up to scratch to at least give someone a
general idea on how to get things out.

## Something is Better Than Nothing

One important thing I want to share is that _something_ is better than nothing.
I don't think any person is prepared for a true Level 4 disaster.  There are
challenges that you won't understand, complications you can't account for, and
more.

If you get something down on paper and shared, that gives you more footholds
should something happen.  Even if you aren't 100% prepared, it might give you a
better shot at coming out the other side.

Also, Testing is key.  Pretend you need to recover from scratch and make sure
your documentation is updated.

## My Plan

My plan revolves around two files, a PDF that is written documentation and an
encrypted file that contains copies of all the backup configurations.  I
automate the generation of these two things, and once a week the files get
updated and uploaded to a cloud service provider.

I have this largely automated, and I put an example up on
[GitHub](https://github.com/grumpy-systems/recovery-info).  That system takes
the `docs.md` markdown file and builds a PDF based on it.  It then bundles the
configuration I need, encrypts it, and uploads it to the offsite provider.

If you run that demo, you'll need to edit a few things in Makefile.

The first will be `get-configs`, and this should be the step that gets your
offsite configuration.  If you put it in `out/configs`, the `compress` step will
bundle it into a ZIP file automatically.

The other will be `sync`, and this will be how you upload things to the offsite
provider.  In my case, I use Rclone to do this, but you can omit this step if
you just want to upload things manually.

With the PDF and ZIP file that gets output, a person can (hopefully) have the
keys and knowledge needed to recover offsite backups for my environment.  I send
these to a shared folder that is shared with a few close people in case I get
locked out.  I also print the PDF and put it in the lab in case things need
recovery without Internet access.

## Further Reading

If you're interested in learning more, there's a few posts I like:

* [How My Homelab Became Critical
  Infrastructure](/2022/how-my-homelab-became-critical-infrastructure-during-a-tornado/) - I wrote this after a close call with a Tornado.  It's a creative solution
    that has helped me multiple times during minor emergencies.
* [Lawyer. Passport. Locksmith.
  Gun.](https://www.youtube.com/watch?v=6ihrGNGesfI) - A talk from Deviant Ollam
  that focuses more on the human side of preparedness, but has a good set of
  lessons he learned after a friend was arrested and mistreated.
* [Ready.Gov](https://www.ready.gov/) - If you haven't taken stock of what you
  and your family need in a disaster (things like food and water), it's worthing
  setting up some basic supplies.
