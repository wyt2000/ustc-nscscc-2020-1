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


module MEM_module(
input clk,
input rst,
input HI_LO_write_enableM,
input [31:0] HI_LO_dataM,
input [1:0] MemReadType,
input RegWriteM,
input MemReadM,
input MemtoRegM,
input MemWriteM,
input [31:0] ALUout,
input [31:0] RamData,
input [5:0] WriteRegister,
output MemtoRegW,
output RegWriteW,
output HI_LO_write_enableW,
output [63:0] HI_LO_dataW,
output [31:0] RAMout,
output [31:0] ALUoutW,
output [6:0] WriteRegisterW
    );
wire [31:0] RAMtmp;
reg [3:0] calWE;
reg [31:0] ramout;
RAM_31_24 RAMHI(ALUout[8:2],ALUout[31:24],clk,calWE[3]&MemWriteM,RAMtmp[31:24]);
RAM_23_16 RAMMH(ALUout[8:2],ALUout[31:24],clk,calWE[2]&MemWriteM,RAMtmp[23:16]);
RAM_15_8  RAMML(ALUout[8:2],ALUout[31:24],clk,calWE[1]&MemWriteM,RAMtmp[15:8]);
RAM_7_0   RAMLO(ALUout[8:2],ALUout[31:24],clk,calWE[0]&MemWriteM,RAMtmp[7:0]);

always@(*)
begin
    if (MemReadType[1:0]==2'b00)
    begin
        if (ALUout[1:0]==2'b00)
        begin
            calWE[3:0]=4'b1000;
            if (MemReadType[2]==0) ramout={24'b0,RAMtmp[31:24]};
            else ramout={{24{RAMtmp[31]}},RAMtmp[31:24]};
        end
        else if (ALUout[1:0]==2'b01) 
        begin
            calWE[3:0]=4'b0100;
            if (MemReadType[2]==0) ramout={24'b0,RAMtmp[23:16]};
            else ramout={{24{RAMtmp[23]}},RAMtmp[23:16]};
        end
        else if (ALUout[1:0]==2'b10)
        begin
            calWE[3:0]=4'b0010;
            if (MemReadType[2]==0) ramout={24'b0,RAMtmp[15:8]};
            else ramout={{24{RAMtmp[15]}},RAMtmp[15:8]};
        end
        else if (ALUout[1:0]==2'b11)
        begin
            calWE[3:0]=4'b0001;
            if (MemReadType[2]==0) ramout={24'b0,RAMtmp[7:0]};
            else ramout={{24{RAMtmp[7]}},RAMtmp[7:0]};
        end
    end
    else if (MemReadType[1:0]==2'b01)
    begin
        if (ALUout[1:0]==2'b00)
        begin
            calWE[3:0]=4'b1100;
            if (MemReadType[2]==0) ramout={16'b0,RAMtmp[31:16]};
            else ramout={{16{RAMtmp[31]}},RAMtmp[31:16]};
        end
        else if (ALUout[1:0]==2'b10)
        begin
            calWE[3:0]=4'b0011;
            if (MemReadType[2]==0) ramout={16'b0,RAMtmp[15:0]};
            else ramout={{16{RAMtmp[15]}},RAMtmp[15:0]};
        end
    end
    else if (MemReadType[1:0]==2'b10) calWE[3:0]=4'b1111;
end

assign MemtoRegW=MemtoRegM;
assign HI_LO_write_enableW=HI_LO_write_enableM;
assign RegWriteW=RegWriteM;
assign WriteRegisterW=WriteRegister;
assign Hi_LO_dataW=HI_LO_dataM;

endmodule
