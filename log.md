[toc]

## 7.7

**发现的问题：**

1.分支判断数值不是有符号的

2.分支需要写寄存器时写入的数据错误

3.分支写入的imm_sel寄存器无需分支发生branch_taken

4.JALR指令写入寄存器号错误

5.div指令在ALU发出stall请求时Harzard Unit没有stall

6.FlushE时ID/EX的EPC_sel被清为0，导致PC地址被非预期地址修改，以及div计算出的HILO结果无法被旁路

7.div_control.sv中的div_count在除法执行完后会继续递减，导致后续的除法指令出错

8.load 和 store 的大小尾端反了。

9.SB 和 SH 要求把 Rt 寄存器的低位存到内存地址处，现在是对应位存到该处。

**解决方案：**

1.在ID模块的branch_judge中加上signed声明

2.*修改了instruction.vh中的\`FUNC_BGEZAL和\`FUNC_BLTZAL声明错误

​	*修改了ID段Control Unit中控制ALUSrcA和B的信号，详见控制信号表格

​	*修改了branch_judge中的RegWriteBD信号，在BLTZAL和BGEZAL这两个指令分支不发生时也有效

3.修改了ID段传给EX的Imm_sel_and_branch_taken为Imm_sel

4.修改了控制单元中JALR指令的RegDst信号为1（即选择Rd写入），更新了控制信号表格

5.修改了Harzard Unit的状态机使得其支持div的stall

6.*修改IF.v使EPC_sel为0时候不选EPC；修改Hazard Unit 的状态机使其在div或mul指令后stall IF、ID两周期。

​	*修改了alu.sv中div时hilo的输出，高位32为余数，低32位为商。

7.在div_control.sv中div_count复位处增加判断条件!div_done

8.WB 段选择取数据结果改为后面是 0 ，前面是 3，MEM 段 calWE 做同上修改。

9.MEM 段设置 TrueRamData。

**结果：**

1.通过36号测试点，在41号测试点发生错误

2.通过先前发生错误的地址，在新的地址发生错误，仍未通过41号测试点

3.通过41号测试点，未通过42号测试点

4.通过42号测试点，未通过44号测试点

5.stall成功，但在写入时出错，仍未通过原出错地址

6.通过原出错地址，仍未通过44号测试点

7.爽了，过了58个测试点，第59个没过（LB部分）

8.通过58号测试点，未通过63号测试点

8.通过63号测试点，未通过65号测试点

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