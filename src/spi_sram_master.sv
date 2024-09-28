`resetall
`timescale 1ns / 1ps
`default_nettype none


module spi_sram_master (
    input  wire clk,
    input  wire clk2,
    input  wire rst,
    input  wire en,
    input  wire en2,

    output wire ready,

    output wire cs_n,
    input  wire miso,
    output wire mosi,

    input  wire [23:0]mem_addr,
    input  wire       mem_en,
    input  wire       mem_wr,
    input  wire  [7:0]mem_wdata,
    output wire  [7:0]mem_rdata    
);

typedef enum integer {
    IDLE,
    LOAD,
    CMDADDR1,
    CMDADDR2,
    DATA1,
    DATA2,
    DELAY1,
    DELAY2,
    DELAY3
} State_Type;

State_Type state = IDLE;

State_Type next_state;

logic ready_sm;
logic cs_n_sm;

logic counter_reset;
logic [4:0]counter_reset_val;

logic data_shift;
logic data_load;
logic [39:0]data_load_val;

logic dhold_load;

logic addr_shift;
logic addr_load;
logic addr_load_lsb;
logic addr_incr;
logic addr_early;

logic men;
logic mwr;


reg counter_done;


always_comb begin
    next_state = state;
    
    ready_sm = 0;
    cs_n_sm  = 0;

    counter_reset = 0;
    counter_reset_val = (7-2);

    data_shift = 0;
    data_load  = 0;
    data_load_val = 0;
    
    dhold_load = 0;

    addr_shift = 0;
    addr_load  = 0;
    addr_load_lsb = 0;
    addr_incr  = 0;
    addr_early = 0;

    unique case(state)
        IDLE: begin // IDLE
            ready_sm = 1;
            cs_n_sm  = 1;
            
            counter_reset = 1;
            counter_reset_val = (31-2);

            if (mem_en) begin
                data_load = 1;

                if (mem_wr)
                    data_load_val = { 8'h82, mem_addr, mem_wdata };
                else
                    data_load_val = { 8'h83, mem_addr, mem_wdata };

                next_state = CMDADDR1;
            end
        end

        CMDADDR1: begin
            data_shift = 1;

            if (counter_done)
                next_state = CMDADDR2;
        end

        CMDADDR2: begin
            counter_reset = 1;
            counter_reset_val = (7-2);

            data_shift = 1;

            next_state = DATA1;
        end

        DATA1: begin
            data_shift = 1;

            if (counter_done)
                next_state = DATA2;
        end

        DATA2: begin
            counter_reset = 1;
            counter_reset_val = (3-2);
            
            data_shift = 1;
            dhold_load = 1;
            
            next_state = DELAY1;
        end
        
        DELAY1: begin
            ready_sm = 1;
            cs_n_sm  = 1;


            if (mem_en) begin
                data_load = 1;

                if (mem_wr)
                    data_load_val = { 8'h82, mem_addr, mem_wdata };
                else
                    data_load_val = { 8'h83, mem_addr, mem_wdata };

                if (counter_done)
                    next_state = DELAY3;
                else
                    next_state = DELAY2;
            end
            else if (counter_done)
                next_state = IDLE;
        end
        
        DELAY2: begin
            ready_sm = 0;
            cs_n_sm  = 1;
            
            if (counter_done)
                next_state = DELAY3;            
        end    
        
        DELAY3: begin
            ready_sm = 0;
            cs_n_sm  = 1;
            
            counter_reset = 1;
            counter_reset_val = (31-2);

            next_state = CMDADDR1;
        end
    endcase
end


// state register
always_ff @(posedge clk) begin
    if (rst)
        state <= IDLE;
    else if (en)
        state <= next_state;
end

reg [4:0]counter;
always_ff @(posedge clk) begin
    if (en && counter_reset)
        { counter_done, counter } <= { 1'b0, counter_reset_val };
    else if (en)
        { counter_done, counter } <= counter - 1;
end

reg [39:0]data;
always_ff @(posedge clk) begin
    if (en) begin
        if (data_load)
            data <= data_load_val;
        else if (data_shift)
            data <= { data, miso };
    end
end

reg dout;
always_ff @(posedge clk2) begin
    if (en2)
        dout <= data[39];
end

reg [7:0]dhold;
always_ff @(posedge clk) begin
    if (en && dhold_load) begin
        dhold <= { data, miso };
    end
end

reg cs_n_out;
always_ff @(posedge clk2) begin
    if (en2)
        cs_n_out <= cs_n_sm;
end

//assign mem_rdata = dhold;
assign mem_rdata = data[7:0];

assign mosi = dout;

assign ready = ready_sm;
assign cs_n  = cs_n_out;

endmodule
`resetall
