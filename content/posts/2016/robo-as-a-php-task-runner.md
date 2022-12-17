---
title: "Robo as a PHP Task Runner"
date: 2016-07-14
tags: ["tools"]
type: post
---

One of the things I ran into when developing The Storehouse was the need for a
task runner that fit into my weird style of development.  I’m not really a fan
of having multiple tools that do the same thing, so consolidating all of my
dependencies into Composer was a goal of mine once I started needing task
runners.

At first, I started off using Gulp and Node.js to do task running.  This worked,
and worked well, but I wasn’t ever super thrilled with having to have npm
installed on my system for one job.  As well, it introduced a completely new set
of dependencies for development, which could be problematic if anyone ever
wanted to contribute.

## Enter Robo

Robo is poised as a simple task runner that is completely based in PHP.  For a
lot of people, this sounds really bad since PHP is renowned for being a slow
language with many quirks.  Robo overcomes this, however, and is a very
effective tool that can do much of the same basic tasks as Gulp and do so
without introducing another package manager into your application.

Its configured using pure PHP, so there isn’t another language or learning curve
for developing tasks the meet your needs.  Since all of its dependencies are
managed through Composer, its cross platform and can be installed alongside the
dependencies for your project.

## Things I Like

I actually really like Robo and use it for The Storehouse as well as many
one-off projects I do.  Overall, it does what it needs to do and not too much
more.  It’s easy to setup and configure and doesn’t have much of a learning
curve.

### Not Multi-Threaded

This might sounds like a disadvantage at first, but it’s really actually a
pretty nice thing compared to Gulp.  One of the issues I ran into quickly with
Gulp was the need to have tasks wait until other tasks were complete before
moving on.  This is easily accomplished by using the dependent functionality to
ensure certain functions execute before the current function.

For tasks that are long series of sequential steps, such as deploying the
project, this can get pretty complex pretty quick.  Gulp’s default method of
operation is to try and execute tasks in parallel to save time.  When I’m
deploying though, I have to have rsync wait until all the styles are finished
building.

There’s callbacks and methods to make things synchronous, but support is sparse
and I quickly ran into issues.  Since I’m not really a Javascript guy, writing
callback functions and asynchronous code isn’t something I do too often, and I
felt like I was starting to spend more time on creating Gulp tasks and making
them run correctly than actually developing on my projects.

### Simple

Robo is pretty stripped down compared to its JS counterparts.  To some this
might be a sour point since it frankly doesn’t do as much.  I like this though,
since it makes what it can and cannot do a bit more clear and makes my tasks
more concise.  With Gulp I felt like there was so much I could do and so much
better ways to do it that it almost felt daunting anytime I tried to update a
task.

Since there aren’t as many features, it’s easier to understand what Robo can and
cannot do and it’s easy to take advantage of more features since there isn’t so
many variants of how to accomplish something based on your environment.

The whole process of writing tasks and using them is much easier and overall
feels more streamlined than Gulp.  The syntax is much simpler and it’s simple to
make a task do more than one thing, something that I found Gulp lacking in.
Even if you want your task to do something more complex than Robo can handle out
of the box, it’s pretty easy to write new functionality and tailor things to
your exact needs.

## Things I Don’t Like

### Documentation

This isn’t to say that documentation is non-existent, but really the only source
is the Robo site.  This is both good and bad, since it only really shows you one
way of how to accomplish things which although usually is working, doesn’t offer
many alternatives or easily identifiable opportunities for customization.  The
options to a method are mostly documented, but sometimes their use or purpose
isn’t clear.

That’s something I hope to post more of here in order to help fellow users
navigate some of the issues I ran into when getting things working.

### Speed

This is something that coming from a tool like Gulp will stick out the most,
especially when compiling SASS or SCSS.  Since Robo doesn’t make use of a C
based processor, it is much slower than the node solution.  It compares better
to Compass, which isn’t bad at all.

## Overall

Overall, Robo is pretty slick.  It solves a lot of the problems I ran into with
using Gulp and didn’t introduce any overly complex or excessive dependencies
while doing it.  I’ll definitely continue to use it in my projects, since it
fits into a PHP work flow and environment so easily.
