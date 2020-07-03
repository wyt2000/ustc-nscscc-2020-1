`timescale 1ns / 1ps


module Exception_module(
input clk,
input address_error,
input memread,
input overflow_error,
input syscall,
input break,
input reversed,
input [5:0] hardware_abortion,//硬件中断
input [1:0] software_abortion,//软件中断
input [31:0] Status,//Status寄存器当前的值
input [31:0] Cause,//Cause寄存器当前的值
input [31:0] pc,//错误指令pc
output [31:0] BadVAddr,//输出置BadVaddr
output [31:0] EPC,//输出置EPC
output [31:0] NewPC,//PC跳转
output [31:0] we,//写使能字
output new_Cause_BD1,//给cause寄存器赋新值
output exception_occur,//异常发生（Stall，Clear）
output new_Status_EXL,//给Status寄存器赋新值
output new_Status_IE,//给Status寄存器赋新值
output [7:0] Cause_IP,//给cause寄存器赋新值
output [7:0] Status_IM,//给Status寄存器赋新值
output [4:0] ExcCode//异常编码
    );
    assign we=0;
    wire [31:0] Abortion_access;
    assign Abortion_access=32'HBFC00380;
    assign NewPC=Abortion_access;
    assign new_Status_IE=1'b1;
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