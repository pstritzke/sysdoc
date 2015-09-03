#!/bin/sh

echo "1.2 block device for boot system (/dev/sdb1):"
read BLK_BOOT

echo "1.2 block device for root system (/dev/sdb2):"
read BLK_ROOT

echo "1.3 formating $BLK_BOOT with ext4:"
mkfs.ext4 $BLK_BOOT
echo "1.3 formating $BLK_ROOT with ext4:"
mkfs.ext4 $BLK_ROOT

echo "1.3 mount point: (/mnt)"
read CHROOT

mount $BLK_ROOT $CHROOT
mkdir -p $CHROOT/boot
mount $BLK_BOOT $CHROOT/boot

mkdir -p $CHROOT/usr
mkdir -p $CHROOT/var
mkdir -p $CHROOT/var/lib/pkg


echo "1.3 path/to crux-3.1.iso: (/home/user)"
read ISO_PATH

mkdir -p $CHROOT/iso

modprobe isofs
modprobe loop
mount -o loop $ISO_PATH/crux-3.1.iso $CHROOT/iso

for p in $CHROOT/iso/crux/core/*; do echo $p >> $CHROOT/core.lst; done

tar xf $CHROOT/iso/crux/core/pkgutils#5.35.6-1.pkg.tar.xz usr/bin/pkgadd -O > $CHROOT/pkgadd

chmod +x $CHROOT/pkgadd


echo "1.3 core.lst complete, review list of packages before continue..."
read
vim $CHROOT/core.lst


echo "1.4 starting install"
touch $CHROOT/var/lib/pkg/db

cd $CHROOT
while read line; do
	printf "Installing $line;\n"
	$CHROOT/pkgadd -r $CHROOT $line
done < core.lst

rm $CHROOT/pkgadd
rm $CHROOT/core.lst

echo "1.5 dns resolver, copy resolv.conf;"
cp /etc/resolv.conf $CHROOT/etc


echo "1.6 activating chroot;"
mount --bind /dev $CHROOT/dev
mount --bind /tmp $CHROOT/tmp
mount -t proc proc $CHROOT/proc
mount -t sysfs none $CHROOT/sys


echo "2.1 hostname (box);"
read HOST_NAME
chroot $CHROOT /bin/bash -c "hostname $HOST_NAME"
vim $CHROOT/etc/hosts


echo "2.2 set timezone;"
chroot $CHROOT /bin/bash -c tzselect

echo "2.3 set locale;"
chroot $CHROOT /bin/bash -c "localdef -i en_US -f UTF-8 en_US.UTF-8"

echo "2.4.1 set root passwd;"
passwd -R $CHROOT 

echo "2.4.2 admin username: (admin)"
read ADMIN_USER

echo "creating user "$ADMIN_USER";"
useradd -R $CHROOT -s /bin/bash -m -U $ADMIN_USER
passwd -R $CHROOT $ADMIN_USER

echo "2.4.3 adding user "$AMIN_USER" to wheel group;"
usermod -R $CHROOT -a -G wheel $ADMIN_USER
sudoedit $CHROOT/etc/sudoers

echo "2.5 Set file system table;"
vim $CHROOT/etc/fstab

echo "2.6 Edit rc.conf;"
vim $CHROOT/etc/rc.conf

echo "3.1 installing fakeroot;"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/fakeroot#1.20-1.pkg.tar.xz"

echo "3.2 adding user pkgmk;"
useradd -R $CHROOT -U -m -d /var/ports -s /bin/false pkgmk

echo "3.2 adding user "$AMIN_USER" to pkgmk group;"
usermod -R $CHROOT -a -G pkgmk $ADMIN_USER

echo "3.3 setting ports layout in /var/ports;"
chroot --userspec=pkgmk:pkgmk $CHROOT /bin/bash -c "mkdir /var/ports/distfiles"
chroot --userspec=pkgmk:pkgmk $CHROOT /bin/bash -c "mkdir /var/ports/packages"
chroot --userspec=pkgmk:pkgmk $CHROOT /bin/bash -c "mkdir /var/ports/work"
chroot --userspec=pkgmk:pkgmk $CHROOT /bin/bash -c "mkdir /var/ports/pkgbuild"

id pkgmk
echo "create entry with correct pkgmk id in fstab"
read
vim $CHROOT/etc/fstab

echo "3.4 configure pkgmk;"
vim $CHROOT/etc/pkgmk.conf

echo "3.5 configure prt-get;"
vim $CHROOT/etc/prt-get.conf

echo "3.5 activate contrib ports collection;"
mv $CHROOT/etc/ports/contrib.rsync.inactive $CHROOT/etc/ports/contrib.rsync

echo "3.6 install additional packages;"

chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/libffi#3.1-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/sqlite3#3.8.5-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/python#2.7.8-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/glib#2.40.0-1.pkg.tar.xz"

chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/freetype#2.4.11-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/libpng#1.6.12-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/grub2#2.00-4.pkg.tar.xz"

chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/expat#2.1.0-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/lvm2#2.02.107-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/keyutils#1.5.9-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/libevent#2.0.21-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/rpcbind#0.2.1-2.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/mdadm#3.3.1-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/libtirpc#0.2.4-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/libnfsidmap#0.25-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/nfs-utils#1.3.0-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/wireless-tools#29-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/libnl#3.2.24-1.pkg.tar.xz"
chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/wpa_supplicant#2.2-1.pkg.tar.xz"

echo "3.6 update ports;"
chroot $CHROOT /bin/bash -c "ports -u"

echo "3.6 get this documentation;"
chroot $CHROOT /bin/bash -c "prt-get depinst git"
chroot $CHROOT /bin/bash -c "su - $ADMIN_USER -c 'git clone https://github.com/s1lvino/sysdoc'"

echo "3.6 add sysdoc port collection;"
cp $CHROOT/home/$ADMIN_USER/sysdoc/ports/sysdoc.httpup $CHROOT/etc/ports/
chroot $CHROOT /bin/bash -c "ports -u sysdoc"

echo "3.6 add sysdoc to prt-get.conf;"
vim $CHROOT/etc/prt-get.conf

echo "3.6 install handbook to /root"
chroot $CHROOT /bin/bash -c "su - $ADMIN_USER -c 'cp $CHROOT/iso/crux/handbook.txt ~/'"

echo "4.1 installing linux kernel;"
chroot $CHROOT /bin/bash -c "prt-get depinst linux-libre"

echo "5.1 dracut initramfs;"
chroot $CHROOT /bin/bash -c "dracut --kver 3.18.20-gnu_crux"

echo "5.2 installing grub to MBR; (/dev/sdb)"
read BLK_DEV

mkdir $CHROOT/etc/default
echo "GRUB_DISABLE_LINUX_UUID=false
GRUB_ENABLE_LINUX_LABEL=false" > $CHROOT/etc/default/grub

chroot $CHROOT /bin/bash -c "grub-install $BLK_DEV"
chroot $CHROOT /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"

printf "ready to chroot $CHROOT /bin/bash, have fun ;)\n"
