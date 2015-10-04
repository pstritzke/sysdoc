#!/bin/sh

######################################################################
#
# Put this file in;
# /usr/share/gitolite/deploy.sh
#


WWW_DIR=/srv/www/

for DP_FILE in /srv/git/deploy/*
do

    if [ ! -f "$DP_FILE" ]; then
        # Nothing to do ;)
        #echo "Deploy: invalid DP_FILE"
        exit;
    fi

    PROJECT=$(basename "$DP_FILE")

    GIT_DIR=`cat $DP_FILE`

    if [ ! -d "$GIT_DIR" ]; then

        echo "Deploy: invalid GIT_DIR="$GIT_DIR
        exit;
    fi
    echo "Deploy: GIT_DIR="$GIT_DIR

    GIT_WORK_TREE=$WWW_DIR$PROJECT/

    if [ ! -d "$GIT_WORK_TREE" ]; then
        echo "Deploy: invalid GIT_WORK_TREE="$GIT_WORK_TREE
        exit
    fi

    echo "Deploy: GIT_WORK_TREE="$GIT_WORK_TREE

    echo "Deploy: setting group permissions"

    # Change permissions for www group
    #find $GIT_WORK_TREE -type f -print0 | xargs -0 chmod 644
    find $GIT_WORK_TREE -type d -print0 | xargs -0 chmod 775

    echo "Deploy: starting git checkout"

    cd /srv/git

    sudo -u gitolite git --git-dir=$GIT_DIR --work-tree=$GIT_WORK_TREE checkout -f master

    cd $HOME

    echo "Deploy: fixing permissions"

    # Fix ownership and permissions
    chown -R www:www $GIT_WORK_TREE

    find $GIT_WORK_TREE -type f -print0 | xargs -0 chmod 644
    find $GIT_WORK_TREE -type d -print0 | xargs -0 chmod 755

    echo "Deploy: removing deploy file="$DP_FILE
    # Done with project
    rm $DP_FILE
done
