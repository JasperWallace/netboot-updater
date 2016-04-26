#!/bin/bash

. "`dirname $0`/config.sh"

mirror="ftp.${location}.debian.org"

cd $workdir

# wget http://"$YOURMIRROR"/debian/dists/wheezy/main/installer-"$ARCH"/current/images/netboot/netboot.tar.gz
# wget http://"$YOURMIRROR"/debian/dists/wheezy/main/installer-"$ARCH"/current/images/SHA256SUMS
# wget http://"$YOURMIRROR"/debian/dists/wheezy/Release
# wget http://"$YOURMIRROR"/debian/dists/wheezy/Release.gpg

# cat SHA256SUMS | grep -F netboot/netboot.tar.gz
#ac278b204f768784824a108e7cf3ae8807f9969adcb4598effeff2b92055bb52  ./netboot/netboot.tar.gz
# sha256sum netboot.tar.gz
#ac278b204f768784824a108e7cf3ae8807f9969adcb4598effeff2b92055bb52  netboot.tar.gz
#(match!)

# sha256sum SHA256SUMS
#4856ecb5015b93d7dd02249c91d03bd88890d44bd25d8a2d2a400bab63f9d7de  SHA256SUMS
# cat Release | grep -A 100000 '^SHA256' | grep -F installer-"$ARCH"/current/images/SHA256SUMS
#4856ecb5015b93d7dd02249c91d03bd88890d44bd25d8a2d2a400bab63f9d7de    14289 main/installer-"$ARCH"/current/images/SHA256SUMS
#(match!)

rm -f ${menus}/debian-menu.cfg
cat > ${menus}/debian-menu.cfg << EOF
default vesamenu.c32
prompt 0
timeout 0
menu title Debian Installers
menu include pxelinux.cfg/graphics.conf

EOF

for dist in jessie wheezy; do
	for arch in i386 amd64; do
		extra=""
		if [ -e $dist-$arch-netboot.tar.gz ] ; then
			extra="-z $dist-$arch-netboot.tar.gz"
		fi
	        ret="$(curl ${extra} ${curlargs} --write-out '%{http_code}' --location -o $dist-$arch-netboot.tar.gz \
        	http://${mirror}/debian/dists/${dist}/main/installer-${arch}/current/images/netboot/netboot.tar.gz)"
        	if [ $ret = "200" -o -n "$force" ] ; then
        		# we got updated
        		echo "$dist-$arch was updated"
        		curl ${curlargs} --location -z $dist-$arch-SHA256SUMS -o $dist-$arch-SHA256SUMS http://${mirror}/debian/dists/${dist}/main/installer-${arch}/current/images/SHA256SUMS
        		curl ${curlargs} --location -z ${dist}-Release -o ${dist}-Release http://${mirror}/debian/dists/${dist}/Release
        		curl ${curlargs} --location -z ${dist}-Release.gpg -o ${dist}-Release.gpg http://${mirror}/debian/dists/${dist}/Release.gpg
        		cat $dist-$arch-SHA256SUMS | grep -F netboot/netboot.tar.gz
        		sha256sum $dist-$arch-netboot.tar.gz
        		cat ${dist}-Release | grep -A 100000 '^SHA256' | grep -F installer-"${arch}"/current/images/SHA256SUMS
        		sha256sum $dist-$arch-SHA256SUMS
        		if [ ! -e ${tftpdir}/debian-installer/${dist} ] ; then
        			mkdir -p ${tftpdir}/debian-installer/${dist}
        		fi
        		if [ ! -e ${tftpdir}/debian-installer/${dist}/${arch} ] ; then
        			mkdir -p ${tftpdir}/debian-installer/${dist}/${arch}
        		fi
        		# nuke any existing extracted stuff
        		rm -rf debian-installer
        		tar xzf $dist-$arch-netboot.tar.gz ./debian-installer/
        		# mangle menu entries to fit under our new directory structure
        		find debian-installer/ -type f -iname "*.cfg" -print0 | xargs -0 sed "s,debian-installer/,debian-installer/${dist}/," -i
			# nuke any existing stuff at the destination
			rm -rf ${tftpdir}/debian-installer/${dist}/${arch}
        		mv -v -f -T debian-installer/${arch} ${tftpdir}/debian-installer/${dist}/${arch}
cat >> ${menus}/debian-menu.cfg <<ABC123
label Debian ${dist} ${arch}
      menu label ^Debian ${dist} ${arch}
      kernel vesamenu.c32
      append debian-installer/$dist/$arch/boot-screens/menu.cfg
ABC123
        	elif [ $ret = "304" ] ; then
        		# not modified
        		true
        	else
        		echo "got: ${ret} trying to download $dist-$arch-netboot.tar.gz, maybe something is wrong?"
        	fi
        done
done

cat >> ${menus}/debian-menu.cfg <<ABC123
LABEL back
 MENU LABEL back
 KERNEL vesamenu.c32
 APPEND ~
ABC123
