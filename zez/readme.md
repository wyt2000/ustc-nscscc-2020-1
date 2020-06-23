在MEM段的使能信号的注解：
MemRead：当进行LB，LBH，LH，LHU，LW时为1，其他指令时为0。
MemWrite：当进行SB，SH，SW时为1，其他指令时为0。
MemReadType：对于读取不同长度和不同位扩展的指令将赋予不同的值。
对应表如下：
LB：100
LBU:000
LH: 101
LHU:001
LW: 010
SB: 000
SH: 001
SW: 010
