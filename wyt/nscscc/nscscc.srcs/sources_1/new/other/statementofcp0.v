//cp0.v源代码是协处理器cp0的设计代码，它由9个寄存器构成，包括 add为相应寄存器在RF中的编号（地址）
//EPC：上次异常PC地址 add=14
//BadAddr：地址异常的地址，包括TLB缺页，cache miss，地址不是合法地址，例如访问OS或者地址溢出 add=8
//count：计数器，由于产生随机数，两个周期计数器+1 add=9
//Status：寄存器状态寄存器，用于保存寄存器当前状态：比如8个中断使能，以及全局中断使能，还有协处理器数目 add=12
//configure：配置寄存器，用于存放寄存器配置信息，如大小端、处理器架构、字长等信息 add=16
//prid：处理器型号、生产商、版本等出厂设置信息 add=15
//compare：由于产生定时中断，与count配合产生定时中断 add=11
//Ramdom：产生随机数 add=1
//cause：存储异常发生原因，如异常指令是否位于延迟槽内，软硬件中断编号，异常种类等 add=13

//接口说明
module CP0
    #(parameter WIDTH=32)
(
        input clk,rst,
        input [5:0] hardware_interruption,//6 hardware break
        input [1:0] software_interruption,//2 software interruption
        input we,//write enable signal
        input [4:0] waddr,//write address of CP0
        input [WIDTH-1:0] BADADDR,//the virtual address that has mistakes
        input [WIDTH-1:0] comparedata,//the data write to the compare
        input [WIDTH-1:0] configuredata,
        input [WIDTH-1:0] epc,
        input [WIDTH-1:0] pridin,
        input [7:0] interrupt_enable;
        input EXL,
        input IE,
        input Branch_delay,
        input [4:0] Exception_code,
        output [WIDTH-1:0] count_data,
        output [WIDTH-1:0] compare_data,
        output [WIDTH-1:0] Status_data,
        output [WIDTH-1:0] cause_data,
        output [WIDTH-1:0] EPC_data,
        output [WIDTH-1:0] configure_data,
        output [WIDTH-1:0] prid_data,
        output [WIDTH-1:0] BADVADDR_data,
        output [WIDTH-1:0] Ramdom_data,
        output timer_int_data,//when compare==count, create a break
        output allow_interrupt,
        output state//user mode:0 kernel mode:1


);
//pridin,configuredata,comparedata,BADADDR,epc是相应寄存器单独的输入
//timer_int_data为时钟中断，1代表时钟中断有效
//state为处理器状态输出，0为普通态，1为用户态
//allow_interrupt为全局中断使能信号，1代表全局中断使能，0为全局中断屏蔽
//we为写使能信号，为1时可以向寄存器写入值，写入到waddr地址的寄存器中
//Branch_delay是否处于分支延迟槽，位于则置1
//EXL处于异常级则置为1，否则为0
//IE全局中断使能为1
//interrupt_enable八个中断使能信号0表示屏蔽中断，1表示不屏蔽中断
//以上4个信号均为Status输入信号
//hardware/software_interrupt硬件、软件中断触发信号，用于触发某个中断，在一定条件下中断触发
//以上软硬件中断信号为Cause输入信号
