MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))

MKDV_TOOL ?= icarus

TOP_MODULE = fw_wishbone_sram_ctrl_single_tb
MKDV_PLUGINS += cocotb pybfms
PYBFMS_MODULES += generic_sram_bfms wishbone_bfms
MKDV_COCOTB_MODULE ?= fw_wishbone_sram_ctrl_tests.smoke

MKDV_VL_SRCS += $(TEST_DIR)/$(TOP_MODULE).sv


include $(TEST_DIR)/../../common/defs_rules.mk

RULES := 1

include $(TEST_DIR)/../../common/defs_rules.mk

