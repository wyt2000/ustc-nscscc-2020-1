`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/23 10:14:01
// Design Name: 
// Module Name: mem
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

module RAM(
input clk,
input [31:0] addr,
input [3:0] WE,
input [31:0] inputdata,
output [31:0] data);
reg [31:0] RAM[31:0];

assign data=RAM[addr];

always@(posedge clk)
begin
    if (WE[3]) RAM[inputdata][31:24]=inputdata[31:24];
    if (WE[2]) RAM[inputdata][23:16]=inputdata[23:16];
    if (WE[1]) RAM[inputdata][15:8] =inputdata[15:8] ;
    if (WE[0]) RAM[inputdata][ 7:0] =inputdata[7 :0] ;
end
endmodule


module mem(
input clk,
input rst,
input HI_LO_write_enableM,
input [31:0] HI_LO_dataM,
input [2:0] MemReadType,
input RegWriteM, 
input MemReadM,
input MemtoRegM,
input MemWriteM,
input [31:0] ALUout,
input [31:0] RamData,
input [5:0] WriteRegister,
input FlushM,
output MemtoRegW,
output RegWriteW,
output HI_LO_write_enableW,
output [31:0] Hi_LO_dataW,
output [31:0] RAMout,
output [31:0] ALUoutW,
output [5:0] WriteRegisterW
    );
wire [31:0] RAMtmp;
reg [3:0] calWE;
reg [31:0] ramout;

RAM readmem(clk,ALUout,calWE,RamData,RAMtmp);
always@(*)
begin
    if (MemReadType[1:0]==2'b00)
    begin
        if (ALUout[1:0]==2'b00)
        begin
            if (MemWriteM==1) calWE[3:0]=4'b1000;
            else calWE[3:0]=4'b0000;
            if (MemReadType[2]==0) ramout={24'b0,RAMtmp[31:24]};
            else ramout={{24{RAMtmp[31]}},RAMtmp[31:24]};
        end
        else if (ALUout[1:0]==2'b01) 
        begin
            if (MemWriteM==1) calWE[3:0]=4'b0100;
            else calWE[3:0]=4'b0000;
            if (MemReadType[2]==0) ramout={24'b0,RAMtmp[23:16]};
            else ramout={{24{RAMtmp[23]}},RAMtmp[23:16]};
        end
        else if (ALUout[1:0]==2'b10)
        begin
            if (MemWriteM==1) calWE[3:0]=4'b0010;
            else calWE[3:0]=4'b0000;
            if (MemReadType[2]==0) ramout={24'b0,RAMtmp[15:8]};
            else ramout={{24{RAMtmp[15]}},RAMtmp[15:8]};
        end
        else if (ALUout[1:0]==2'b11)
        begin
            if (MemWriteM==1) calWE[3:0]=4'b0001;
            else calWE[3:0]=4'b0000;
            if (MemReadType[2]==0) ramout={24'b0,RAMtmp[7:0]};
            else ramout={{24{RAMtmp[7]}},RAMtmp[7:0]};
        end
    end
    else if (MemReadType[1:0]==2'b01)
    begin
        if (ALUout[1:0]==2'b00)
        begin
            if (MemWriteM==1) calWE[3:0]=4'b1100;
            else calWE[3:0]=4'b0000;
            if (MemReadType[2]==0) ramout={16'b0,RAMtmp[31:16]};
            else ramout={{16{RAMtmp[31]}},RAMtmp[31:16]};
        end
        else if (ALUout[1:0]==2'b10)
        begin
            if (MemWriteM==1) calWE[3:0]=4'b0011;
            else calWE[3:0]=4'b0000;
            if (MemReadType[2]==0) ramout={16'b0,RAMtmp[15:0]};
            else ramout={{16{RAMtmp[15]}},RAMtmp[15:0]};
        end
    end
    else if (MemReadType[1:0]==2'b10)
    begin
        if (MemWriteM==1) calWE[3:0]=4'b1111;
        else calWE[3:0]=4'b0000;
    end
end

assign MemtoRegW=MemtoRegM;
assign HI_LO_write_enableW=HI_LO_write_enableM;
assign RegWriteW=RegWriteM;
assign WriteRegisterW=WriteRegister;
assign Hi_LO_dataW=HI_LO_dataM;

endmodule
