#This is the information of the interface of the WB&&IF module

##The interface of the WB module
The name of the interface| The function && use of the interface| any limitation when using the interface|输出or输入|
--|:--:|:--:|:--:
aluout|ALU计算结果|无时序约束，读出的值即为本指令经过ALU计算所得结果|输入，EX段生成
Memdata|访存结果|这里采用distributed Memory的IP核，因为不涉及cache，不考虑Mem段出现的异常，即为访存结果|输入，Mem段生成
MemtoRegW|写回段写回数据控制| 为1是选择aluout，为0选择Memdata，写回的数据写回寄存器文件|输入，ID段生成
WritetoRFdata|写回的数据|32位|输出，输出到ID段寄存器文件
Exception_Write_addr_sel|选择信号，控制写回寄存器文件的数据的地址是异常处理地址或是正常地址|1选择写回异常处理写的CP0地址，否则写回指令写回的地址，1位|输入信号，异常处理模块生成
Exception_Write_data_sel|选择信号，控制写回寄存器文件的数据，来自异常处理单元或是指令生成|1选择异常处理单元生成的字，否则写回指令要求写回的数，32位|输入，异常处理模块生成
Exception_RF_addr|异常处理模块生成的写寄存器文件端口|7位|输入，异常处理模块生成
Exceptiondata|寄存器文件生成的写CP0字|32位|输入，异常处理模块生成
WriteinRF_HI_LO_data|写回寄存器文件的64位数|直接拼接生成，这里传入的是两位32位数|输出，输出到ID段寄存器文件
HI_LO_writeenablein|HI/LO写使能信号，直接传|1位，1为写有效|输出，输出到ID段寄存器文件
Stall|停顿流水线的信号，因为WB段处理写CP0寄存器需要多个周期，涉及停顿流水线，输出到Harzard检测单元|1位|输入，异常处理模块生成，意味着发现异常，交给Harzard模块处理
clear| 异常处理模块生成的清零流水线信号||输入，异常处理模块生成，出现异常，流水段清零
Stallout|Stall的输出
clearout|clear的输出


##The interface of the IF module
The name of the interface| The function && use of the interface| any limitation when using the interface
--|:--:|:--:
Jump|是否无条件分支跳转|译码单元产生
BranchD|有条件分支|还与分支跳转种类有关，跳转到寄存器或者目标地址
EPC_sel|是否异常恢复指令，取EPC的地址赋给PC
StallF|控制PC写入使能信号，1为写入使能
Jump_reg| 跳转到寄存器的寄存器的值
Instruction| 写入流水段寄存器、从存储器取的指令
PC_add_4|下一条PC，即PC+4

###下一条指令选择信号的说明

{EPC_sel,Jump,BranchD}的值| 输入PC的地址|指令范例
--|:--:|:--:
{1,1,1}|跳转到无条件跳转（非寄存器跳转指令）的目标地址|jump _next
{1,1,0}|跳转到无条件跳转（寄存器跳转指令）的目标地址|jump $(10)
{1,0,1}|跳转到有条件分支地址的目标地址|beq $(t1) $(t2) _next
{1,0,0}|顺序执行
{0,x,x}|异常返回|eret