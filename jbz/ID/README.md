# ID模块

branch_judge改动：branch_taken在Op为000000时也有效。

控制单元：删除了ALUControl信号，传给ID/EX段间寄存器的RegWriteD由RegWriteBD（来自branch_judge）和RegWriteCD（来自Control Unit）相或后生成。

寄存器堆(register_file)读CP0的端口改为read_addr_2，因为只有MFC0指令需要读CP0寄存器且读取字段为RT。

ID增加输出branch_addr，原jump_addr更改为数据通路中最左边的多选器的第三个端口的信号，branch_addr为上述多选器中第一个端口的信号。

控制单元的控制信号详见control unit signals.xlsx文件，使用了吴钰同的instruction.vh头文件。控制信号可能存在错误，欢迎指出。

修正了一些小错：MemReadType和RS、RD、RT宽度。

添加了新的旁路端口。