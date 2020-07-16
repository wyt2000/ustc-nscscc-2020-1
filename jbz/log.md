## myCPU修改说明

此目录中的myCPU由重构且上板通过的sram接口的myCPU修改而来，主要修改的地方有以下：

mycpu_top.v：sram端口更换为AXI接口，增加了对cpu_axi_interface.v的调用，添加了MEM/WB存储MemData的段间寄存器，删除了IF/ID段间寄存器.flush中的is_newPC信号，将CPU由EX段执行分支修改回在ID段执行分支

IF和MEM：这两个文件夹下增加了inst_sram.v和data_sram.v，分别由这两个模块发起类sram信号的访存请求，IF.v和MEM.v中增加了对这两个模块的调用，以及添加寄存器来存储访存得到的结果，用来防止被stall后访存得到的结果丢失。

EX.V：添加寄存器存储乘除法运算结果，防止在EX段被stall时访存结果丢失。

Hazard_detection_control.v：修改了stall与flush的控制信号，来保证data_sram和inst_sram同时访存时数据不会丢失。

其余如interface.v上增加了相应的改动；

目前已通过48个测试点。