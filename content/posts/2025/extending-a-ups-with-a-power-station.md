---
title: "Extending a UPS with a Power Station"
date: 2025-02-15
tags: ["homelab", "how-to"]
type: post
---

A while ago, I highlighted a design in my homelab where I kept core services
running on a low power core to get longer runtimes on my UPS.  I talk about it
in [this
post](/2022/how-my-homelab-became-critical-infrastructure-during-a-tornado/),
and that setup worked well for a long time.

But as my network grew and more things became important, I started to lose some
of the runtime of that UPS.  Recently, I've upgraded my NVR to a full Unifi NVR
appliance, added a TV antenna and amplifier, and a few other gadgets that I've
deemed also critical infrastructure, so the wattage has increased and the UPS
was only able to do about 20 to 30 minutes now.  This is in part due to its
aging batteries, but also the increased load.

I sought out to fix this, and landed in the category of Lithium power stations.
These are self contained units that contain a Lithium battery and an AC
inverter, and are intended for things like camping, RV's or event backup power
like we're using here.  Jackery, Bluetti and Ecoflow are major brands in the
space, if you can't picture what I'm talking about.

## How I Justified This

When looking at power stations vs Lithium UPS units (or even larger lead acid
units), these power stations looked really appealing.  When making my
comparisons to traditional UPS systems, these are the points I considered.

* **Cost** - Both in upfront cost and maintenance.  Lead acid units will a new
  set of batteries every few years, so buying a large unit used for cheap would
  still require several hundred dollars of batteries.  New UPS units were
  several thousand dollars at a minimum, so even more expensive.
* **Utility** - These power stations accept solar panel input and are moderately
  portable (smaller ones more portable), so I could take the unit out of the
  rack and use it on a trip or elsewhere.  In a longer outage, some solar panels
  would be enough to keep things like my fridge going for much longer.
* **Safety** - A lot of folks have hacked together battery strings for UPS units
  that exceed the design capacity of the UPS.  Some units can handle this, but
  others aren't designed to run the inverter at high load for hours at at time.
  Changing battery chemistry from lead to lithium also seemed like a bad idea
  without more knowledge than I have.

## Features Needed To Make This Work

I went with a [Bluetti AC70](https://www.bluettipower.com/products/ac70), but
a lot of stations should work.  There are a few features you need to look for
though:

* **Rated Power** - This needs to well exceed the wattage of the devices you
  plan to run.  Unless you're running your entire rack, this shouldn't be an
  issue.  Don't look at things talking about X-Boost or other tricks, as they
  won't work for electronics.
* **Rated Capacity** - Expect to get about 80-90% of this value, but this will
  govern the runtime of your gear.  For example, if you have 250 watts of load
  and 750 watt hours of capacity, divide 750 / 250 to get about 3 hours of
  runtime.
* **LiFePO4 Battery** - Most stations use this chemistry now, but some don't.
  This will withstand lots of charge / discharge cycles and is very stable and
  safe.
* **Passthrough Charging or a UPS Mode** - Different brands call this different
  things, but this allows the station to output power as it's charging.  When AC
  Power is present, that's passed to the output and the battery is only switched
  on when no AC input is present.  Some units have slow chargers that don't
  allow this, so be sure to check.

The rest, like app control, are all immaterial.

## Wait, But What About Clean Shutdowns?

So you're buying this and now you're asking "How will my machines know to
shutdown?"

The answer is the lead acid UPS we'll run inline after the power station.  I
plug my lead acid UPS into the output of the power station which seems silly,
but let has benefits.

First, you're free to take your power station elsewhere and not lose the only
UPS.  I use mine on trips at times or once the power is out and my generator
running.  I'll free it from the rack and use it elsewhere in the house where my
generator can't reach.

Second, this solves all the problems with communication.  In an outage, the
power station will transfer to it's internal battery and power the other UPS and
the load.  In my case, once the power station is dead the lead battery will take
over for about 20-30 minutes.  In that time, I get the normal UPS health alerts
and eventual graceful shutdowns like I did before.

If your power station outputs a pure sine wave, the lead UPS will only trip for
a second while the power transfers from the grid to the power station's battery
(if even that).  After this, it should continue to run as if on grid power until
the power station runs out.

## A Few Odds and Ends

One thing that I also purchased was a cord like [this
one](https://www.amazon.com/dp/B0CHVTWPQQ).  This takes the IEC power cable
coming from the wall and lets you either plug it into the power station's input
port or bypass the power station and power the UPS directly off the grid again.
If you take your power station out of the rack, this makes the change over much
easier.

(On the above, keep in mind my setup is only drawing a few hundred watts, and
only one output of that cord is used at at time.  Don't be dumb and overload
cheap cords, you'll burn things down.)

You'll also want to adjust the charging speed of the power station.  Many can
vary from a few hundred watts to 1KW+.  When there's grid power and the battery
needs charged, this value gets combined with whatever your load is using for a
larger total draw.  If you have 500 watts of gear and charge at 1KW, you'll pull
1.5KW and you may start tripping breakers for the circuit.  I keep mine charging
at only a few hundred watts, so at worst the setup draws < 500 watts.

Also make sure to discharge the battery at times to keep it healthy.  I'm not
sure how much damage is done by keeping things charged to 100% all the time, but
I go down every month or so and let the power station discharge most of its
battery.  Check the manual for your power stations in case it has more guidance.
