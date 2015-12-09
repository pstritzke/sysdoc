#!/bin/sh

ISO_URL="https://serverop.de/crux/crux-3.2/iso/crux-3.2.iso"
ISO_FILE="crux-3.2.iso"

DIR="${BASH_SOURCE%/*}"

if [[ ! -d "$DIR" ]];
    then DIR="$PWD";
fi

. "$DIR/install-func.sh"

printf "\n\nFormat device and Install crux 3.2
from $ISO_URL\n\n\n"

printf "0.1 path/to/etc (/home/user/sysdoc/conf/etc):"
#DIR_CONF=/home/user/sysdoc/conf/etc
read DIR_CONF

printf "\n\nFormat device and Install crux 3.2
from $ISO_URL\n\n\n"

printf "5.2 install to device; (/dev/sdb):"
#BLK_ROOT=/dev/sda4
read BLK_ROOT

printf "1.3 mount point to chroot (/mnt):"
#CHROOT=/mnt
read CHROOT

printf "1.3 path/to crux-3.2.iso (/home/user):"
#ISO_PATH=/home/user
read ISO_PATH

printf "2.4.2 admin username: (admin):"
#ADMIN_USER=admin
read ADMIN_USER


printf "\n\n===========================================================================
Press enter to start: prepare_disk\n\n\n"
read
prepare_disk

printf "\n\n===========================================================================
Press enter to start: mount_chroot\n\n\n"
read
mount_chroot

printf "\n\n===========================================================================
Press enter to start: prepare_iso\n\n\n"
read
prepare_iso

printf "\n\n===========================================================================
Press enter to start: prepare_install\n\n\n"
read
prepare_install

printf "\n\n===========================================================================
Press enter to start: install_crux\n\n\n"
read
install_crux

printf "\n\n===========================================================================
Press enter to start: configure_crux\n\n\n"
read
configure_crux

printf "\n\n===========================================================================
Press enter to start: configure_pkg\n\n\n"
read
configure_pkg

printf "\n\n===========================================================================
Press enter to start: update_ports\n\n\n"
read
update_ports

printf "\n\n===========================================================================
Press enter to start: get_sysdoc\n\n\n"
read
get_sysdoc

printf "\n\n===========================================================================
Press enter to start: install_extra\n\n\n"
read
install_extra

printf "\n\n===========================================================================
Press enter to start: install_linux\n\n\n"
read
install_linux

printf "\n\n===========================================================================
Press enter to start: setup_boot\n\n\n"
read
setup_boot

printf "ready to chroot $CHROOT /bin/bash, have fun ;)\n"
