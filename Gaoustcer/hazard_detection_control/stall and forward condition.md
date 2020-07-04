# This is about the Stall conditions and forwarding conditions in the Hazard_detection_control module

## forwarding condition
forwarding 控制信号名称|取值|转发信号来源|转发到哪一个流水段|转发条件
:--:|:--:|:--:|:--:|:--:
forwardAD|2'b00|Register File读端口1读出数据|ID|default
forwardAD|2'b01|EX段ALU计算结果|ID|EX.writereg==ID.rs
forwardAD|2'b10|没用|ID|没用
forwardAD|2'b11|Mem段ALUout|ID|Mem.writereg==ID.rs&&MemreadM==0 add nop use
forwardBD|2'b00|Register File读端口1读出数据|ID|default
forwardBD|2'b01|EX段ALU计算结果|ID|EX.writereg==ID.rt
forwardBD|2'b10|没用|ID|没用
forwardBD|2'b11|Mem段ALUout|ID|Mem.writereg==ID.rs&&MemreadM==0 add nop use
forwardAE|2'b00|ID_EX段读出数据|EX|default
forwardAE|2'b01|WB段写回数据向EX段转发|EX|WB.writereg==EX.Rs 
forwardAE|2'b10|mem段ALUout|EX|Mem.writereg==EX.Rs && MemreadM==0
forwardBE|2'b00|ID_EX段读出数据|EX|default
forwardBE|2'b01|WB段写回数据向EX段转发|EX|WB.writereg==EX.Rs 
forwardBE|2'b10|mem段ALUout|EX|Mem.writereg==EX.Rs && MemreadM==0

## Stall and clear condition
Stall&&Clean condition|from|Stall cycles
:--:|:--:|:--:
Exception_Stall==1|例外处理模块|1
Exception_clean==1|例外处理模块|段寄存器清零信号
lw+use(条件跳转指令)||2
lw+use（非条件跳转指令||1
