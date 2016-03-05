#!/bin/bash
#
#
#

. "`dirname $0`/config.sh"

url="http://sourceforge.net/projects/dban/files/dban/dban-2.3.0/dban-2.3.0_i586.iso/download"
file=dban-2.3.0_i586.iso

cd $workdir

ret="$(curl -z $file --location ${curlargs} --write-out '%{http_code}' -o $file $url)"
if [ $ret = "200" -o -n "$force" ] ; then
	echo "dban was updated"
	mkdir -p dban-tmp

	# we need to extract files from the dban iso
	# not sure of a good cli command to do this :/
	mount -o loop $file dban-tmp


	mkdir -p ${tftpdir}/dban
	cp dban-tmp/dban.bzi ${tftpdir}/dban
	umount dban-tmp

cat <<ABC123
# netboot setup for DBAN
LABEL DBAN
  MENU LABEL ^DBAN
  KERNEL dban/dban.bzi
  APPEND nuke="dwipe"

# XXX add an autonuke option
ABC123

fi

# APPEND nuke="dwipe --autonuke" silent
