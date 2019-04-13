#!/bin/bash

set -e

SCRIPT_DIR="$(dirname $0)"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
MKIMAGE=$HOST_DIR/bin/mkimage
CONFIG="$O/.config"

# $1 - config option
#
# return:
#          empty string or config value (un-quoted)
function br_config_get {
	local opt=$1
	local val=""

	val=$(grep -m 1 -s "${opt}=" ${CONFIG} | awk -F '=' '{ print $2; }')
	val="${val%\"}"
	val="${val#\"}"

	echo "${val}"
}

BOARD_NAME="$(br_config_get BR2_RPI_BOARD_NAME)"
if [ -z "${BOARD_NAME}" ]; then
	echo "[error] empty rpi board name"
	exit 1
fi

GENIMAGE_CFG="${SCRIPT_DIR}/../${BOARD_NAME}/genimage.cfg"

rm -rf "${GENIMAGE_TMP}"

if grep -qs "BR2_aarch64=y" ${CONFIG}; then
	GENIMAGE_CFG="${SCRIPT_DIR}/../${BOARD_NAME}/genimage-64.cfg"

	# Run a 64bits kernel
	sed -e '/^kernel=/s,=.*,=Image,' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
	if ! grep -qE '^arm_64bit=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
		echo "arm_64bit=1" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
	fi
else
	# Run a 32bits kernel
	sed -e '/^kernel=/s,=.*,=zImage,' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
	sed -e 's/^arm_64bit=1.*$//' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
fi

# Enable mini-uart console
if grep -qs "BR2_RPI_CONSOLE_USE_MINI_UART=y" ${CONFIG}; then
	if ! grep -qE '^enable_uart=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
		echo "enable_uart=1" >> "${BINARIES_DIR}/rpi-firmware/config.txt"

	fi
else
	sed -e 's/^enable_uart=.*$//' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
fi

if grep -qs "BR2_RPI_BT_SLOW=y" ${CONFIG}; then
	if ! grep -qE '^dtoverlay=' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
		echo "dtoverlay=pi3-miniuart-bt" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
	fi
else
	sed -e 's/^dtoverlay=pi3-miniuart-bt.*$//' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
fi

if ! grep -qs "BR2_RPI_USE_BT=y" ${CONFIG}; then
	if ! grep -qE '^dtoverlay=' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
		echo "dtoverlay=pi3-disable-bt" >> "${BINARIES_DIR}/rpi-firmware/config.txt"
	fi
else
	sed -e 's/^dtoverlay=pi3-disable-bt.*$//' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
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
