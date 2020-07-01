module errordetect(
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
