LOCAL_DIR := $(GET_LOCAL_DIR)

MODULE := $(LOCAL_DIR)

MODULE_SRCS += \
	$(LOCAL_DIR)/ashish_test_ta2.c \
	$(LOCAL_DIR)/manifest.c

MODULE_DEPS += \
	app/trusty \
	lib/libc-trusty \

include make/module.mk
