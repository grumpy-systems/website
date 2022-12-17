---
title: "Backup Google Photos (Part 2)"
date: 2021-04-15
tags: ["how-to", "code", "homelab"]
type: post
---

In [Part One](/2021/backup-google-photos-part-1/) we looked at how to download
our photos from Google Photos to a local drive.  But now we'll look at how to
archive them into human readable folders that can be included in daily snapshot
backups.

## Our Problem

Now we have all our photos downloaded, but I really wanted things to live on my
NAS with the rest of my important files.  This would also let me potentially
delete photos from Google Photos but keep things locally.

I wanted this to be "automated" to where I could edit a fairly basic file and
update the links between Google Albums and local directories.  Also, I didn't
want to copy + paste a script for each directory.

I keep all meaningful photos in Albums, so I focused on syncing the albums
rather than individual photos.  Copying all the photos would be fairly trivial
with `rsync`.

## The CSV

The first part was the CSV file.  I created a fairly basic format with no
headings, and had the following columns:

* User (More on this later)
* Google Album Name
* Local Path

I added a User field to allow for multiple Google Photo accounts to use this
script, in case my Wife has photos she'd like to put there too.  There's a
switch in the script that follows this and basically just replaces the source
path it's pulling from.

Here's an example line from my CSV:

```csv
"grumpy","Houston","Grumpy/Trips/2019.07 - Houston"
```

## The Script

Here's the bash script I wrote:

```bash
#!/bin/bash

set -e

###
# Config Variables
###

GRUMPY_PHOTOS_PATH='<source_photos_path>'

MAP_FILE='/.../photo-paths.csv'
OWNCLOUD_PATH='/.../shared/Photos/'

###
# End of Config Variables
###

while IFS="," read -r user album dest; do
    # Clean out the quotes we have padding the CSV
    temp="${user%\"}"
    temp="${temp#\"}"
    user=$temp

    temp="${album%\"}"
    temp="${temp#\"}"
    album=$temp

    temp="${dest%\"}"
    temp="${temp#\"}"
    dest=$temp

    # Get the right source based on the user column
    if [ "$user" == "grumpy" ]; then
        SRC="$GRUMPY_PHOTOS_PATH"
    fi

    # If we don't have an SRC, skip this line
    if [ "$SRC" == "" ]; then
        echo "Skipping line with user $user"
        continue
    fi

    # Find the album directory
    while IFS=  read -r -d $'\0'; do
        DIRNAME="$( basename "$REPLY" )"
        DIRNAME="${DIRNAME:5}"
        if [ "$DIRNAME" == "$album" ]; then
            # Clean up some variables to make things sane
            SRCDIR="$REPLY/"
            DESTDIR="$OWNCLOUD_PATH/$dest/"

            echo "Syncing $SRCDIR to $DESTDIR..."

            sudo -u www-data mkdir -p "$DESTDIR"
            rsync -rL --delete --owner="www-data" --group="www-data" "$SRCDIR" "$DESTDIR"

            touch "$DESTDIR/__DO_NOT_ADD_FILES_HERE__"
        fi
    done < <( find "$SRC/albums" -regex ".*/[0-9]+ .+" -type d -print0 )
    
done <$MAP_FILE

echo "Fixing ownership..."
chown -R www-data: $OWNCLOUD_PATH
```

Here's what that script does:

* Get a list of links from the CSV.
* For each link, find the corresponding Google Album.  This is a bit more
  complex then it sounds because the Albums have dates prepended, and can change
  location when adding photos.
* Rsync the source album to the destination.  We have `--delete` set to prevent
  any duplicate files (noted below) and `-L` to copy the symlinks (also noted
  below).
* We put a empty file in each directory to warn people not to put files directly
  there.

There's also a couple variables you'll need to edit at the top:

* `GRUMPY_PHOTOS_PATH` (but you can rename this) - This is the source of photos
  coming from `gphotos-sync`.  You'll want this path to be the base where you
  are syncing photos, ie the directory that contains both the `photos` and the
  `albums` directories.
* `MAP_FILE` - The location of the CSV file you'll use to map everything.  In my
  case, this also lives on my NAS.
* `OWNCLOUD_PATH` - This is the location on the NAS where everything should
  live.

### Why --delete

One bug that was reported with `gphotos-sync` is the ability for it to
re-download photos at times if modifications to metadata are made.  This could
potentially cause issues with our use case, so we clean up files.

Also, if a photo is deleted from the album, I'd like to remove it from the
server too.  Worst case, things are still backed up and snapshotted daily.

### Why -L

By default, `gphotos-sync` will just place symlinks to the photos in the albums
directory.  This is nice because it doesn't duplicate data, but in our case we
want to move the actual photo data.  `-L` tells rsync to follow links and copy
the actual file rather than just the link.

## Wrapping Up

That script isn't the best, but it works for what I need it for.  It runs daily
right after the photos are downloaded, and well ahead of our offsite backups.
The advantage of all this is all our photos not only get downloaded locally, but
placed in another offsite backup in case things go really wrong elsewhere.
