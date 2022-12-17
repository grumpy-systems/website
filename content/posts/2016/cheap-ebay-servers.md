---
title: "Cheap Ebay Servers"
date: 2016-10-05
tags: ["dev-ops", "startups"]
type: post
---

One of the most challenging things about starting a business is figuring out how to setup your operations.  With a tech
company, this gets trickier because of the plethora of options on how to handle your business.  When setting up a
physical operation, sourcing hardware can become a challenge, especially when capital is limited.

One of the things that can really help is used equipment, since for a small operation the latest and greatest can be
overkill.  In my case, I turned to Ebay to try and find some cheaper hardware, and scored good with a trio of servers
that have been in production without issue for years now.  It sounds crazy, and has it’s drawbacks, but it worked really
well.

![The Servers at CoLo](/images/IMG_20160521_130042292.jpg)

## The Good

I purchased the first machine (Galactica in the picture) in 2013 and have been running it continuously since then.  The
other two (Atlantia and Pegasus) were purchased in 2015 and have been running since then.  These machines cost $150 and
$75, making them have some pretty awesome return on investment.  The reliability is eerie (I’m knocking on my wood desk
as I type this): no major failures in that time.  The machines were purchased from a refurbisher, so they arrived pretty
fresh, which probably helps.

The machines aren’t hot-rods, but they keep up very well.  I run the trio as a ProxmoxVE cluster and each can handle a
handful of OpenVZ containers without any issue.  Each one shipped with dual processors and 16GB of ram.  I can’t recall
the specs off the top of my head (we’ll discuss this later).  Granted, I’m not putting a lot of load on these machines
but they keep up with room to spare.

Since these machines are so cheap, it makes it easier to run multiple in case of
a failure.  Really I could likely put all the load on one machines, but having
three gives me some tolerance for failures.

## The Not So Good

These machines aren’t really documented … anywhere.  If you Google the model
numbers, you’ll find Ebay listings and people asking for help.  These machines
don’t really need a lot of attention, but if you do need to find extra help it
may be a trick.  The question on max memory size is one downfall of this, I
can’t even say for certain how many memory slots are on the board or the max
amount of RAM supported.

These machines have hot swap bays, but mine didn’t come with screws.  Since
these are pretty slim, the screw heads have to be able to recess into the bottom
of the tray for it to slide in.  Another Ebay search turned up some screws,
although they didn’t cooperate with the 2.5″ solid state drives I installed.  I
ended up using some other screws and kinda wedging it in there since there’s
only one SSD on each node.

The other thing these machines lack is any sort of Out of Band Management or
IPMI.  So if something breaks, you have to drive to the DC to fix it.  This is
OK for something in town but can be a deal breaker if you need to put the
servers far off site.  These boards act like they support it, having some
options in the BIOS and sometimes an extra network port for OOB, but I could not
get any of the three machines to talk using that interface.  There’s probably a
trick to it, but without any solid documentation it isn’t easy to find.

These machines all run ProxmoxVE, which is based on Debian Linux.  the two newer
machines had some issues getting Linux to setup and run.  Again, the lack of
documentation extenuates this, since finding a solution or setting can be a lot
of guessing.  Once setup these machines haven’t had any issues with Linux
though.

Overall, it seems pretty risky looking back, but I don’t think it could have
turned out better.  Especially on a tight budget, these gave me exactly what I
needed and even leave room to expand in the future.  Would I purchase more?  I
might.  I say that because these machines aren’t really setup to be virtual
hosts.  They work, yes, but in 4U of space I can run so much more on new
hardware.  Knowing that (coupled with the high cost of colocation) has kinda
turned me off to the idea of more of these, since they aren’t very space
efficient.

For someone who needs a few cheap servers, these things rock.  For an enterprise
that needs 500 servers, probably not so much.
