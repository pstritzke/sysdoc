
prepare_disk() {
    echo "1.3 formating $BLK_ROOT with ext4:"
    mkfs.ext4 $BLK_ROOT
}

mount_chroot() {

    umount -R $CHROOT/proc
    umount -R $CHROOT/sys

    mount $BLK_ROOT $CHROOT
    #mkdir -p $CHROOT/boot
    #mount $BLK_BOOT $CHROOT/boot

    mkdir -p $CHROOT/usr
    mkdir -p $CHROOT/var
    mkdir -p $CHROOT/var/lib/pkg

    echo "1.6 activating chroot in $CHROOT;"

    mkdir -p $CHROOT/dev
    mkdir -p $CHROOT/tmp
    mkdir -p $CHROOT/proc
    mkdir -p $CHROOT/sys

    mount --bind /dev $CHROOT/dev
    mount --bind /tmp $CHROOT/tmp
    mount -t proc proc $CHROOT/proc
    mount -t sysfs none $CHROOT/sys
}

prepare_iso() {

    ISO_FILE=$ISO_PATH/$ISO_FILE

    if [ -f $ISO_FILE ];
    then
       echo "File $ISO_FILE exists."
    else
       echo "File $ISO_FILE does not exist."
       cd $ISO_PATH && { curl -k -O $ISO_URL ; cd -; }
    fi

    mkdir -p $CHROOT/iso

    modprobe isofs
    modprobe loop
    mount -o loop $ISO_PATH/crux-3.2.iso $CHROOT/iso
}

prepare_install() {
    echo "1.3 Create core.lst and install pkgadd"
    for p in $CHROOT/iso/crux/core/*; do echo $p >> $CHROOT/core.lst; done

    tar xf "$CHROOT/iso/crux/core/pkgutils#5.36-2.pkg.tar.xz" usr/bin/pkgadd -O > $CHROOT/pkgadd

    chmod +x $CHROOT/pkgadd

    echo "3.6 install handbook to /root"
    cp $CHROOT/iso/crux/handbook.txt $CHROOT/root/

    echo "1.3 core.lst complete, review list of packages before continue..."
    read
    vim $CHROOT/core.lst
}

install_crux() {
    echo "1.4 starting install"
    touch $CHROOT/var/lib/pkg/db

    cd $CHROOT
    while read line; do
        printf "Installing $line;\n"
        $CHROOT/pkgadd -f -r $CHROOT $line
    done < core.lst

    rm $CHROOT/pkgadd
    rm $CHROOT/core.lst
}

configure_crux() {
    echo "1.5 dns resolver, copy resolv.conf;"
    cp /etc/resolv.conf $CHROOT/etc

    echo "2.1 edit /etc/hosts file;"
    vim $CHROOT/etc/hosts

    echo "2.2 set timezone;"
    chroot $CHROOT /bin/bash -c tzselect

    echo "2.3 set locale;"
    chroot $CHROOT /bin/bash -c "localdef -i en_US -f UTF-8 en_US.UTF-8"

    echo "2.4.1 set root passwd;"
    passwd -R $CHROOT

    echo "2.4.2 admin username: (admin) $ADMIN_USER"

    echo "creating user "$ADMIN_USER";"
    useradd -R $CHROOT -s /bin/bash -m -U $ADMIN_USER
    passwd -R $CHROOT $ADMIN_USER

    echo "2.4.3 adding user "$ADMIN_USER" to wheel group;"
    usermod -R $CHROOT -a -G wheel $ADMIN_USER
    sudoedit $CHROOT/etc/sudoers

    echo "2.5 Set file system table;"
    blkid
    read
    vim $CHROOT/etc/fstab

    echo "2.6 Edit rc.conf;"
    vim $CHROOT/etc/rc.conf
}

configure_pkg() {
    echo "3.1 installing fakeroot;"
    chroot $CHROOT /bin/bash -c "pkgadd /iso/crux/opt/fakeroot#1.20.2-1.pkg.tar.xz"

    echo "3.2 adding user pkgmk;"
    useradd -R $CHROOT -U -m -d /var/ports -s /bin/false pkgmk

    echo "3.2 adding user "$ADMIN_USER" to pkgmk group;"
    usermod -R $CHROOT -a -G pkgmk $ADMIN_USER

    echo "3.3 setting ports layout in /var/ports;"
    chroot --userspec=pkgmk:pkgmk $CHROOT /bin/bash -c "mkdir /var/ports/packages"
    chroot --userspec=pkgmk:pkgmk $CHROOT /bin/bash -c "mkdir /var/ports/work"
    chroot --userspec=pkgmk:pkgmk $CHROOT /bin/bash -c "mkdir /var/ports/pkgbuild"

    echo "3.3 creating distfiles in /var/ports;"
    chroot --userspec=pkgmk:pkgmk $CHROOT /bin/bash -c "mkdir /var/ports/distfiles"

    echo "create entry with correct pkgmk id in fstab"
    id pkgmk
    read
    vim $CHROOT/etc/fstab

    echo "3.4 configure pkgmk;"
    vim $CHROOT/etc/pkgmk.conf

    echo "3.5 activate contrib ports;"
    mv $CHROOT/etc/ports/contrib.rsync.inactive $CHROOT/etc/ports/contrib.rsync


    echo "3.5 configure prt-get;"
    vim $CHROOT/etc/prt-get.conf

}

update_ports() {

    echo "3.6 update ports;"
    chroot $CHROOT /bin/bash -c "ports -u"
    chroot $CHROOT /bin/bash -c "prt-get sysup"
    REV_DEP=$(chroot $CHROOT /bin/bash -c "revdep")
    chroot $CHROOT /bin/bash -c "prt-get update -f $REV_DEP"

}

install_extra() {
    echo "3.6 install additional packages;"

    #cp $CHROOT/iso/crux/opt/* $CHROOT/var/ports/packages
    #cp $CHROOT/iso/crux/xorg/* $CHROOT/var/ports/packages

    chroot $CHROOT /bin/bash -c "prt-get depinst glib"
    chroot $CHROOT /bin/bash -c "prt-get depinst grub2"
    chroot $CHROOT /bin/bash -c "prt-get depinst wireless-tools"
    chroot $CHROOT /bin/bash -c "prt-get depinst wpa_supplicant"
    chroot $CHROOT /bin/bash -c "prt-get depinst shorewall"
    chroot $CHROOT /bin/bash -c "prt-get depinst logrotate"
    # samhain at this point add /etc/logrotate.d/samhain 
    chroot $CHROOT /bin/bash -c "prt-get -if depinst samhain"
    chroot $CHROOT /bin/bash -c "prt-get -if depinst tmux"

}

get_sysdoc() {
    echo "3.6 get this documentation;"
    chroot $CHROOT /bin/bash -c "prt-get depinst git"

    chroot $CHROOT /bin/bash -c "su - $ADMIN_USER -c 'git clone https://github.com/s1lvino/sysdoc'"

    echo "3.6 add sysdoc port collection;"
    cp $CHROOT/home/$ADMIN_USER/sysdoc/ports/sysdoc.httpup $CHROOT/etc/ports/
    chroot $CHROOT /bin/bash -c "ports -u sysdoc"

    echo "3.6 add sysdoc to prt-get.conf;"
    read
    vim $CHROOT/etc/prt-get.conf

}

install_linux() {
    echo "4.1 installing linux kernel;"
    chroot $CHROOT /bin/bash -c "prt-get -im depinst linux-libre"

    echo "5.1 dracut initramfs;"
    chroot $CHROOT /bin/bash -c "dracut --kver 4.1.13-gnu_crux"
}

setup_boot() {

    mkdir $CHROOT/etc/default
    echo "GRUB_DISABLE_LINUX_UUID=false
    GRUB_ENABLE_LINUX_LABEL=false" > $CHROOT/etc/default/grub

    chroot $CHROOT /bin/bash -c "grub-install $BLK_ROOT"
    chroot $CHROOT /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
}


