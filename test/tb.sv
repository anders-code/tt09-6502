// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 Anders <anders-code@users.noreply.github.com>

`resetall
`timescale 1ns/1ps
`default_nettype none


module tb ();

import tb_utils::*;

logic clk;   // driven by tb wrapper
logic rst_n; // driven by tb wrapper

logic ena = 1;

wire [7:0]ui_in;
wire [7:0]uo_out;
wire [7:0]uio_in;
wire [7:0]uio_out;
wire [7:0]uio_oe;

`ifdef GL_TEST
    wire VPWR = 1'b1;
    wire VGND = 1'b0;
`endif

tt_um_anders_tt_6502 uut (
    .clk,
    .rst_n,
`ifdef GL_TEST
    .VPWR,
    .VGND,
`endif
    .ena,
    .ui_in,
    .uo_out,
    .uio_in,
    .uio_out,
    .uio_oe
);


logic irq = 0;
logic nmi = 0;

wire cs_n;
wire mosi;
wire miso;
wire sclk;

assign ui_in[7]    = nmi;
assign ui_in[6]    = irq;
assign ui_in[5:0]  = 6'b00_0010;

assign uio_in[7:3] = 0;
assign uio_in[2]   = miso;
assign uio_in[1:0] = 0;

assign cs_n = uio_out[0];
assign mosi = uio_out[1];
assign sclk = uio_out[3];


wire [23:0]mem_addr;
wire       mem_en;
wire       mem_wr;
wire  [7:0]mem_wdata;
reg   [7:0]mem_rdata;

spi_sram_slave #(
    .CS_DELAY (0)
) spi_sram_slave_inst (
    .clk  (sclk),
    .clkb (~sclk),
    .rst  (~rst_n),
    .en   (1'b1),
    .enb  (1'b1),
    .cs_n,
    .miso,
    .mosi,
    .mem_addr  (mem_addr),
    .mem_en    (mem_en),
    .mem_wr    (mem_wr),
    .mem_wdata (mem_wdata),
    .mem_rdata (mem_rdata)
);

reg [7:0]mem[64*1024];
always_ff @(posedge sclk) begin
    if (mem_en) begin
        if (mem_wr)
            mem[mem_addr[15:0]] <= mem_wdata;
        mem_rdata <= mem[mem_addr[15:0]];
    end
end

// fish some signals out of the gate list
`ifdef GL_TEST

wire RDY = uut.\spi_cpu_inst.cache_inst.cpu_rdy ;

wire [15:0]PC = {
    uut.\spi_cpu_inst.cpu_inst.PC[15] ,
    uut.\spi_cpu_inst.cpu_inst.PC[14] ,
    uut.\spi_cpu_inst.cpu_inst.PC[13] ,
    uut.\spi_cpu_inst.cpu_inst.PC[12] ,
    uut.\spi_cpu_inst.cpu_inst.PC[11] ,
    uut.\spi_cpu_inst.cpu_inst.PC[10] ,
    uut.\spi_cpu_inst.cpu_inst.PC[9] ,
    uut.\spi_cpu_inst.cpu_inst.PC[8] ,
    uut.\spi_cpu_inst.cpu_inst.PC[7] ,
    uut.\spi_cpu_inst.cpu_inst.PC[6] ,
    uut.\spi_cpu_inst.cpu_inst.PC[5] ,
    uut.\spi_cpu_inst.cpu_inst.PC[4] ,
    uut.\spi_cpu_inst.cpu_inst.PC[3] ,
    uut.\spi_cpu_inst.cpu_inst.PC[2] ,
    uut.\spi_cpu_inst.cpu_inst.PC[1] ,
    uut.\spi_cpu_inst.cpu_inst.PC[0] 
};

wire [5:0]state = {
    uut.\spi_cpu_inst.cpu_inst.state[5] ,
    uut.\spi_cpu_inst.cpu_inst.state[4] ,
    uut.\spi_cpu_inst.cpu_inst.state[3] ,
    uut.\spi_cpu_inst.cpu_inst.state[2] ,
    uut.\spi_cpu_inst.cpu_inst.state[1] ,
    uut.\spi_cpu_inst.cpu_inst.state[0]
};

`else

wire RDY        = uut.spi_cpu_inst.cache_inst.cpu_rdy;
wire [5:0]state = uut.spi_cpu_inst.cpu_inst.state;
wire [15:0]PC   = uut.spi_cpu_inst.cpu_inst.PC;

`endif

initial begin
    $readmemh(tb_rel_path("../arlet-6502/sim/mem-files/basic.mem"), mem, 0, $size(mem)-1);

    if(tb_enable_dumpfile("tb.vcd"))
        $dumpvars(0, tb);
end

endmodule
`resetall
