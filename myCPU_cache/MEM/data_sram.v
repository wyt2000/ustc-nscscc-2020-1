`timescale 1ns / 1ps

module data_sram
(
    input          clk,
    input          rst,

    //sram
    output  reg         data_req     ,
    output  reg         data_wr      ,
    output  reg [1 :0]  data_size    ,
    output  reg [31:0]  data_addr    ,
    output  reg [31:0]  data_wdata   ,
    input       [31:0]  data_rdata   ,
    input               data_addr_ok ,
    input               data_data_ok ,

    input          MemRead,
    input   [3:0]  MemWrite,
    input   [31:0] addr,
    input   [31:0] wdata,
    output  reg    CLR,
    output  reg    stall
);

    parameter IDLE  =   2'b00;
    parameter HDSK  =   2'b01;
    parameter WAIT  =   2'b10;

    reg     [1:0]   current_state, next_state;
    reg     Flush;
    wire     [31:0]  reg_addr, reg_wdata;
    wire     [3:0]   reg_MemWrite;
    wire     en;

    assign en = MemWrite[0] | MemWrite[1] | MemWrite[2] | MemWrite[3] | MemRead;

    register #(32) _reg_addr (
		.clk(clk),
		.rst(rst),
        .Flush(Flush),
		.en(en),
		.d(addr),
		.q(reg_addr)
	);

    register #(32) _reg_wdata (
		.clk(clk),
		.rst(rst),
        .Flush(Flush),
		.en(en),
		.d(wdata),
		.q(reg_wdata)
	);

    register #(4) _reg_MemWrite (
		.clk(clk),
		.rst(rst),
        .Flush(Flush),
		.en(en),
		.d(MemWrite),
		.q(reg_MemWrite)
	);

    always@(posedge clk) begin
        if(rst)
            current_state   <=  IDLE;
        else
            current_state   <=  next_state;
    end

    always@(*) begin
        case(current_state)
            IDLE: begin
                if(en) begin
                    if(data_addr_ok) begin
                        next_state = WAIT;
                    end
                    else begin
                        next_state = HDSK;
                    end
                end
                else begin
                    next_state = IDLE;
                end
            end

            HDSK: begin
                if(data_addr_ok)
                    next_state = WAIT;
                else
                    next_state = HDSK;
            end

            WAIT: begin
                if(data_data_ok)
                    next_state = IDLE;
                else
                    next_state = WAIT;
            end

            default: next_state = IDLE;
        endcase
    end

    always@(*) begin
        data_req    = 0;
        CLR         = 0;
        stall       = 0;
        data_wr     = 0;
        data_size   = 0;
        data_addr   = 0;
        data_wdata  = 0;
        Flush       = 0;
        case (current_state)
            IDLE: begin
                if(en) begin
                    data_req = 1;
                    CLR = 1;
                    stall = 1;
                    if(MemRead) begin
                        data_size   =  2'b10;
                        data_addr[1:0]  =  2'b00;
                        data_addr[28:2] =  addr[28:2];
                        data_wr = 0;
                    end
                    else begin
                        case(MemWrite)
                                4'b0001: begin
                                    data_size       =  2'b00;
                                    data_addr[1:0]  =  2'b00;
                                    data_addr[28:2] =  addr[28:2];
                                    data_wdata      =  wdata;
                                    data_wr         =  1;
                                end

                                4'b0010: begin
                                    data_size       =  2'b00;
                                    data_addr[1:0]  =  2'b01;
                                    data_addr[28:2] =  addr[28:2];
                                    data_wdata      =  wdata;
                                    data_wr         =  1;
                                end

                                4'b0100: begin
                                    data_size       =  2'b00;
                                    data_addr[1:0]  =  2'b10;
                                    data_addr[28:2] =  addr[28:2];
                                    data_wdata      =  wdata;
                                    data_wr         =  1;
                                end

                                4'b1000: begin
                                    data_size       =  2'b00;
                                    data_addr[1:0]  =  2'b11;
                                    data_addr[28:2] =  addr[28:2];
                                    data_wdata      =  wdata;
                                    data_wr         =  1;
                                end

                                4'b0011: begin
                                    data_size       =  2'b01;
                                    data_addr[1:0]  =  2'b00;
                                    data_addr[28:2] =  addr[28:2];
                                    data_wdata      =  wdata;
                                    data_wr         =  1;
                                end

                                4'b1100: begin
                                    data_size       =  2'b01;
                                    data_addr[1:0]  =  2'b10;
                                    data_addr[28:2] =  addr[28:2];
                                    data_wdata      =  wdata;
                                    data_wr         =  1;
                                end

                                4'b1111: begin
                                    data_size       =  2'b10;
                                    data_addr[1:0]  =  2'b00;
                                    data_addr[28:2] =  addr[28:2];
                                    data_wdata      =  wdata;
                                    data_wr         =  1;
                                end
                        endcase
                    end
                end
                else begin
                    Flush = 1;
                end
            end

            HDSK: begin
                data_req    = 1;
                CLR         = 1;
                stall       = 1;
                
                if(MemRead) begin
                    data_size   =  2'b10;
                    data_addr[1:0]  =  2'b00;
                    data_addr[28:2] =  reg_addr[28:2];
                    data_wr = 0;
                end
                else begin
                    case(reg_MemWrite)
                        4'b0001: begin
                                data_size       =  2'b00;
                                data_addr[1:0]  =  2'b00;
                                data_addr[28:2] =  reg_addr[28:2];
                                data_wdata      =  reg_wdata;
                                data_wr         =  1;
                        end
                        4'b0010: begin
                                data_size       =  2'b00;
                                data_addr[1:0]  =  2'b01;
                                data_addr[28:2] =  reg_addr[28:2];
                                data_wdata      =  reg_wdata;
                                data_wr         =  1;
                        end
                        4'b0100: begin
                                data_size       =  2'b00;
                                data_addr[1:0]  =  2'b10;
                                data_addr[28:2] =  reg_addr[28:2];
                                data_wdata      =  reg_wdata;
                                data_wr         =  1;
                        end
                        4'b1000: begin
                                data_size       =  2'b00;
                                data_addr[1:0]  =  2'b11;
                                data_addr[28:2] =  reg_addr[28:2];
                                data_wdata      =  reg_wdata;
                                data_wr         =  1;
                        end
                        4'b0011: begin
                                data_size       =  2'b01;
                                data_addr[1:0]  =  2'b00;
                                data_addr[28:2] =  reg_addr[28:2];
                                data_wdata      =  reg_wdata;
                                data_wr         =  1;
                        end
                        4'b1100: begin
                                data_size       =  2'b01;
                                data_addr[1:0]  =  2'b10;
                                data_addr[28:2] =  reg_addr[28:2];
                                data_wdata      =  reg_wdata;
                                data_wr         =  1;
                        end
                        4'b1111: begin
                                data_size       =  2'b10;
                                data_addr[1:0]  =  2'b00;
                                data_addr[28:2] =  reg_addr[28:2];
                                data_wdata      =  reg_wdata;
                                data_wr         =  1;
                        end
                    endcase
                end
            end

            WAIT: begin
                Flush   = 1;
                if (!data_data_ok) begin
                    CLR     = 1;
                    stall   = 1;
                end
            end
        endcase
    end

endmodule