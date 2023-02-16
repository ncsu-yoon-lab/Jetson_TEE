LOCAL_DIR := $(GET_LOCAL_DIR)

MODULE := $(LOCAL_DIR)


MODULE_SRCS += \
	$(LOCAL_DIR)/ashish_test_ta.c \
	$(LOCAL_DIR)/manifest.c

MODULE_DEPS += \
	app/trusty \
	lib/libc-trusty \

$(warning VISHRUTH LOCAL_DIR = $(MODULE))
include make/module.mk

