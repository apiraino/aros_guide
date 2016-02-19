#!/bin/bash

OPT_BUILD="20160119"
DBG_BUILD="20160119"
OPT="/home/user/aros/AROS-$OPT_BUILD-linux-i386-system"
DBG="/home/user/aros/AROS-$DBG_BUILD-source/bin/linux-i386/AROS"
QUALO="$OPT"

if [ -n "$1" ]; then
    if [ "$1" == "DBG" ]; then
        QUALO=$DBG
    fi
fi

cd $QUALO;
if [ "$1" == "DBG" ]; then
    echo "Running $QUALO under GDB"
    gdb -q -iex "set auto-load safe-path $DBG/.gdbinit" ./boot/linux/AROSBootstrap
else
    echo "Running $QUALO"
    ./Arch/linux/AROSBootstrap &
fi


exit 0

