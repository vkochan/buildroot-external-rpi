################################################################################
#
# rpi-console-init
#
################################################################################

RPI_CONSOLE_INIT_VERSION = 0.1
RPI_CONSOLE_INIT_DEPENDENCIES = $(if $(BR2_PACKAGE_BUSYBOX),busybox)
RPI_CONSOLE_INIT_SOURCE =

# Add a console on tty1
define RPI_CONSOLE_INIT_ADD_TTY1
	$(RPI_CONSOLE_INIT_PKGDIR)/rpi_add_tty1.sh $(TARGET_DIR)
endef
RPI_CONSOLE_INIT_TARGET_FINALIZE_HOOKS += RPI_CONSOLE_INIT_ADD_TTY1

$(eval $(generic-package))
