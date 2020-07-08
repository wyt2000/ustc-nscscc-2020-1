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
output [2:0] MemReadTypeW,
output reg [31:0] TrueRamData,
//syscall
input syscallin,
output syscallout,
//break
input _breakin,
output _breakout,
//exception
input [2:0] exception_in,
output [2:0] exception_out,
output MemWriteW
    );

always@(*)
begin
    calWE = 0;
    TrueRamData = 0;
    if (exception_in != 0 || PCin[1:0] != 2'b00) calWE = 0;
    else if (MemReadType[1:0]==2'b00)
    begin
        if (ALUout[1:0]==2'b00)
        begin
            if (MemWriteM==1) begin
                calWE[3:0] = 4'b0001;
                TrueRamData[7:0] = RamData[7:0];
            end
            else calWE[3:0]=4'b0000;
        end
        else if (ALUout[1:0]==2'b01) 
        begin
            if (MemWriteM==1) begin
                calWE[3:0] = 4'b0010;
                TrueRamData[15:8] = RamData[7:0];
            end
            else calWE[3:0]=4'b0000;
        end
        else if (ALUout[1:0]==2'b10)
        begin
            if (MemWriteM==1) begin
                calWE[3:0] = 4'b0100;
                TrueRamData[23:16] = RamData[7:0];
            end
            else calWE[3:0]=4'b0000;
        end
        else if (ALUout[1:0]==2'b11)
        begin
            if (MemWriteM==1) begin
                calWE[3:0] = 4'b1000;
                TrueRamData[31:24] = RamData[7:0];
            end
            else calWE[3:0]=4'b0000;
        end
    end
    else if (MemReadType[1:0]==2'b01)
    begin
        if (ALUout[1:0]==2'b00)
        begin
            if (MemWriteM==1) begin
                calWE[3:0]=4'b0011;
                TrueRamData[15:0] = RamData[15:0];
            end 
            else calWE[3:0]=4'b0000;
        end
        else if (ALUout[1:0]==2'b10)
        begin
            if (MemWriteM==1) begin
                calWE[3:0]=4'b1100;
                TrueRamData[31:16] = RamData[15:0];
            end
            else calWE[3:0]=4'b0000;
        end
    end
    else if (MemReadType[1:0]==2'b10)
    begin
        if (MemWriteM==1) begin
            calWE[3:0]=4'b1111;
            TrueRamData = RamData;
        end
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
assign syscallout = syscallin;
assign _breakout = _breakin;
assign exception_out = exception_in;
assign MemWriteW = MemWriteM;

endmodule
