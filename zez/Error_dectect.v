`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 19:24:35
// Design Name: 
// Module Name: errordetect
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


module errordetect(
input clk,
input address_error,
input memread,
input overflow_error,
input syscall,
input break,
input reversed,
output write_BadVAddr,
output [31:0] BadVAddr,
input [31:0] ADDR,
input [31:0] Branch,
input [31:0] Status,
input [31:0] Cause,
input [31:0] pc,
input [5:0] HW,
output Write_EPC,
output [31:0] EPC,
output [31:0] NewPC,
output Write_Status,
output new_Status_EXL,
output Write_Cause,
output new_Cause_BD1,
output exception_occur,
input [7:0] Cause_IP,
input [7:0] Status_IM,
output WriteExcCode,
output [4:0] ExcCode
    );
wire [31:0] Abortion_access;
assign Abortion_access=32'HBFC00380;
assign NewPC=Abortion_access;

wire Status_EXL;
assign Status_EXL = Status[1];
wire Cause_BD;
assign Cause_BD=Cause[31];
wire Status_IE;
assign Status_IE=Status[0];
assign ExcCode=Cause[6:2];
assign EPC=Cause_BD==1 ? pc-4:pc;

assign exception_occur=(!Status_EXL)
                       &((|(Cause_IP&&Status_IM))|address_error|overflow_error|syscall|break|reversed);
assign Write_EPC=(!Status_EXL)
                       &((|(Cause_IP&&Status_IM))|address_error|overflow_error|syscall|break|reversed);
assign Write_Cause=(!Status_EXL)
                       &((|(Cause_IP&&Status_IM))|address_error|overflow_error|syscall|break|reversed);
assign WriteExcCode=(!Status_EXL)
                       &((|(Cause_IP&&Status_IM))|address_error|overflow_error|syscall|break|reversed);

//assign new_Cause_BD=;

//中断例外需要再讨论一下

assign BadVAddr=ADDR;
reg [4:0] ExcCodereg;
always@(*)
begin
    if (|(Cause_IP&&Status_IM)) ExcCodereg<=5'h00;
    else if (address_error && memread) ExcCodereg<=5'h04;
    else if (reversed) ExcCodereg<=5'h0a;
    else if (overflow_error) ExcCodereg<=5'h0c;
    else if (syscall) ExcCodereg<=5'h08;
    else if (break) ExcCodereg<=5'h09;
    else if (address_error && !memread) ExcCodereg<=5'h05;
end
assign ExcCode=ExcCodereg;
endmodule
