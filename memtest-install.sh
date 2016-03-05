#!/bin/bash
#
#
#

. "`dirname $0`/config.sh"

url="http://www.memtest86.com/downloads/memtest86-usb.tar.gz"
file=memtest86-usb.tar.gz

cd $workdir

ret="$(curl -z $file --location ${curlargs} --write-out '%{http_code}' -o $file $url)"
if [ $ret = "200" -o -n "$force" ] ; then
	echo "memtest was updated"
	mkdir -p memtest-tmp
	(cd memtest-tmp ; tar -xvzf ../${file} )
	mkdir -p ${tftpdir}/memtest/
	cp memtest-tmp/memtest86-usb.img ${tftpdir}/memtest/

cat <<ABC123
# netboot setup for memtest
# from memtest.com, not memtest.org
LABEL Memtest
  MENU LABEL Memtest86 V6.x.x
  KERNEL memdisk
  APPEND initrd=memtest/memtest86-usb.img

ABC123

fi
