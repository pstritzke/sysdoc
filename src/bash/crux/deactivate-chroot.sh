#!/bin/sh

echo "Chroot: (/mnt)"
read CHROOT

umount $CHROOT/dev
umount $CHROOT/tmp
umount $CHROOT/proc
umount $CHROOT/sys
