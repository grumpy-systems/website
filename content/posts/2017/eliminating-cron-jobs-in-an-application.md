---
title: "Eliminating Cron Jobs in an Application"
date: 2017-08-28
tags: ["lessons-learned", "tools"]
---

When you have an application, there’s inevitably some things that just need to
be done periodically.  These aren’t tied directly to user actions, so the quick
answer is usually cron.  It’s easy to setup, but when it breaks it can cause
subtle issues that may impact your customers or application.

It’s simple to setup a script that does whatever needs done, and it’s equally
easy to tell cron to execute the script at regular intervals.  Usually, things
are well.  Cron runs your script, emails you the output, and life moves on.

## Why Eliminate Cron?

### Code Design

One thing that cron instilled in me was poor code quality and design.  I
designed critical parts of the application on the assumption that they would
only be called once and therefore didn’t implement checks to make sure actions
weren’t duplicated.  The problem with this design quickly becomes apparent when
cron misbehaves.

Since none of the scripts checked to make sure it was actually safe to run,
there were times when scripts would run twice as frequently or not at all due to
simple human errors when setting up cron.  Depending on your use case, this
could be a major issue.  In our case, this was related to billing so users’
bills weren’t calculated or multiple bills were generated for a billing period.

### Timing

Cron has a really great feature of running things at exactly the same time.
This is great, but when a task may be intense running it at the same time can
create regular load spikes on your application.  Worse yet, if multiple jobs run
at the same time you can overwhelm your application with tasks that are fairly
low priority.

You can stagger your jobs, but then you’re always having to keep timings in your
mind and ensuring that you don’t double up on strenuous tasks.

### Distribution

Another issue we ran into was having the cron jobs execute in a distributed
manner.  Since we assumed cron scripts would only be executed once, we weren’t
setup to be able to run the job across multiple machines or in a multi-threaded
way.  Really this is a fairly minor concern, but as our application grows I’m
sure we’ll have more to execute and eventually being able to break up the cron
scripts across multiple machines will become a larger issue.

## Ways to Eliminate Cron

### Complex Way

In our case, we took a rather advanced approach to accomplish this task.  We
utilized asynchronous events with The Storehouse already, so we created a
“housekeeping” event that would be fired on random requests.  We could then add
event listeners that would perform our periodic actions in the background.

This works really well and is still the way we operate.  Since it’s all
asynchronous, the user’s request isn’t affected a great deal by the added event,
just the added time to queue the extra event.  Our application servers handle
the events like every other event, and since they’re run pretty frequently none
of the tasks take too long.

This relies on a few assumptions though.  First, is that your application serves
enough requests to fire this event at intervals frequent enough for your needs.
In our case, this event is fired about once an hour which is plenty.  The second
is that you have some kind of asynchronous event processing.  If you do
housekeeping on random requests and hold the request to complete your tasks, the
user will have to wait for your tasks to complete before their request is
processed.

### Simple Way

This method is a bit simpler, but doesn’t address all the issues we laid out
above.  What you can do is create a script that runs via cron at more frequent
intervals than what is needed.  This doesn’t “eliminate” cron, but it works
around the issue of relying on cron to time your jobs.  In this case your
application determines when it is time to run your periodic tasks, and not cron.
This way if cron acts up, your jobs aren’t doubled up.

Overall, cron is still a useful tool, I’m not trying to remove cron from our
environment all-together: just remove our application’s dependency on regularly
executed scripts.
