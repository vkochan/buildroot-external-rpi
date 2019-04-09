#/bin/bash

if [ -e ${1}/etc/inittab ]; then
    grep -qE '^tty1::' ${1}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a \
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${1}/etc/inittab
fi
