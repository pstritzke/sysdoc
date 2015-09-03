#!/bin/sh
COLL=core
prt-get printf "%i %p %n\n" | grep "yes /usr/ports/"$COLL | cut -d " " -f 3 > $COLL"_installed.lst"

while read line; do
    {
       # cd /usr/ports/$COLL/$line
       # sudo -H -u pkgmk fakeroot pkgmk -f -d
       prt-get update -if -fr $line
    }
done < $COLL"_installed.lst" 
