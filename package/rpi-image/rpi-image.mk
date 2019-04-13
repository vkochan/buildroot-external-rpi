################################################################################
#
# rpi-image
#
################################################################################

RPI_IMAGE_VERSION = 0.1
RPI_IMAGE_DEPENDENCIES = $(if $(BR2_PACKAGE_BUSYBOX),busybox)
RPI_IMAGE_INSTALL_IMAGES = YES
RPI_IMAGE_SOURCE =

RPI_IMAGES_ENV = $(EXTRA_ENV) \
		 BR2_RPI_USE_BT=$(BR2_RPI_USE_BT) \
		 BR2_RPI_BT_NORMAL=$(BR2_RPI_BT_NORMAL) \
		 BR2_RPI_BT_SLOW=$(BR2_RPI_BT_SLOW) \
		 BR2_RPI_CONSOLE_USE_NORMAL_UART=$(BR2_RPI_CONSOLE_USE_NORMAL_UART) \
		 BR2_RPI_CONSOLE_USE_MINI_UART=$(BR2_RPI_CONSOLE_USE_MINI_UART) \
		 BR2_aarch64=$(BR2_aarch64) \
		 BR2_TARGET_UBOOT=$(BR2_TARGET_UBOOT) \
		 BR2_EXTERNAL_RPI_BOARD_NAME=$(BR2_EXTERNAL_RPI_BOARD_NAME) \
		 BR2_EXTERNAL_RPI_PATH=$(BR2_EXTERNAL_RPI_PATH)

define RPI_IMAGE_INSTALL_IMAGES_CMDS
	$(RPI_IMAGES_ENV) $(RPI_IMAGE_PKGDIR)/rpi_image_gen.sh $(BINARIES_DIR)
endef

$(eval $(generic-package))
