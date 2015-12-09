#!/bin/bash

PKGMK_PKGFILE="Pkgfile"
PKGMK_CONFFILE="/etc/pkgmk.conf"
DISTFILES="/home/distfiles/"
INDEX_HEADER="/home/ports/header";

get_filename() {
    if [[ $1 =~ ^(http|https|ftp|file)://.*/(.+) ]]; then
        echo "$PKGMK_SOURCE_DIR/${BASH_REMATCH[2]}"
    else
        echo $1
    fi
}

get_basename() {
    local FILE="`echo $1 | sed 's|^.*://.*/||g'`"
    echo $FILE
}


check_pkgfile() {
    if [ ! "$name" ]; then
        echo "Variable 'name' not specified in $PKGMK_PKGFILE."
        exit $E_PKGFILE
    elif [ ! "$version" ]; then
        echo "Variable 'version' not specified in $PKGMK_PKGFILE."
        exit $E_PKGFILE
    elif [ ! "$release" ]; then
        echo "Variable 'release' not specified in $PKGMK_PKGFILE."
        exit $E_PKGFILE
    elif [ "`type -t build`" != "function" ]; then
        echo "Function 'build' not specified in $PKGMK_PKGFILE."
        exit $E_PKGFILE
    fi
}

check_directory() {
    if [ ! -d $1 ]; then
        echo "Directory '$1' does not exist."
        exit $E_DIR_PERM
    elif [ ! -w $1 ]; then
        echo "Directory '$1' not writable."
        exit $E_DIR_PERM
    elif [ ! -x $1 ] || [ ! -r $1 ]; then
        echo "Directory '$1' not readable."
        exit $E_DIR_PERM
    fi
}

check_file() {
    if [ -e $1 ] && [ ! -w $1 ]; then
        echo "File '$1' is not writable."
        exit 1
    fi
}

download_file() {
    echo "Downloading '$1'."

    if [ ! "`type -p wget`" ]; then
        echo "Command 'wget' not found."
        exit $E_GENERAL
    fi

    LOCAL_FILENAME=`get_filename $1`
    LOCAL_FILENAME_PARTIAL="$LOCAL_FILENAME.partial"
    DOWNLOAD_OPTS="--passive-ftp --no-directories --tries=3 --waitretry=3 \
        --directory-prefix=$PKGMK_SOURCE_DIR \
        --output-document=$LOCAL_FILENAME_PARTIAL --no-check-certificate"

    if [ -f "$LOCAL_FILENAME_PARTIAL" ]; then
        echo "Partial download found, trying to resume"
        RESUME_CMD="-c"
    fi

    echo=1

    BASENAME=`get_basename $1`
    for REPO in ${PKGMK_SOURCE_MIRRORS[@]}; do
        REPO="`echo $REPO | sed 's|/$||'`"
        wget $RESUME_CMD $DOWNLOAD_OPTS $PKGMK_WGET_OPTS $REPO/$BASENAME
        echo=$?
        if [ $echo == 0 ]; then
            break
        fi
    done

    if [ $echo != 0 ]; then
        while true; do
            wget $RESUME_CMD $DOWNLOAD_OPTS $PKGMK_WGET_OPTS $1
            echo=$?
            if [ $echo != 0 ] && [ "$RESUME_CMD" ]; then
                echo "Partial download failed, restarting"
                rm -f "$LOCAL_FILENAME_PARTIAL"
                RESUME_CMD=""
            else
                break
            fi
        done
    fi

    if [ $echo != 0 ]; then
        echo "Downloading '$1' failed."
        exit $E_DOWNLOAD
    fi

    mv -f "$LOCAL_FILENAME_PARTIAL" "$LOCAL_FILENAME"
}

download_source() {
    local FILE LOCAL_FILENAME

    for FILE in ${source[@]}; do
        LOCAL_FILENAME=`get_filename $FILE`

        if [ ! -e $LOCAL_FILENAME ]; then
            if [ "$LOCAL_FILENAME" = "$FILE" ]; then
                echo "Source file '$LOCAL_FILENAME' not found (can not be downloaded, URL not specified)."
                exit $E_DOWNLOAD
            else
                download_file $FILE
            fi
        fi

        if [ ! "$LOCAL_FILENAME" = "$FILE" ]; then
            BASENAME=`basename $LOCAL_FILENAME`
            if [ ! -e $DISTFILES$BASENAME ]; then
                ln $LOCAL_FILENAME $DISTFILES$BASENAME;
            fi
        fi
    done
}


update_port() {

    local FILE PORT_CFILE TITLE DEST;

    PORT_CFILE=$1;

    source /etc/ports/$PORT_CFILE;

    if [  "$ROOT_DIR" != "" ]; then
        DEST=$ROOT_DIR;
        else
        DEST=$destination;
    fi

    for d in $DEST/*
    do (
        if [ -f $d/$PKGMK_PKGFILE ]; then
            cd $d;

            PKGMK_SOURCE_DIR="$PWD"

            source ./$PKGMK_PKGFILE;
            source $PKGMK_CONFFILE;

            check_directory "$PKGMK_SOURCE_DIR"
            check_pkgfile;

            prtsweep .

            download_source;

        fi
    ) done

    cd $DEST;
    TITLE=$(echo $PORT_CFILE | cut -f 1 -d '.');
    portspage --header=$INDEX_HEADER --title="${TITLE^} collection" . > index.html


}

update_port "core.rsync";
update_port "opt.rsync";
update_port "contrib.rsync";
update_port "xorg.rsync";
update_port "xfce.rsync";
update_port "sysdoc.httpup";
