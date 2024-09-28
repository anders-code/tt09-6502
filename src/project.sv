/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_anders_tt_6502 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
//  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in

wire we;
wire [23:0]ab;
wire  [7:0]dout;
wire  [7:0]din;
wire ready;
cpu cpu_inst (
    .clk,
    .reset (!rst_n),
    .AB  (ab[15:0]),
    .DI  (din),
    .DO  (dout),
    .WE  (we),
    .IRQ (ui_in[6]),
    .NMI (ui_in[7]),
    .RDY (ready)
);

assign ab[23:16] = 0;

wire cs_n;
wire miso;
wire mosi;

spi_sram_master spi_sram_master_inst (
    .clk,
    .clk2  (!clk),
    .rst   (!rst_n),
    .en    (1'b1),
    .en2   (1'b1),
    .ready,
    .cs_n,
    .miso,
    .mosi,
    .mem_addr  (ab),
    .mem_en    (1'b1),
    .mem_wr    (we),
    .mem_wdata (dout),
    .mem_rdata (din)
);

//logic [7:0]out;
//always_comb begin
//    unique casez (ui_in[1:0])
//       2'b00: out = ab[7:0];
//       2'b01: out = ab[15:8];
//       2'b1?: out = { 7'b0, we };
//    endcase
//end

assign uio_out[0] = cs_n;
assign uio_out[1] = mosi;
assign uio_out[3] = clk;
assign miso = uio_in[2];

assign uio_oe = 8'h0b;
assign uio_out[2] = 0;
assign uio_out[7:4] = 0;

assign uo_out[7:0] = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ui_in[5:0], ena, clk, rst_n, 1'b0};

endmodule
