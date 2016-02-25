
# Netboot Updater

Having been annoyed one too many times by my Debian netboot kernels getting out
of date with respect to the kernel module packages I wrote this script to keep
the netboot setup up to date.

## Setup

edit `config.sh`, it should be pretty obvious

The scripts do not create `pxelinux.cfg/default` for you, instead they create
`pxelinux.cfg/default.example`, you'll have to edit `pxelinux.cfg/default` yourself,
however it shouldn't need changing after you've done it once.

## TODO

dban menus
check checksums and fingerprints
check we don't overwrite existing stuff
