#!/bin/bash

set -e

SCRIPT_DIR="$(dirname $0)"
BOARD_NAME="${2}"
GENIMAGE_CFG="${SCRIPT_DIR}/../${BOARD_NAME}/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
MKIMAGE=$HOST_DIR/bin/mkimage
CONFIG="$O/.config"

# skip rpi board name arg
shift 1

for arg in "$@"
do
	case "${arg}" in
		--add-pi3-miniuart-bt-overlay)
		if ! grep -qE '^dtoverlay=' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			echo "Adding 'dtoverlay=pi3-miniuart-bt' to config.txt (fixes ttyAMA0 serial console)."
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# fixes rpi3 ttyAMA0 serial console
dtoverlay=pi3-miniuart-bt
__EOF__
		fi
		;;

		--gpu_mem_256=*|--gpu_mem_512=*|--gpu_mem_1024=*)
		# Set GPU memory
		gpu_mem="${arg:2}"
		sed -e "/^${gpu_mem%=*}=/s,=.*,=${gpu_mem##*=}," -i "${BINARIES_DIR}/rpi-firmware/config.txt"
		;;
	esac

done

rm -rf "${GENIMAGE_TMP}"

if grep -qs "BR2_aarch64=y" ${CONFIG}; then
	GENIMAGE_CFG="${SCRIPT_DIR}/../${BOARD_NAME}/genimage-64.cfg"

	# Run a 64bits kernel (armv8)
	sed -e '/^kernel=/s,=.*,=Image,' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
	if ! grep -qE '^arm_64bit=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
		cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable 64bits support
arm_64bit=1
__EOF__
	fi

	# Enable uart console
	if ! grep -qE '^enable_uart=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
		cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable rpi3 ttyS0 serial console
enable_uart=1
__EOF__
	fi
fi

if grep -qs "BR2_TARGET_UBOOT=y" ${CONFIG}; then
	$MKIMAGE -A arm -O linux -T script -C none -n boot.scr \
		-d ${SCRIPT_DIR}/boot.scr ${BINARIES_DIR}/boot.scr.uimg

	sed -e "s/kernel=.*$/kernel=u-boot.bin/" -i "${BINARIES_DIR}/rpi-firmware/config.txt"
else
	touch "${BINARIES_DIR}/boot.scr.uimg"
	touch "${BINARIES_DIR}/u-boot.bin"
fi

genimage                           \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

exit $?
