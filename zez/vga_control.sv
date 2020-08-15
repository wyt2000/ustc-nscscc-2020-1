module vga_registers(
input clk,rst,
input [3:0] we,
input [31:0] data,
input [31:0] addr,
output reg hs,vs,
output [11:0] vga_data
);
wire clk_65m;
wire locked;
clk_wiz_65m clk_65(
    .clk_in1(clk),
    .reset(rst),
    .clk_out1(clk_65m),
    .locked(locked)
);
parameter H_CNT = 11'd1343; //136+160+1024+24=1345
parameter V_CNT = 11'd805; //6+29+768+3=806
reg [10:0] h_cnt,v_cnt;
reg h_de,v_de;//data_enable
wire [11:0] rd_data;
always@(posedge clk_65m)
begin
    if(rst)
        h_cnt <= 11'd0;
    else if(h_cnt>=11'd1343)
        h_cnt <= 11'd0;
    else
        h_cnt <= h_cnt + 11'd1;
end
always@(posedge clk_65m)
begin
    if(rst)
        v_cnt <= 11'd0;
    else if(h_cnt==11'd1343) begin
        if(v_cnt>=11'd805)
            v_cnt <= 11'd0;
        else
            v_cnt <= v_cnt + 11'd1;
    end
end
always@(posedge clk_65m)
begin
    if(rst)
        h_de <= 1'b0;
    else if((h_cnt>=296)&&(h_cnt<=1319))
        h_de <= 1'b1;
    else
        h_de <= 1'b0;
end
always@(posedge clk_65m)
begin
    if(rst)
        v_de <= 1'b0;
    else if((v_cnt>=35)&&(v_cnt<=802))
        v_de <= 1'b1;
    else
        v_de <= 1'b0;
end
always@(posedge clk_65m)
begin
    if(rst)
        hs <= 1'b1;
    else if(h_cnt<=11'd135)
        hs <= 1'b0;
    else
        hs <= 1'b1;
end
always@(posedge clk_65m)
begin
    if(rst)
        vs <= 1'b1;
    else if(v_cnt<=11'd5)
        vs <= 1'b0;
    else
        vs <= 1'b1;
end
wire [13:0] cur_vga_addr;
wire [13:0] real_vga_addr;
wire [10:0] curh,curv;
wire [11:0] input_data;
wire WE;
assign WE=|we;
assign curh=h_cnt-11'd135;
assign curv=v_cnt-11'd35;
assign cur_vga_addr={curv[9:3],curh[9:3]};
assign real_vga_addr=we?addr[14:1]:cur_vga_addr;
assign input_data = (we==4'b1100) ? data[27:16]:data[11:0];
vga_Ram run_vga_ram(
    .a(real_vga_addr),
    .d(input_data),
    .we(we),
    .clk(clk),
    .spo(rd_data)
);
assign vga_data = ((v_de==1)&&(h_de==1))? rd_data : 12'h0;
endmodule
