FW_WISHBONE_SRAM_CTRL_VERILOG_DV_COMMONDIR := $(dir $(lastword $(MAKEFILE_LIST)))
FW_WISHBONE_SRAM_CTRL_DIR := $(abspath $(FW_WISHBONE_SRAM_CTRL_VERILOG_DV_COMMONDIR)/../../..)
PACKAGES_DIR := $(FW_WISHBONE_SRAM_CTRL_DIR)/packages
DV_MK := $(shell PATH=$(PACKAGES_DIR)/python/bin:$(PATH) python3 -m mkdv mkfile)


ifneq (1,$(RULES))

MKDV_PYTHONPATH += $(FW_WISHBONE_SRAM_CTRL_VERILOG_DV_COMMONDIR)/python

include $(FW_WISHBONE_SRAM_CTRL_DIR)/verilog/rtl/defs_rules.mk
include $(DV_MK)
else # Rules

include $(DV_MK)

endif
