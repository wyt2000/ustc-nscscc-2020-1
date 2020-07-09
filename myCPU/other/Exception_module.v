`timescale 1ns / 1ps

/*module Exception_module(
input clk,
input address_error,
input memread,
input overflow_error,
input syscall,
input _break,
input reserved,
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
output reg [4:0] ExcCode//异常编码
    );*/
    
module Exception_module(
input clk,
input address_error,
input MemWrite,
input overflow_error,
input syscall,
input _break,
input reserved,
input isERET,

input [31:0] ErrorAddr,
input [31:0] Branch,
input [31:0] Status,
input [31:0] Cause,
input [31:0] pc,
input [5:0] hardware_abortion,
input [1:0] software_abortion,
input [7:0] Status_IM,
input [31:0] EPCD,
output [7:0] Cause_IP,
output [31:0] BadVAddr,
output [31:0] EPC,
output [31:0] NewPC,
output [31:0] we,
output new_Status_EXL,
output new_Cause_BD1,
output new_Status_IE,
output exception_occur,
output reg [4:0] ExcCode
    );
wire PCError;
assign PCError = (pc[1:0]!=2'b00 | (isERET && EPCD[1:0]!=2'b00)) ? 1 : 0;
wire [31:0] Abortion_access;
assign Abortion_access=32'HBFC00380;
assign NewPC=Abortion_access;

wire Status_EXL;
assign Status_EXL = Status[1];
wire Cause_BD;
assign Cause_BD=Cause[31];
wire Status_IE;
assign Status_IE=Status[0];
//assign ExcCode=Cause[6:2];
//assign EPC=(pc==Branch) ? pc-4:pc;
assign EPC = (PCError && isERET) ? EPCD : pc;//non-Branch_delay
assign exception_occur=(!Status_EXL)
                       &((|(hardware_abortion&&Status_IM))|address_error|overflow_error|syscall|_break|reserved|PCError);

assign we[7:0]=8'h00;
assign we[11:9]=3'b000;
assign we[31:15]=0;
//assign we[8]=(!Status_EXL)&address_error;
/*assign we[12]=(!Status_EXL)
             &((|(hardware_abortion&&Status_IM))|address_error|overflow_error|syscall|_break|reserved);
assign we[13]=(!Status_EXL)
             &((|(hardware_abortion&&Status_IM))|address_error|overflow_error|syscall|_break|reserved);

assign we[14]=(!Status_EXL)
             &((|(hardware_abortion&&Status_IM))|address_error|overflow_error|syscall|_break|reserved);*/
assign we[8]  = (address_error | PCError) ? 1'b1 : 1'b0; //write BadVAddr
assign we[12] = (syscall | _break | overflow_error | address_error | PCError | reserved) ? 1'b1 : 1'b0;
assign we[13] = (syscall | _break | overflow_error | address_error | PCError | reserved) ? 1'b1 : 1'b0;
assign we[14] = (syscall | _break | overflow_error | address_error | PCError | reserved) ? 1'b1 : 1'b0;
assign Cause_IP = (syscall | _break | overflow_error | address_error | PCError | reserved) ? 8'b00000000 : 8'b11111111;
assign new_Status_EXL = (syscall | _break | overflow_error | address_error| PCError | reserved) ? 1'b1 : 1'b0;

assign new_Cause_BD1=(pc==Branch);

//IE的赋值值得商榷
assign new_Status_IE = (syscall | _break | overflow_error | address_error | PCError | reserved) ? 1'b0 : 1'b1;

//中断例外需要再讨论一下

assign BadVAddr = PCError ? (isERET ? EPCD : pc) : ErrorAddr;
//reg [4:0] ExcCodereg;
always@(*)
begin
    if (|(Cause_IP&&Status_IM)) ExcCode=5'b00000;
    else if (PCError) ExcCode=5'b00100;
    else if (reserved) ExcCode=5'b01010;
    else if (overflow_error) ExcCode=5'b01100;
    else if (syscall) ExcCode=5'b01000;
    else if (_break) ExcCode=5'b01001;
    else if (address_error && !MemWrite) ExcCode=5'b00100; //load_ex
    else if (address_error && MemWrite) ExcCode=5'b00101; //store_ex
    //else ExcCode=5'b11111;
end
//assign ExcCode=ExcCodereg;


endmodule