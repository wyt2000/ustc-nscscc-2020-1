#This is about possible Stall situation and the signal that controls stall unit
##Signals control the forwarding unit
Signal name | function | Width| different situations for the signal|Using situation
--|:--:|:--:|:--:
forwardAD| 作为ID段第一个寄存器读端口的旁路| 2 |forwardAD==2'b00，无旁路，取寄存器文件读端口读出的值，forwardAD=2'b01,旁路信号来自EX段ALU计算的结果，forwardAD=2'b10，旁路信号来自Mem段访存得到的信号，forwardAD=2'b11，旁路信号来自Mem段ALU计算结果（空传）|用于数据比较时数据前推
forwardBD|一切和forwardAD相同
forwardAE|作为EX段ALU第一个操作数的旁路选择信号|2|forwardAE=2'b00,无旁路，forwardAE=2'b01,来自Mem段ALUout的旁路信号，forwardAE=2'b10，旁路信号来自Mem段访存得到的信号|用于计算时数据前推
forwardBE|和forwardAE基本相同

##Signals used in the Stall situations
Signal name | function | Width| different situations for the signal|Using situation|in or out
--|:--:|:--:|:--:
StallException|异常处理生成的Stall信号|1|一旦有效1，则所有段间寄存器的写入使能信号均无效|异常停顿|Stall模块输入信号
ClearException|异常处理生成的Clear信号|1|一旦有效1，则将所有流水段寄存器清零信号置为有效|异常清理流水线|Stall模块输入信号