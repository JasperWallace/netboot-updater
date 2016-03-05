#!/bin/bash

. "`dirname $0`/config.sh"
cd $workdir

# partly from http://wiki.hackzine.org/sysadmin/debian-pxe-server.html

# http://archive.ubuntu.com/ubuntu/dists/trusty-updates/main/installer-amd64/current/images/netboot/netboot.tar.gz
# http://archive.ubuntu.com/ubuntu/dists/wily/main/installer-amd64/current/images/netboot/netboot.tar.gz

rm -f ${menus}/ubuntu-menu.cfg
cat > ${menus}/ubuntu-menu.cfg << EOF
default vesamenu.c32
prompt 0
timeout 0
menu title Ubuntu Installers
menu include pxelinux.cfg/graphics.conf

EOF
mkdir -p ${tftpdir}/ubuntu-installer/

for dist in trusty-updates wily ; do
	for arch in i386 amd64; do
		extra=""
		if [ -e $dist-$arch-netboot.tar.gz ] ; then
			extra="-z $dist-$arch-netboot.tar.gz"
		fi
		ret="$(curl ${extra} ${curlargs} --write-out '%{http_code}' --location -o $dist-$arch-netboot.tar.gz \
		http://archive.ubuntu.com/ubuntu/dists/${dist}/main/installer-${arch}/current/images/netboot/netboot.tar.gz)"
		if [ $ret = "200" -o -n "$force" ] ; then
			echo "$dist-$arch was updated"
			tar xzf ${dist}-${arch}-netboot.tar.gz ./ubuntu-installer/
			find ./ubuntu-installer/ -type f -print0 | \
				xargs -0 sed "s,ubuntu-installer/,ubuntu-installer/${dist}/," -i
			mkdir -p _ubuntu-installer/${dist}
			rm -rf _ubuntu-installer/${dist}/${arch}
			mv -f "./ubuntu-installer/${arch}/" "./_ubuntu-installer/${dist}/"
			rm -rf ./ubuntu-installer/
			mkdir -p ${tftpdir}/ubuntu-installer/${dist}
			rm -rf ${tftpdir}/ubuntu-installer/${dist}/${arch}
			mv -v -f ./_ubuntu-installer/${dist}/${arch} ${tftpdir}/ubuntu-installer/${dist}/${arch}
cat >> ${menus}/ubuntu-menu.cfg <<EOF
label Install Ubuntu ${dist} ${arch}
	menu label ^Ubuntu ${dist} ${arch}
	kernel vesamenu.c32
	append ubuntu-installer/${dist}/${arch}/boot-screens/menu.cfg

EOF
		elif [ $ret = "304" ] ; then
        		# not modified
        		true
        	else
        		echo "got: ${ret} trying to download $dist-$arch-netboot.tar.gz, maybe something is wrong?"
        	fi
	done
done

cat >> ${menus}/ubuntu-menu.cfg <<ABC123
LABEL back
 MENU LABEL back
 KERNEL vesamenu.c32
 APPEND ~
ABC123
