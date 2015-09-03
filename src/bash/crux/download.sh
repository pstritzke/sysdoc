#!/bin/sh

for d in /usr/ports/core/* 
do
    (
    cd $d && pkgmk -do
    )
done

for d in /usr/ports/opt/* 
do
    (
    cd $d && pkgmk -do
    )
done

for d in /usr/ports/opt/* 
do
    (
    cd $d && pkgmk -do
    )
done

for d in /usr/ports/xorg/* 
do
    (
    cd $d && pkgmk -do
    )
done
