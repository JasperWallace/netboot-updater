
# Netboot Updater

Having been annoyed one too many times by my Debian netboot kernels getting out
of date with respect to the kernel module packages I wrote this script to keep
the netboot setup up to date.

## Setup

install curl

edit `config.sh`, it should be pretty obvious

The scripts do not create `pxelinux.cfg/default` for you, instead they create
`pxelinux.cfg/default.example`, you'll have to edit `pxelinux.cfg/default` yourself,
however it shouldn't need changing after you've done it once.

You'll need to put:

* pxelinux.0
* ldlinux.c32
* vesamenu.c32
* libcom32.c32
* libutil.c32

In the root of your tftp dir, they will be in `debian-installer/jessie/amd64/boot-screens/`
(assuming your using debian), if not they will be somewhere under the directory structure of
whatever it is you are booting, if you still can't find them they are part of the pxelinux
bits of syslinux, which you can find here:

https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz

## TODO

* dban menus
* check checksums and fingerprints
* check we don't overwrite existing stuff
