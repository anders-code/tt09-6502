# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(tb):
    tb._log.info("Start")

    # Set the clock period to 10 ns (100 MHz)
    clock = Clock(tb.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    tb._log.info("Reset")
    tb.rst_n.value = 0
    await ClockCycles(tb.clk, 10)
    tb.rst_n.value = 1

    tb._log.info("Test project behavior")

    # Wait for one clock cycle to see the output values
#    await ClockCycles(tb.clk, 394)
    await ClockCycles(tb.clk, 20)

#    assert tb.RDY;
#    assert tb.cs_n;
#    assert tb.state == 12;
#    assert tb.PC == 0x401;
#
