`timescale 1ns / 1ps

module MEM_module (
input clk,
input rst,
input HI_LO_write_enableM,
input [63:0] HI_LO_dataM,
input [2:0] MemReadType,
input RegWriteM, 
input MemReadM,
input MemtoRegM,
input MemWriteM,
input [31:0] ALUout,
input [31:0] RamData,
input [6:0] WriteRegister,
input [31:0] PCin,
output MemtoRegW,
output RegWriteW,
output HI_LO_write_enableW,
output [63:0] HI_LO_dataW,
output [31:0] ALUoutW,
output [6:0] WriteRegisterW,
output reg [3:0] calWE,
output [31:0] PCout,
output [2:0] MemReadTypeW
    );

always@(*)
begin
    calWE = 0;
    if (MemReadType[1:0]==2'b00)
    begin
        if (ALUout[1:0]==2'b00)
        begin
            if (MemWriteM==1) calWE[3:0]=4'b1000;
            else calWE[3:0]=4'b0000;
        end
        else if (ALUout[1:0]==2'b01) 
        begin
            if (MemWriteM==1) calWE[3:0]=4'b0100;
            else calWE[3:0]=4'b0000;
        end
        else if (ALUout[1:0]==2'b10)
        begin
            if (MemWriteM==1) calWE[3:0]=4'b0010;
            else calWE[3:0]=4'b0000;
        end
        else if (ALUout[1:0]==2'b11)
        begin
            if (MemWriteM==1) calWE[3:0]=4'b0001;
            else calWE[3:0]=4'b0000;
        end
    end
    else if (MemReadType[1:0]==2'b01)
    begin
        if (ALUout[1:0]==2'b00)
        begin
            if (MemWriteM==1) calWE[3:0]=4'b1100;
            else calWE[3:0]=4'b0000;
        end
        else if (ALUout[1:0]==2'b10)
        begin
            if (MemWriteM==1) calWE[3:0]=4'b0011;
            else calWE[3:0]=4'b0000;
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
assign HI_LO_dataW=HI_LO_dataM;
assign PCout = PCin;
assign ALUoutW = ALUout;
assign MemReadTypeW = MemReadType;

endmodule
