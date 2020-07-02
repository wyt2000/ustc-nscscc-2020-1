## This is the information of the interface of Error_detect module
The name of the interface|function|from|come to|
--|:--:|:--:|:--:
input clk|时钟信号|来自外部|
input address_error|地址错|来自EX?|
input memread|访存|EX？|这个接口可能用不上，可以置为0
input overflow_error|溢出错|EX|
input syscall|系统调用异常|ID|
input break|Break指令|ID|
input reversed|无效指令|ID|
input [5:0] hardware_abortion|硬件中断|外部中断|
input [1:0] software_abortion|软件中断|外部中断|
input [31:0] Status|Status寄存器当前的值|CP0寄存器（封装寄存器输出）Status_data|
input [31:0] Cause|Cause寄存器当前的值|CP0寄存器cause_data|
input [31:0] pc|错误指令pc|PC寄存器|
output [31:0] BadVAddr|输出置BadVaddr||寄存器文件端口BADADDR
output [31:0] EPC|输出置EPC||寄存器文件的epc输入端口
output [31:0] NewPC|PC跳转||二选一选择器的选择信号
output [31:0] we|写使能字||寄存器文件的写使能字输入we
output new_Cause_BD1|给cause寄存器赋新值||寄存器问价输入端口Branch_delay
output exception_occur|异常发生（Stall，Clear）||这个端口比较特别，它可以输出到多个端口，包括：PC赋值的选择信号、Harzard单元的Exception_Stall和Exception_Clear端口，作为段间寄存器清零以及Stall流水线的信号
output new_Status_EXL|给Status寄存器赋新值||寄存器文件的EXL输入
output new_Status_IE|给Status寄存器赋新值||涉及中断使能，暂时没用
output [7:0] Cause_IP|给cause寄存器赋新值||寄存器文件输入端口interrupt_enable
output [7:0] Status_IM|给Status寄存器赋新值||寄存器文件输入端口,[7:2]对应hardware_interruption,[1:0]对应软件中断software_interruption
output [4:0] ExcCode|异常编码||对应寄存器文件输入端口Exception_code