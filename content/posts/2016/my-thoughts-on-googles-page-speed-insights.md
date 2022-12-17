---
title: "My Thoughts on Googles Page Speed Insights"
date: 2016-12-16
tags: ["dev-ops", "startups", "tools"]
---

Google’s Page Speed measure is a tool to give developers feedback as to how
their web page is performing.  It rates the pages on a scale of 0 to 100, with
100 being “perfect.”  In my opinion this system is very flawed and it creates an
ambiguous number that encourages developers and clients to waste time and money
chasing after unobtainable goals.

_Obligatory Disclaimer: These opinions don’t reflect my employer at all.  I had
a bad day, I’m tired and I’m grumpy._

So, let’s start with what the page speed insights are supposed to be.  Google
describes it as a measure of the page’s performance.  The idea is a good one:
give feedback and suggestions to improve the site’s performance.

## Complaint 1: Implementation

My main beef is with the implementation, it rates the site on a scale of 0 to
100, which implicitly creates the idea that 100 is perfect, even if the
developers of the tool didn’t intend for that to be the case.  They, however,
make it clear that this is their intent by rating the scores as Good and Bad,
with about 85 being the cutoff for “performing well.”  So this creates pressure
on developers to improve the score, since a better score is always better.

As well, the rules that they use to measure the performance are arbitrary and
opinionated.  Some of the suggestions: compress images, enable gzip, are pretty
universal.  Some other ones, like eliminating blocking CSS, create even more
headaches and have no clear-cut solution that works in all browsers.  Some of
the rules just simply don’t apply, but you can’t filter which ones to check on.
You can’t re-calculate an adjusted score either, since the math that lands at
the magic number is kept hidden.

## Complaint 2: Google doesn’t even follow it

Yup, google.com gets a whopping 79 out of 100!  The site which should
arguably be the example of how to implement such arbitrary rules doesn’t event
score above the “performing well” threshold.  By their own metric their site is
sub-standard or just OK.

This isn’t limited to just Google, some of the major (and not so major) sites I
checked all perform relatively low.  In my sample, no sites got a perfect score.
Since perfect isn’t really achievable, even for sites that have armies of
developers working on the front end, it becomes difficult to explain to the boss
why your awesome new site gets a 60.

Another weird point is that Google will flag Google served scripts and fonts for
not having the correct cache control headers set.  This means if you run
Analytics or use a font served by Google your score is counted down because
Google doesn’t serve the files to their own recommendations set by this tool.

## It’s Just a Tool

In the about section, Google even says that the metric is just a tool.  The
problem is that by attaching a score and rating system to it, it only
exaggerates people’s reliance on the tool.  Front end optimization is a good
thing, but revolving all your development around a single number becomes a
detriment to good development practices.  Sites that spend hours of development
revolving around improving this score are likely no better off than another site
that simply adheres to more universal and well tested practices and focuses on
more concrete and real measures of how their site is performing.

This is symptom of a larger problem: seeking validation of your code from other
arbitrary parties.  Really the people that are in the best position to give
feedback regarding how your site is behaving are the users that utilize it.  If
your users and customers are happy with the site’s performance, then I don’t see
a huge need to radically change things to appease some automated tool.
Automated tools are good opinions to take into consideration, but they alone
should not determine the quality of your code.

## Other Services

There are other services that have the same rating system that I have less of a
problem with.  The difference, specifically with GTMetrix, is that the criteria
are more widely accepted, and there are more of them.  This makes it a lot more
sane to implement, since what they suggest to do is usually pretty sane and
straightforward.  An example of this is blocking CSS.

GTMetrix doesn’t count against you if you don’t do this but Google does.  When
you go to implement this, you’ll quickly find that Google’s docs don’t have
anything of help and there isn’t a real solid way to accomplish this.  There are
a lot of different ways, but some rely on browser quirks that are sometimes not
present and others rely on Javascript, which if you’re also loading by their
recommendations means you have to wait for the JS to load then wait for the CSS
to load.

Overall, the tool is just that: a tool.  I think it’s easy to place trust in it
blindly since it scores your site, but really should only be one metric of many
that you use to determine if your site is performing well.  Really, the best
metric is feedback from users and customers about how they see the site
performing, and this automated tool shouldn’t replace that feedback.
