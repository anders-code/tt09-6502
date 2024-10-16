# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = project.sv $(wildcard ../arlet-6502/rtl/*.sv)

ifeq ($(SIM),icarus)
    COMPILE_ARGS    += -grelative-include
else ifeq ($(SIM),verilator)
    COMPILE_ARGS    += --relative-includes
    VERILOG_SOURCES += ../arlet-6502/rtl/cfg.vlt
    VERILOG_SOURCES += ../arlet-6502/sim/utils/cfg.vlt
endif

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD        = sim_build/rtl
COMPILE_ARGS    += -DCONFIG_TT=1 -DSIM=1
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

else

PDK_ROOT ?= ~/ttsetup/pdk

# Gate level simulation:
SIM_BUILD        = sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
VERILOG_SOURCES += ../arlet-6502/rtl/spi_sram_slave.sv

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Include the testbench sources:
VERILOG_SOURCES += ../arlet-6502/sim/utils/tb_utils.sv
VERILOG_SOURCES += $(PWD)/tb.sv
TOPLEVEL = tb

# MODULE is the basename of the Python test file
MODULE = test

PLUSARGS += +dumpfile

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

GATE_PNL = $(wildcard $(PWD)/../runs/wokwi/final/pnl/*.v)
$(PWD)/gate_level_netlist.v: $(GATE_PNL)
	cp -f "$(GATE_PNL)" "$@"

