`timescale 1ns / 1ps

module inst_sram
(
    input          clk,
    input          rst,

    //sram
    output  reg         inst_req     ,
    output              inst_wr      ,
    output      [1 :0]  inst_size    ,
    output  reg [31:0]  inst_addr    ,
    output      [31:0]  inst_wdata   ,
    input       [31:0]  inst_rdata   ,
    input               inst_addr_ok ,
    input               inst_data_ok ,

    input          is_newPC,
    input   [31:0] PC,
    output  reg    CLR,
    output  reg    stall
);

    assign inst_wr      =   0;
    assign inst_size    =   2'b10;
    assign inst_wdata   =   32'b0;
    
    parameter IDLE  =   2'b00;
    parameter HDSK  =   2'b01;
    parameter WAIT  =   2'b10;
    parameter RECV  =   2'b11;

    reg     [31:0]  addr;
    reg     [1:0]   current_state, next_state;

    always@(posedge clk) begin
        if(rst)
            addr <= 0;
        else if(is_newPC)
            addr <= PC;
        else
            addr <= addr;
    end

    always@(posedge clk) begin
        if(rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always@(*) begin
        case(current_state)
            IDLE: begin
                if(is_newPC && inst_addr_ok)
                    next_state = WAIT;
                else if(is_newPC)
                    next_state = HDSK;
                else
                    next_state = IDLE;
            end

            HDSK: begin
                if(inst_addr_ok)
                    next_state = WAIT;
                else
                    next_state = HDSK;
            end

            WAIT: begin
                if(inst_data_ok)
                    next_state = IDLE;
                else
                    next_state = WAIT;
            end

            default: next_state = IDLE;
        endcase
    end

    always@(*) begin
        inst_req    = 0;
        inst_addr   = 0;
        CLR         = 0;
        stall       = 0;
        case (current_state)
            IDLE: begin
                if(is_newPC) begin
                    CLR = 1;
                    stall = 1;
                    inst_req = 1;
                    inst_addr = PC;
                end
            end

            HDSK: begin
                inst_req    = 1;
                inst_addr   = addr;
                CLR         = 1;
                stall       = 1;
            end

            WAIT: begin
                if(inst_data_ok) begin
                    CLR = 0;
                    stall = 0;
                end
                else begin
                    CLR      = 1;
                    stall    = 1;
                end
            end

        endcase
    end

endmodule 