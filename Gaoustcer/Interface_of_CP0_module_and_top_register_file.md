# This is the function of the sealed interface of the original CP0 module
input or output [模块宽度] 封装接口名|功能|在顶层寄存器文件中是否被用到（与例外处理模块连接），如果不连接，则置为0|与顶层寄存器文件端口连接
--|:--:|:--:|:--:
input [4:0] waddr|输入端口，用于一般对于CP0寄存器文件一次写一个数据的情形|用到|write_addr，在写地址在CP0地址空间时相连，写使能字为0
input clk|时钟，其余略
input rst|复位，其余略
input [WIDTH-1:0] writedata|写入的数据，用于CP0寄存器文件一次写一个寄存器的情况|用到|write_data，写的时候要求写使能字为0，写地址在CP0地址空间
input [4:0] raddr|读端口|用到|读出数据，异步读|与RF读端口相连
input [5:0] hardware_interruption|硬件中断，直接来自硬件|用到|与顶层hardware_interruption相连
input [1:0] software_interruption|软件中断，软件可见|用到|顶层software_interruption相连
input [WIDTH-1:0] we|写使能字，中断或者例外模式，写多个寄存器|用到|与顶层we相连
input general_write_in|单个写使能，单个写优先级不如写多个|用到|顶层write_enable端口
input [WIDTH-1:0] BADADDR|写入地址错异常PC值|用到|顶层BADADDR端口相连
input [WIDTH-1:0] comparedata||无用
input [WIDTH-1:0] configuredata||无用
input [WIDTH-1:0] epc|错误指令恢复地址|用到|顶层epc端口相连
input [WIDTH-1:0] pridin||无用|
input [7:0] interrupt_enable|中断使能，Status寄存器中8位中断使能位|有用|与顶层interrupt_enable端口连接
input EXL|Status寄存器的EXL位置位信号|处理器状态标志位，1代表例外态，0代表正常态|用到|与顶层模块exception_occur连接
input IE||无用
input Branch_delay|异常指令是否在延迟操槽里，控制cause寄存器最高位|有用|与顶层模块Branch_delay相连
input [4:0] Exception_code|例外代码，控制Cause寄存器ExcCode位|有用|与顶层模块ExcCode相连
output [WIDTH-1:0] readdata|无条件读端口，读寄存器的值
output [WIDTH-1:0] count_data|无条件读端口，读寄存器的值
output [WIDTH-1:0] compare_data|无条件读端口，读寄存器的值
output [WIDTH-1:0] Status_data|无条件读端口，读寄存器的值|有用|输出状态寄存器的值，与Status_data相连
output [WIDTH-1:0] cause_data|无条件读端口，读寄存器的值|有用|输出状态寄存器的值，与cause_data相连
output [WIDTH-1:0] EPC_data|无条件读端口，读寄存器的值|有用|输出端口，与输出EPC相连
output [WIDTH-1:0] configure_data|无条件读端口，读寄存器的值
output [WIDTH-1:0] prid_data|无条件读端口，读寄存器的值
output [WIDTH-1:0] BADVADDR_data|无条件读端口，读寄存器的值
output [WIDTH-1:0] Ramdom_data|无条件读端口，读寄存器的值
output timer_int_data|定时中断，读端口
output allow_interrupt|中断允许，读端口
output state|处理器状态，读端口

*注意epc是输入而EPC是输出，WIDTH=32*

# This is about the function of the interface of the top_register_file module（added interface）
name of the interface|Read or Write|function of the interface|与封装CP0接口的联系|与Error_detect模块接口关系
--|:--:|:--:|:--:|:--:
Status_data|Read|读出Status寄存器的值|与Status_data相连|作为Error模块的输入Status
EPC_data|Read|读出EPC寄存器的值|与EPC_data相连|无关系，作为PC寄存器下一个值（eret）
cause_data|Read|读出cause寄存器的值|与cause_data相连|作为Error模块的输入cause
we|Write|写使能字|与we相连|对应封装CP0寄存器的写使能字|来自Error模块，写使能字we
interrupt_enable|Write|中断使能|对应CP0寄存器的中断使能信号|来自Error模块的输出Status_IM,设置中断屏蔽
Exception_code|Write|例外编码|对应CP0寄存器输入的中断编码|来自Error模块的输出ExcCode
EXL|Write|处理器状态标识位|对应CP0中置处理器状态位EXL输入|来自Error模块输出exception_occur
hardware_interruption|Write|硬件中断|对应CP0中硬件中断接口hardware_interruption|来自Error模块Cause_IP[7:2]
software_interruption|Write|软件中断|对应CP0中软件中断接口software_interruption|来自Error模块Cause_IP[1:0]
epc|Write|异常地址|对应CP0输入epc|来自Error模块EPC
----
**设计的top_CP0说明：**
**有两种写模式，当写多个无效的时候采用写单个寄存器，写多个需要给多个写信号，这里为了扩展，写信号端口比需要的多一些，此时可以将这些多出的写端口全部置为0**
**写单个只要给出一个写入到CP0的字和写地址（5位），这里共用通用写端口**
**特殊地，这里IE置为1**