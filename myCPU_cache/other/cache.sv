`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/22 17:16:05
// Design Name: 
// Module Name: ICache
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cache #(
    parameter  OFFSET_LEN    = 5,
    parameter  INDEX_LEN = 7,
    parameter  TAG_LEN  = 20,
    parameter  WAY_CNT  = 2
)(
    input  clk, rst,
    output miss,               // 对CPU发出的miss信号
    input  [31:0] addr,        // 读写请求地址
    input  rd_req,             // 读请求信号
    output reg [31:0] rd_data, // 读出的数据，一次读一个word
    
    //AXI
    input mem_gnt,
    input [31:0] ins [1<<(OFFSET_LEN-2)],
    output [31:0] mem_addr,
    output mem_read_req
);

wire [TAG_LEN-1   : 0] tag;
assign tag=addr[31:12];
wire [INDEX_LEN-1 : 0] index;
assign index=addr[11:5];
wire [TAG_LEN-1   : 0] cache_tag[WAY_CNT];
wire [WAY_CNT-1:0] valid;
wire [31:0] cache_mem [WAY_CNT][1<<(OFFSET_LEN-2)];
wire [4:0] offset;
assign offset=addr[4:0];
reg weW[WAY_CNT];
reg [7:0] weB[WAY_CNT];
TAG_V_RAM TAG_V_RAM_Way0(.a(index),.d({tag,1}),.clk(clk),.we(weW[0]),.spo({cache_tag[0],valid[0]}));
TAG_V_RAM TAG_V_RAM_Way1(.a(index),.d({tag,1}),.clk(clk),.we(weW[1]),.spo({cache_tag[1],valid[1]}));
data_bank Way0_bank0    (.a(index),.d(ins[0]),.clk(clk),.we(weB[0][0]),.spo(cache_mem[0][0]));
data_bank Way0_bank1    (.a(index),.d(ins[1]),.clk(clk),.we(weB[0][1]),.spo(cache_mem[0][1]));
data_bank Way0_bank2    (.a(index),.d(ins[2]),.clk(clk),.we(weB[0][2]),.spo(cache_mem[0][2]));
data_bank Way0_bank3    (.a(index),.d(ins[3]),.clk(clk),.we(weB[0][3]),.spo(cache_mem[0][3]));
data_bank Way0_bank4    (.a(index),.d(ins[4]),.clk(clk),.we(weB[0][4]),.spo(cache_mem[0][4]));
data_bank Way0_bank5    (.a(index),.d(ins[5]),.clk(clk),.we(weB[0][5]),.spo(cache_mem[0][5]));
data_bank Way0_bank6    (.a(index),.d(ins[6]),.clk(clk),.we(weB[0][6]),.spo(cache_mem[0][6]));
data_bank Way0_bank7    (.a(index),.d(ins[7]),.clk(clk),.we(weB[0][7]),.spo(cache_mem[0][7]));
data_bank Way1_bank0    (.a(index),.d(ins[0]),.clk(clk),.we(weB[1][0]),.spo(cache_mem[1][0]));
data_bank Way1_bank1    (.a(index),.d(ins[1]),.clk(clk),.we(weB[1][1]),.spo(cache_mem[1][1]));
data_bank Way1_bank2    (.a(index),.d(ins[2]),.clk(clk),.we(weB[1][2]),.spo(cache_mem[1][2]));
data_bank Way1_bank3    (.a(index),.d(ins[3]),.clk(clk),.we(weB[1][3]),.spo(cache_mem[1][3]));
data_bank Way1_bank4    (.a(index),.d(ins[4]),.clk(clk),.we(weB[1][4]),.spo(cache_mem[1][4]));
data_bank Way1_bank5    (.a(index),.d(ins[5]),.clk(clk),.we(weB[1][5]),.spo(cache_mem[1][5]));
data_bank Way1_bank6    (.a(index),.d(ins[6]),.clk(clk),.we(weB[1][6]),.spo(cache_mem[1][6]));
data_bank Way1_bank7    (.a(index),.d(ins[7]),.clk(clk),.we(weB[1][7]),.spo(cache_mem[1][7]));
reg LRU [WAY_CNT][INDEX_LEN-1:0];

reg [WAY_CNT-1:0] set_search;
wire cache_hit;
assign cache_hit=(|set_search);
enum {IDLE,SWAP_IN,SWAP_IN_FINISHED} cache_state;

always@(*)
begin
    if (rst) begin
        rd_data=0;
    end
    
    for (integer i=0;i<WAY_CNT;i++) begin
        if (valid[i] && cache_tag[i]==tag) begin
            set_search[i]=1'b1;
        end
        else
            set_search[i]=1'b0;
    end
    
    case (set_search)
        2'b00: rd_data=31'b0;
        2'b01: rd_data=cache_mem[0][offset[OFFSET_LEN-2:0]];
        2'b10: rd_data=cache_mem[1][offset[OFFSET_LEN-2:0]];
        2'b11: rd_data=cache_mem[1][offset[OFFSET_LEN-2:0]];
    endcase
end

assign mem_read_req=(cache_state==SWAP_IN);
assign mem_addr = mem_read_req ? {addr[31:5],5'b0} : 32'b0;
assign miss=(rd_req) && !(cache_hit && cache_state==IDLE);

always@(posedge clk or posedge rst)
begin
    if (rst) begin
        cache_state <= IDLE;  
    end
    else begin
        case (cache_state)
            IDLE: begin
                for (integer i=0;i<WAY_CNT;i++) begin
                    weW[i]<=0;
                    weB[i]<=8'b0;
                end
                if (cache_hit) begin
                
                    for (integer i=0;i<WAY_CNT;i++) begin
                        if (set_search[i])
                            LRU[i][index]<=0;
                        else
                            LRU[i][index]<=1;
                    end
                end
                else begin
                    cache_state <= SWAP_IN;
                end
            end
            SWAP_IN:begin
                if (mem_gnt) begin
                    cache_state <= SWAP_IN_FINISHED;
                end
            end
            SWAP_IN_FINISHED:begin
                cache_state <=  IDLE;
            end
        endcase
    end
end

always@(*) begin
    if(cache_state == SWAP_IN_FINISHED) begin
        case (valid)
        2'b00:begin
            weW[0]=1;
            weB[0]=8'b1;
        end
        2'b01:begin
            weW[1]=1;
            weB[1]=8'b1;
        end
        2'b10:begin
            weW[0]=1;
            weB[0]=8'b1;
        end
        2'b11:begin
            if (LRU[0][index]==1) begin
                weW[0]=1;
                weB[0]=8'b1;
            end
            else begin
                weW[1]=1;
                weB[1]=8'b1;
            end
        end
        endcase

    end
end

endmodule
