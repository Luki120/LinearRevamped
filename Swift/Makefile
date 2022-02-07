TARGET := iphone:clang:latest:12.2
INSTALL_TARGET_PROCESSES = SpringBoard

TWEAK_NAME = LinearRevamped

LinearRevamped_FILES = $(shell find Sources/LinearRevamped -name '*.swift') $(shell find Sources/LinearRevampedC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
LinearRevamped_CFLAGS = -fobjc-arc -ISources/LinearRevampedC/include
LinearRevamped_SWIFTFLAGS = -ISources/LinearRevampedC/include

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
