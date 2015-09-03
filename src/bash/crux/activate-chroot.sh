#!/bin/sh

echo "Chroot: (/mnt)"
read CHROOT

mount --bind /dev $CHROOT/dev
mount --bind /tmp $CHROOT/tmp
mount -t proc proc $CHROOT/proc
mount -t sysfs none $CHROOT/sys
