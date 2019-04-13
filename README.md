This repository contains buildroot external project for
Raspberry Pi boards. The goal is to easy make Pi customization
via buildroot config options, so it may be easy included with
other "externals" w/o modifications.

To build this external project:

    make BR2_DEFCONFIG=${PWD}/configs/rpi3_defconfig BR2_EXTERNAL=${PWD} O=${PWD}/output/rpi3 defconfig -C PATH_TO_BUILDROOT
    make -C output/rpi3

U-Boot
======
If u-boot is selected (BR2_TARGET_UBOOT=y) then 'rpi_3_32b' or 'rpi_3' (if 64bit mode) board is used as default.

Image generation
================
The project has rpi-image package which generates rpi image and config.txt file, to
re-generate the image and config.txt it is needed to specify 'rpi-image-reinstall' in
make invocation. If someone needs to use post-image script then it is possible to disable
rpi-image package and use script from board/common/post-image.sh.
