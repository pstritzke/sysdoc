#!/bin/sh

echo -n "backupname (laptop): "
read BKP_NAME

echo -n "root directory you want backup (/mnt/): "
read ROOT_DIR

echo -n "where you want to save (/home/user/backup): "
read DEST_DIR

echo $DES_DIR
echo $ROOT_DIR

tar -zcpf $DEST_DIR/$BKP_NAME-`date '+%S-%M-%H-%j-%Y'`.tar.gz \
    --directory=$ROOT_DIR \
    --exclude=var/ports/distfiles \
    --exclude=mnt \
    --exclude=home \
    --exclude=dev \
    --exclude=run \
    --exclude=tmp \
    --exclude=proc \
    --exclude=sys .
