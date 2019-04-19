################################################################################
#
# toolchain-external-rpi-arm
#
################################################################################

TOOLCHAIN_EXTERNAL_RPI_ARM_VERSION = 2f0e57d4c8b8e0f37b51e6eec799efce2d616f2e
TOOLCHAIN_EXTERNAL_RPI_ARM_SITE = $(call github,vkochan,toolchain-rpi-arm-4.9.3-linux-gnueabihf,$(TOOLCHAIN_EXTERNAL_RPI_ARM_VERSION))

$(eval $(toolchain-external-package))
