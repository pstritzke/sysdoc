#!/bin/sh

echo "Chroot: (/mnt)"
read CHROOT

echo "Device: (/dev/sdb)"
read BLK_ROOT

umount -R $CHROOT

mount $BLK_ROOT $CHROOT

mount --bind /dev $CHROOT/dev
mount --bind /tmp $CHROOT/tmp
mount -t proc proc $CHROOT/proc
mount -t sysfs none $CHROOT/sys
