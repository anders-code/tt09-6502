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
wire [15:0]ab;
cpu cpu_inst (
    .clk,
    .reset (~rst_n),
    .AB (ab),
    .DI (uio_in),
    .DO (uio_out),
    .WE (we),
    .IRQ (ui_in[6]),
    .NMI (ui_in[7]),
    .RDY (ui_in[4])
);

logic [7:0]out;
always_comb begin
    unique casez (ui_in[1:0])
       2'b00: out = ab[7:0];
       2'b01: out = ab[15:8];
       2'b1?: out = { 7'b0, we };
    endcase
end

assign uo_out = out;
assign uio_oe = we ? 8'hff : 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ui_in[3:2], ui_in[5], ena, clk, rst_n, 1'b0};

endmodule
