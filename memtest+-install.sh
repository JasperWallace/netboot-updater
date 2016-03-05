#!/bin/bash
#
#
#

. "`dirname $0`/config.sh"

url="http://www.memtest.org/download/5.01/memtest86+-5.01.bin.gz"
file="memtest86+-5.01.bin.gz"

cd $workdir

ret="$(curl -z $file --location ${curlargs} --write-out '%{http_code}' -o $file $url)"
if [ $ret = "200" -o -n "$force" ] ; then
	echo "memtest+ was updated"
	gunzip -k -f $file
	mkdir -p ${tftpdir}/memtest/
	cp "memtest86+-5.01.bin" ${tftpdir}/memtest/memtest86+

cat <<ABC123
# netboot setup for memtest+
# from memtest.org, not memtest.com
LABEL Memtestplus
  MENU LABEL Memtest86+ V5.01
  KERNEL memdisk
  APPEND initrd=memtest/memtest86+

ABC123

fi
