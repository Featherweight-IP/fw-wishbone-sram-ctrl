
FW_WISHBONE_SRAM_CTRL_VERILOG_RTLDIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

ifeq (,$(findstring $(FW_WISHBONE_SRAM_CTRL_VERILOG_RTLDIR),$(MKDV_INCLUDED_DEFS)))
include $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/defs_rules.mk
MKDV_VL_SRCS += $(wildcard $(FW_WISHBONE_SRAM_CTRL_VERILOG_RTLDIR)/*.v)
endif

else # Rules

endif
