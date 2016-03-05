#!/bin/sh

# where to put files as we are working on them, needs to be persistant
# to avoid re-downloading things everytime
workdir="/tftpboot/netboot-update-workdir"
# or de, fr, us etc...
location="uk"
# where your tftp server looks for files
# might be /srv/tftp etc...
tftpdir="/tftpboot"
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

force=
verbose=

usage ()
{
    echo "usage: $0 [[-f] [-v] | [-h]]"
}

while [ "$1" != "" ]; do
    case $1 in
        -f | --force )          force=yes
                                ;;
        -v | --verbose )        verbose=yes
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

curlargs=" --silent "

if [ -n "$verbose" ] ; then
	curlargs=" --verbose "
fi

if [ -n "$force" ] ; then
	echo "force"
fi

