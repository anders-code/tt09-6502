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

wire nmi;
wire irq;
wire x;

spi_cpu_6502 spi_cpu_inst (
    .clk,
    .arst_n   (rst_n),
    .nmi,
    .irq,
    .cs_n     (uio_out[0]),
    .mosi     (uio_out[1]),
    .miso     (uio_in[2]),
    .sync     (uo_out[7]),
    .gpin     (ui_in[7:0]),
    .gpout    ({ x, uo_out[6:0] }),
    .gpio_in  (uio_in[7:4]),
    .gpio_oe  (uio_oe[7:4]),
    .gpio_out (uio_out[7:4])
);

// synchronize irq and nmi

reg [1:0]nmi_sync;
reg [1:0]irq_sync;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        nmi_sync <= 2'b00;
        irq_sync <= 2'b00;
    end
    else begin
        nmi_sync <= { nmi_sync[0], ui_in[7] };
        irq_sync <= { irq_sync[0], ui_in[6] };
    end
end
assign nmi = nmi_sync[1];
assign irq = irq_sync[1];

assign uio_out[2]  = 0;   // miso
assign uio_out[3]  = clk; // sclk

assign uio_oe[3:0] = 4'hb;

// List all unused inputs to prevent warnings
wire _unused = &{ ena, x, 1'b0 };

endmodule
