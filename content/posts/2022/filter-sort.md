---
title: "Sort Evolution Mail Filters with Python"
date: 2022-01-15
tags: ["code", "random", "tools"]
---

I _really_ like filtering my mail.  I tend to only need to act on a very small
set of messages coming in, so I filter everything such as Ads, FYIs, Cron Jobs,
etc to folders and just leave the important stuff in my inbox.

Unfortunately though, I now have a few hundred rules, as I keep things separated
out to let me have multiple conditions for single senders and keep everything
fairly organized.  I try to keep these alphabetized, but that's quite the chore.

As an aside, I name my rules in a standard way.  Here are some rule names:

```plain
Ads / Tech / AWS
FYI / Let's Encrypt
Crons / Backups / Offsite
```

Rather than continue to organize them by hand, I've created a simple little
python script to sort the XML file automatically:

```python
import xml.etree.ElementTree as ET
from operator import attrgetter

tree = ET.parse('filters.xml')
root = tree.getroot()

def getKey(element):
    return element.find('title').text

out = sorted(root[0], key=getKey)

top = ET.Element('ruleset')
for element in out:
    top.append(element)

root[0] = top

with open('new.xml', 'wb') as f:
    tree.write(f)
```

To use this, copy out the Evolution filters file (located at
`~/.config/evolution/mail/filters.xml`) and place it in the same directory as
the script.  Run the script, and it will spit out a new sorted list in
`new.xml`.  Inspect that file and copy it back into the `~/.config` path to
install it.

This won't modify the rule's actions, it just sorts by the `title` you've given
to each rule.
