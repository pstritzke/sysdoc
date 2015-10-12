#!/bin/sh


echo ""
echo ""
echo "Read this Script before using it, it makes a lot of
assumptions about your disk layout and contents to
backup."

echo ""
echo -n "System root directory you want backup (/mnt/): "
read ROOT_DIR

echo -n "Home directory you want backup (/mnt/home/): "
read HOME_DIR

echo -n "Services directory you want backup (/mnt/srv/): "
read SRV_DIR

echo -n "Destination directory (/home/user/backup): "
read DEST_DIR

echo ""
echo "Destination directory: $DEST_DIR"
echo "System root directory: $ROOT_DIR"
echo "Home directory: $HOME_DIR"
echo "Services directory: $SRV_DIR"

echo ""
echo "Press Enter to start or Ctrl+c to abort."
read

echo "Starting root system backup;"
tar -zcpf $DEST_DIR/root-`date '+%Y-%j-%H-%M-%S'`.tar.gz \
    --directory=$ROOT_DIR \
    --exclude=var/ports/distfiles \
    --exclude=var/ports/packages \
    --exclude=var/ports/work \
    --exclude=usr/src \
    --exclude=mnt \
    --exclude=home \
    --exclude=dev \
    --exclude=run \
    --exclude=tmp \
    --exclude=proc \
    --exclude=sys .

echo "Starting home directory backup;"
tar -zcpf $DEST_DIR/home-`date '+%Y-%j-%H-%M-%S'`.tar.gz \
    --directory=$HOME_DIR .

echo "Starting services directory backup;"
tar -zcpf $DEST_DIR/srv-`date '+%Y-%j-%H-%M-%S'`.tar.gz \
    --directory=$SRV_DIR .

