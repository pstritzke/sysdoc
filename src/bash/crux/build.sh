#!/bin/sh
COLL=$1
source /etc/ports/$COLL".rsync"

prt-get printf "%i %p %n\n" | grep "yes $destination" | cut -d " " -f 3 > $COLL"_installed.lst"

while read line; do
    {
       # cd /usr/ports/$COLL/$line
       # sudo -H -u pkgmk fakeroot pkgmk -f -d
       prt-get update -if -fr $line
    }
done < $COLL"_installed.lst" 
