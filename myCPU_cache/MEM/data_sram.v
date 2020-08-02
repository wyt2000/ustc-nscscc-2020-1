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
    input          MemWrite,
    input   [3:0]  calWE,
    input   [31:0] addr,
    input   [31:0] wdata,
    output  reg    CLR,
    output  reg    stall
);

    localparam IDLE  =   2'b00;
    localparam HDSK  =   2'b01;
    localparam WAIT  =   2'b10;

    localparam  RD   =   0;
    localparam  WR   =   1;

    reg     [1:0]   current_state, next_state;
    reg     Flush;
    wire    reg_req_type;
    wire     [31:0]  reg_addr, reg_wdata;
    wire     [3:0]   reg_calWE;
    wire     full, empty;
    reg     en, rd_en;
    wire    [67:0]  fifo_data;

    UNCACHED_FIFO BUFFER (
        .clk(clk),
        .srst(rst),
        .full(full),
        .din({addr, wdata, calWE}),
        .wr_en(MemWrite && !full),
        .empty(empty),
        .dout(fifo_data),
        .rd_en(rd_en)
    );

    register #(32) _reg_addr (
		.clk(clk),
		.rst(rst),
        .Flush(Flush),
		.en(en),
		.d((empty ? addr : fifo_data[67:36])),
		.q(reg_addr)
	);

    register #(32) _reg_wdata (
		.clk(clk),
		.rst(rst),
        .Flush(Flush),
		.en(en),
		.d((empty ? wdata : fifo_data[35:4])),
		.q(reg_wdata)
	);

    register #(4) _reg_calWE (
		.clk(clk),
		.rst(rst),
        .Flush(Flush),
		.en(en),
		.d(empty ? calWE : fifo_data[3:0]),
		.q(reg_calWE)
	);

    register #(1) _reg_req_type (
        .clk(clk),
        .rst(rst),
        .Flush(Flush),
        .en(en),
        .d(empty ? RD : WR),
        .q(reg_req_type)
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
                if(!empty || MemRead) begin
                    next_state = HDSK;
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
        rd_en       = 0;
        en          = 0;
        case (current_state)
            IDLE: begin
                if(!empty || MemRead) begin
                    en          =   1;
                end
                if((full && MemWrite) || MemRead)
                    stall       =   1;
                if(!empty)
                    rd_en       =   1;
            end

            HDSK: begin
                data_req    = 1;
                data_addr[28:2] =  reg_addr[28:2];
                if((full && MemWrite) || reg_req_type ==  RD) begin
                    stall           =   1;
                end
                if(reg_req_type ==  WR) begin
                    data_wdata      =  reg_wdata;
                    data_wr         =  1;
                end
                case(reg_calWE)
                    4'b0001: begin
                        data_size       =  2'b00;
                        data_addr[1:0]  =  2'b00;
                    end
                    4'b0010: begin
                        data_size       =  2'b00;
                        data_addr[1:0]  =  2'b01;
                    end
                    4'b0100: begin
                        data_size       =  2'b00;
                        data_addr[1:0]  =  2'b10;
                    end
                    4'b1000: begin
                        data_size       =  2'b00;
                        data_addr[1:0]  =  2'b11;
                    end
                    4'b0011: begin
                        data_size       =  2'b01;
                        data_addr[1:0]  =  2'b00;
                    end
                    4'b1100: begin
                        data_size       =  2'b01;
                        data_addr[1:0]  =  2'b10;
                    end
                    4'b1111: begin
                        data_size       =  2'b10;
                        data_addr[1:0]  =  2'b00;
                    end
                endcase
            end

            WAIT: begin
                if (((reg_req_type == RD) && !data_data_ok) || (full && MemWrite)) begin
                    stall   = 1;
                end
            end
        endcase
    end

endmodule