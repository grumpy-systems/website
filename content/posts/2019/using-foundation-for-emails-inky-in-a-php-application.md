---
title: "Using Foundation for Emails (Inky) in a Php Application"
date: 2019-09-13
tags: ["how-to", "tools", "code"]
type: post
---

One framework that I instantly fell in love with was Inky.  Having built a
number of emails using pure HTML, having the shorthand syntax was amazing.
Coupling it with the inliner and CSS in Foundation for Emails, it's dead simple
to write a good looking email.

Just one problem: Foundation for Emails assumes you're either writing emails as
standalone units, or integrated into a Node.JS application.  What are you to do
if you're, say, running a PHP Symfony application?  It's absolutely possible,
and makes your emails dead simple to write.  Coupling this with Twig gives you a
really easy and powerful way to write emails in your application.

The original way I went about this was utilizing
[thampe/ZurbInkBundle](https://github.com/thampe/ZurbInkBundle), but it recently
has been abandoned and has issues with newer versions of Twig.  This was really
slick (to the end user) since it uses a pure PHP implementation of Inky to
handle the conversion.  This meant no extra dependencies, but required someone
to duplicate the inky logic in PHP, which isn't very sustainable (not as slick).

Before I go on, I should point out that Inky is the parser and template syntax
used by Foundation for Emails.  It's really the "hard part" of setting this up,
since it's much more complex and unique than CSS or inliners that come with
Foundation for Emails.  The bulk of this how to is aimed at getting Inky setup.

## Looking at Alternatives

The route I chose to go was to simply interface with Inky using its Node.JS
API's, this way I'm using the upstream Inky package.  Since my application
already used Webpack, Node was installed on all my build servers already which
mean there wasn't any extra setup to worry about there, just some extra npm
packages.

Inky provides a CLI tool to convert standalone files, but I opted not to go this
route.  This would require me to write the email to a temporary file and create
an empty directory to convert the file into to.  This meant extra steps and temp
files on the disk that I didn't really want to deal with.

As well, the dedicated Inky CLI tool only did the conversion from Inky to HTML.
Inlining CSS would still require some extra step in either node or PHP.

The option I went with was to simply create a Node script that would live with
my Symfony application.  This way I could use the same tools Foundation for
Emails does to inline CSS, and simply call the helper script from my
application.

## The Script

The script is pretty simple:  It takes Gzipped Inky code and converts it into
Base64 HTML that's ready to be plopped into an email and sent.

```js
/*
 * The Storehouse - Project Storage for Big Ideas
 *
 * This file is part of The Storehouse.  Copyright 2018 .
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as published
 *   by the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * This file takes an inky template (in our case, generated from twig) and
 * convert it into the raw HTML output. This lets us utilize inky in our PHP
 * application.
 */

var Inky = require('inky').Inky;
var cheerio = require('cheerio');
var inlineCss = require('inline-css');
var minify = require('html-minifier').minify;
var zlib = require('zlib');

/* Decompress the message body */
var body = zlib.inflateSync(new Buffer(process.argv[2], 'base64')).toString();

/* Load the body into cheerio */
var i = new Inky();
var html = cheerio.load(body, {
    decodeEntities : false
});

/* Do the conversion */
var convertedHtml = i.releaseTheKraken(html);

/* Inline CSS */
inlineCss(convertedHtml, {
    url : 'https://sthse.co/'
}).then(function(html) {
    html = minify(html);
    process.stdout.write(new Buffer(html).toString('base64'));
});
﻿
```

## The PHP Integration

The PHP integration is pretty simple too.  In my case, I already had a class
that handled all the Emails for my application, so it was a simple matter of
extending it to call our new node script each time and email was sent to do the
conversion.

```php
<?php
namespace StorehouseBundle\Utils;

use voku\CssToInlineStyles\CssToInlineStyles;
use StorehouseBundle\Entity\MailMessage;
use Symfony\Component\Process\Process;
use Symfony\Component\Process\Exception\ProcessFailedException;

/*
 * The Storehouse - Project Storage for Big Ideas
 *
 * This file is part of The Storehouse. Copyright 2018 .
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
class Mail
{

    /**
     * SwiftMailer to use while sending mail
     *
     * @var \Swift_Mailer
     */
    private $mailer;

    /**
     * Twig enviroment to use while sending mail.
     *
     * @var \Twig_Environment
     */
    private $twig;

    /**
     * Bin dir location
     *
     * @var string
     */
    private $binDir;

    /**
     * Create a new Mail Helper
     *
     * @param \Swift_Mailer $mailer
     *            SwiftMailer to use
     * @param \Twig_Environment $twig
     *            Twig to use
     */
    public function __construct(\Swift_Mailer $mailer, \Twig_Environment $twig, $kernelDir)
    {
        $this->mailer = $mailer;
        $this->twig = $twig;
        $this->binDir = realpath($kernelDir . '/../bin/');

        if (! $this->binDir) {
            throw new \RuntimeException('Could not find bin dir for email conversion script!');
        }
    }

    /**
     * Send a form message to a destination
     *
     * @param MailMessage $message
     *            Message object to send
     */
    public function sendFormMessage(MailMessage $message)
    {
        /* Get the raw twig output and run it through our converter */
        $body = $this->twig->render('StorehouseBundle:Mail:' . $message->template . '.html.twig', $message->data);

        $process = new Process('node ' . $this->binDir . '/convert-email.js "' . base64_encode(gzcompress($body)) . '"');
        $process->run();

        if (! $process->isSuccessful()) {
            throw new ProcessFailedException($process);
        }

        $body = base64_decode($process->getOutput());

        $swiftMessage = (new \Swift_Message())->setSubject($message->subject)
            ->setFrom('noreply@sthse.co', 'The Storehouse')
            ->setTo($message->destination)
            ->setBody($body, 'text/html');

        $this->mailer->send($swiftMessage);

        return true;
    }
}
```
