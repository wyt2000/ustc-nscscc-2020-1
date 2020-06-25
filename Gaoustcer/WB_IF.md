#This is the information of the interface of the WB&&IF module

##The interface of the WB module
The name of the interface| The function && use of the interface| any limitation when using the interface
--|:--:|:--:
aluout|ALU计算结果|无时序约束，读出的值即为本指令经过ALU计算所得结果
Memdata|访存结果|这里采用distributed Memory的IP核，因为不涉及cache，不考虑Mem段出现的异常，即为访存结果
MemtoRegW|写回段写回数据控制| 为1是选择aluout，为0选择Memdata，写回的数据写回寄存器文件
WritetoRFdata|写回的数据|32位

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