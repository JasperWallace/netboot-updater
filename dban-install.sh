#!/bin/bash
#
#
#

. "`dirname $0`/config.sh"

url="http://sourceforge.net/projects/dban/files/dban/dban-2.3.0/dban-2.3.0_i586.iso/download"
file=dban-2.3.0_i586.iso

cd $workdir

curl -z $file --location --verbose -o $file $url

mkdir dban-tmp

# we need to extract files from the dban iso
# not sure of a good cli command to do this :/
mount -o loop $file dban-tmp

#ls -lh $file dban-tmp

mkdir -p ${tftpdir}/dban
cp dban-tmp/dban.bzi ${tftpdir}/dban
umount dban-tmp

cat <<ABC123
# netboot setup for DBAN
LABEL DBAN
  KERNEL dban/dban.bzi

# XXX add an autonuke option
ABC123

# APPEND nuke="dwipe --autonuke" silent
