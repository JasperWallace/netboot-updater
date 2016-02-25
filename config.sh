#!/bin/sh

# where to put files as we are working on them, needs to be persistant
# to avoid re-downloading things everytime
workdir="/tmp/netboot-update"
# or de, fr, us etc...
location="uk"
# where your tftp server looks for files
# might be /srv/tftp etc...
tftpdir="/tmp/tftpboot"
menus="${tftpdir}/pxelinux.cfg"

mkdir -p $menus

if [ ! -e ${menus}/graphics.conf ] ; then
  cp "`dirname $0`"/graphics.conf ${menus}/graphics.conf
fi

if [ ! -e ${menus}/default.example ] ; then
  cp "`dirname $0`"/default.example ${menus}/default.example
fi

if [ ! -e ${workdir} ] ; then
        mkdir -p ${workdir}
fi
