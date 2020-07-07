[toc]

## 7.6

### jbz

发现的问题：

1.当EX段需要WB段旁路过来的数据，并且EX和MEM段将被stall，WB段继续执行时，下个周期旁路的数据会丢失，使得EX段的数据不是最新的。

2.IF,ID同时被stall时，从指令ram中取出的指令会被后一条覆盖。

解决方法：

1.在harzard unit的ForwardAD和ForwardBD判断逻辑上删除了isaBranchInstruction，使非分支指令能在ID段获得来自MEM段旁路的信号。

2.在IF模块中增加输出is_newPC，该信号表示当前的PC的值与上一个PC是否相同，不相同为1。IF/ID段间寄存器的Flush使能由Hazard.FlushD | ID.CLR_EN改为Hazard.FlushD | ID.CLR_EN | IF.is_newPC，使段间寄存器在PC为刚改变的值时不接收instr RAM的数据。PC的stall使能信号改为IF.StallF | (IF.is_newPC && ID.EPC_sel && !ID.Jump && !ID.BranchD)，即当ID段不需要跳转且PC为刚刚改变的值时stall，使PC的值维持一个周期不变。

### wyt

延迟槽内的指令需要执行，但是由于取指改成两个周期了，跳转地址写回 PC 的时候恰好是上一条指令应该被取出来的那个周期，这样会导致时序混乱，过不了 trace 。

解决方案：把 ID 段分支的结果空传到 EX 段。

合并了目前的代码。

现在任意两条指令之间都含有一个 nop ，所以 Hazard 单元中只需考虑 branch 指令在 ID 段，lw 指令在 MEM 段的 stall 一个周期。