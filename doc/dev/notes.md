## New redesign of the codebase

- one-off tool for converting KS.Inspection-based json files into modern ones
   - No UUID inside
   - Filenames change (no UUID)
   - date :: UTCTime


Trying to find all of the legacy data (what did you do?)

on tiddly.honuapps.com
   ~dino/ks/imported/
      nc-wake_2014
         nc-wake_2014/           3000     2014-01-24 - 2015-01-23
         nc-wake_2015-02-09/      157     2015-02-24 - 2015-02-09
         nc-wake_daily/
            nc-wake_2015-02-10/     8
            nc-wake_2015-02-11/    15
            nc-wake_2015-02-12/    17
         newOne/
   /var/local/kitchensnitch/nc-wake_daily/
      [all dirs]                 1352     2015-02-13 - present

Everything from imported/ above in one dir. This represents all
data before we automated daily downloading

   ~dino/ks/nc-wake_2014-01-24_2015-02-12/   3179

New mongodb server is up-to-date through 2015-07-09. Not yet automated for dailies after that date.

For purposes of populating a new db, everything we were interested in up to 2015-02-12 is in this file:

    data/nc-wake_2014-01-24_2015-02-12.tgz

This means no longer mucking around with

    data/nc-wake_2014, data/nc-wake_2014_q1..., data/nc-wake_2015-02-20, etc.


## 2015-02-13

We are up-to-date with imports to 2015-02-12


## Isolating subsets of inspection files

From within some directory full of inspection JSON files..

    $ cd data/wake_2014..

The first 100

    $ find . type f | head -100 | xargs cp -v -t ../foo/

The second 100

    $ find . type f | head -200 | tail -100 | xargs cp -v -t ../foo/

The third 100

    $ find . type f | head -300 | tail -100 | xargs cp -v -t ../foo/
