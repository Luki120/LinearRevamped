TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

TWEAK_NAME = LinearRevamped

LinearRevamped_FILES = $(wildcard **/**/*.m) $(wildcard **/**/*.swift)
LinearRevamped_CFLAGS = -fobjc-arc -ISources/LinearRevampedC/include
LinearRevamped_SWIFTFLAGS = -ISources/LinearRevampedC/include
LinearRevamped_PRIVATE_FRAMEWORKS = CoreDuet

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
