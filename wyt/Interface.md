# IF 段

### 输入部分
|  变量名   |  位宽  |            功能             |  来自  |
| :-------: | :----: | :-------------------------: | :----: |
|    clk    |   1    |          全局时钟           |  全局  |
|    rst    |   1    |          全局复位           |  全局  |
|   Jump    |   1    |        Jump 是否成功        |   ID   |
|  BranchD  |   1    |       Branch 是否成功       |   ID   |
|  EPC_sel  |   1    |     选择 PC 是否为 EPC      |   ID   |
|    EPC    | [31:0] |       作为 NPC 的 EPC       |   ID   |
| Jump_reg  | [31:0] |      作为 NPC 的 Rs 值      |   ID   |
| Jump_addr | [31:0] |  作为 NPC 的 Jump 跳转地址  |   ID   |
| beq_addr  | [31:0] | 作为 NPC 的 Branch 跳转地址 |   ID   |
|  StallF   |   1    |     是否暂停取下一个 PC     | Hazard |

### 输出部分


|   变量名    |  位宽  |   功能   |    来自    | 去往  |
| :---------: | :----: | :------: | :--------: | :---: |
| Instruction | [31:0] | 完整指令 | 指令存储器 | IF/ID |
|  PC_add_4   | [31:0] |   PC+4   | PC 寄存器  | IF/ID |

# IF/ID 段间寄存器

|    来自     |   去往    |  位宽  |
| :---------: | :-------: | :----: |
| Instruction |   instr   | [31:0] |
|  PC_add_4   | pc_plus_4 | [31:0] |

# ID 段

### 输入部分

|           变量名           |  位宽  |             功能             |  来自  |
| :------------------------: | :----: | :--------------------------: | :----: |
|            clk             |   1    |           全局时钟           |  全局  |
|            rst             |   1    |           全局复位           |  全局  |
|           instr            | [31:0] |         ID 段的指令          | IF/ID  |
|         pc_plus_4          | [31:0] |         ID 段的 PC+4         | IF/ID  |
|         RegWriteW          |   1    |   WB 段是否要写通用寄存器    |   WB   |
|         WriteRegW          | [6:0]  |  WB 段要写回的通用寄存器号   |   WB   |
|          ResultW           | [31:0] |  WB 段要写回的通用寄存器值   |   WB   |
| HI_LO_write_enable_from_WB |   1    |  WB 段是否要写 HILO 寄存器   |   WB   |
|         HI_LO_data         | [63:0] | WB 段要写回的 HILO 寄存器值  |   WB   |
|          ALUoutE           | [31:0] |       来自 EX 段的旁路       |   EX   |
|          ALUoutM           | [31:0] |  来自 MEM 段的计算结果旁路   |  MEM   |
|          RAMoutM           | [31:0] | 来自 MEM 段的 RAM 读数据旁路 |  MEM   |
|         ForwardAD          | [1:0]  |      选 RsValue 的旁路       | Hazard |
|         ForwardBD          | [1:0]  |      选 RtValue 的旁路       | Hazard |

### 输出部分

|          变量名          |  位宽  |                 功能                  |  去往  |
| :----------------------: | :----: | :-----------------------------------: | :----: |
|          ALUOp           | [5:0]  |      decoder 算出的 ALUOp（EX）       | ID/EX  |
|         ALUSrcDA         |   1    |     空传选 a 是 A 或立即数（EX）      | ID/EX  |
|         ALUSrcDB         |   1    |     空传选 b 是 B 或立即数（EX）      | ID/EX  |
|         RegDstD          |   1    |       空传选写回 Rt 或 Rd（EX）       | ID/EX  |
|         MemReadD         |   1    |            空传 mem 读使能            | ID/EX  |
|       MemReadType        | [1:0]  |            空传 mem 读选择            | ID/EX  |
|        MemWriteD         |   1    |            空传 mem 写使能            | ID/EX  |
|        MemtoRegD         |   1    |             空传写回选择              | ID/EX  |
|   HI_LO_write_enableD    |   1    |        空传 HILO 寄存器写使能         | ID/EX  |
|        RegWriteD         |   1    |         空传通用寄存器写使能          | ID/EX  |
| Imm_sel_and_Branch_taken |   1    |    这是一条成功跳转的跳转链接指令     | ID/EX  |
|         RsValue          | [31:0] |                Rs 的值                | ID/EX  |
|         RtValue          | [31:0] |                Rt 的值                | ID/EX  |
|        pc_plus_8         | [31:0] |            到 ID 段的 PC+8            | ID/EX  |
|            Rs            | [6:0]  |             Rs 的寄存器号             | ID/EX  |
|            Rt            | [6:0]  |             Rt 的寄存器号             | ID/EX  |
|            Rd            | [6:0]  |             Rd 的寄存器号             | ID/EX  |
|           imm            | [15:0] |          0 扩展的 ins[15:0]           | ID/EX  |
|         EPC_sel          |   1    |          选择 PC 是否为 EPC           |   IF   |
|         BranchD          |   1    |            Branch 是否成功            |   IF   |
|           Jump           |   1    |             Jump 是否成功             |   IF   |
|        PCSrc_reg         | [31:0] |      传回 IF 段作为 NPC 的 Rs 值      |   IF   |
|           EPC            | [31:0] |       传回 IF 段作为 NPC 的EPC        |   IF   |
|        Jump_addr         | [31:0] |  传回 IF 段作为 NPC 的 Jump 跳转地址  |   IF   |
|       Branch_addr        | [31:0] | 传回 IF 段作为 NPC 的 Branch 跳转地址 |   IF   |
|          CLR_EN          |   1    |         清空 IF/ID 段间寄存器         | IF/ID  |
|        exception         |   1    |             指令是否无效              | Hazard |

# ID/EX 段间寄存器

|           来自           |     去往      |    位宽    |
| :----------------------: | :-----------: | :--------: |
|          ALUOp           |  ALUControl   |   [5:0]    |
|         ALUSrcDA         |    ALUSrcA    |     1      |
|         ALUSrcDB         |    ALUSrcB    |     1      |
|         RegDstD          |    RegDst     |     1      |
|         MemReadD         |   MemRead_i   |     1      |
|       MemReadType        | MemReadType_i |   [1:0]    |
|        MemWriteD         |  MemWrite_i   |     1      |
|        MemtoRegD         |  MemtoReg_i   |     1      |
|   HI_LO_write_enableD    |  hiloWrite_i  |     1      |
|        RegWriteD         |  RegWrite_i   |     1      |
| Imm_sel_and_Branch_taken |    ImmSel     |     1      |
|         RsValue          |       A       |   [31:0]   |
|         RtValue          |       B       |   [31:0]   |
|        pc_plus_8         |    PCplus8    |   [31:0]   |
|            Rt            |      Rt       |   [6:0]    |
|            Rd            |      Rd       |   [6:0]    |
|         **imm**          |    **Imm**    | **[31:0]** |

*零扩展

# EX 段

### 输入部分

|    变量名     |  位宽  |          功能          |  来自  |
| :-----------: | :----: | :--------------------: | :----: |
|      clk      |   1    |        全局时钟        |  全局  |
|      rst      |   1    |        全局复位        |  全局  |
|  hiloWrite_i  |   1    |    空传 HILO 写使能    | ID/EX  |
| MemReadType_i | [1:0]  |    空传 mem 读选择     | ID/EX  |
|   MemRead_i   |   1    |    空传 mem 读使能     | ID/EX  |
|  RegWrite_i   |   1    |   空传寄存器堆写使能   | ID/EX  |
|  MemtoReg_i   |   1    |      空传写回选择      | ID/EX  |
|  MemWrite_i   |   1    |    空传 mem 写使能     | ID/EX  |
|  ALUControl   | [5:0]  |         ALUop          | ID/EX  |
|    ALUSrcA    |   1    |   选 a 是 A 或立即数   | ID/EX  |
|    ALUSrcB    |   1    |   选 b 是 B 或立即数   | ID/EX  |
|    RegDst     |   1    |    选写回 Rt 或 Rd     | ID/EX  |
|    ImmSel     |   1    | 选立即数是 PC+8 或 Imm | ID/EX  |
|       A       | [31:0] |       Rs 的内容        | ID/EX  |
|       B       | [31:0] |       Rt 的内容        | ID/EX  |
|    PCplus8    | [31:0] |          PC+8          | ID/EX  |
|      Rt       | [6:0]  |     Rt 的寄存器号      | ID/EX  |
|      Rd       | [6:0]  |     Rd 的寄存器号      | ID/EX  |
|      Imm      | [31:0] |   0 扩展的 ins[15:0]   | ID/EX  |
|  ForwardMEM   | [31:0] |   来自 MEM 段的旁路    |  MEM   |
|   ForwardWB   | [31:0] |    来自 WB 段的旁路    |   WB   |
|   ForwardA    | [1:0]  |      选 A 的旁路       | Hazard |
|   ForwardB    | [1:0]  |      选 B 的旁路       | Hazard |

### 输出部分

|    变量名     |  位宽  |            功能             |  去往  |
| :-----------: | :----: | :-------------------------: | :----: |
|  hiloWrite_o  |   1    |      空传 HILO 写使能       | EX/MEM |
| MemReadType_o | [1:0]  |       空传 mem 读选择       | EX/MEM |
|   MemRead_o   |   1    |       空传 mem 读使能       | EX/MEM |
|  RegWrite_o   |   1    |     空传寄存器堆写使能      | EX/MEM |
|  MemtoReg_o   |   1    |        空传写回选择         | EX/MEM |
|  MemWrite_o   |   1    |       空传 mem 写使能       | EX/MEM |
|   hiloData    | [63:0] |       乘除法计算结果        | EX/MEM |
|   ALUResult   | [31:0] | 其他运算结果或 mem 读写地址 | EX/MEM |
|    MemData    | [31:0] |         mem 写数据          | EX/MEM |
| WriteRegister | [6:0]  |       写回的寄存器号        | EX/MEM |
|     done      |   1    |        是否算出结果         | Hazard |
|   exception   | [2:0]  |            异常             | Hazard |
|     stall     |   1    |       是否暂停流水线        | Hazard |

# EX/MEM 段间寄存器

|     来自      |        去往         |  位宽  |
| :-----------: | :-----------------: | :----: |
|  hiloWrite_o  | HI_LO_write_enableM |   1    |
| MemReadType_o |     MemReadType     | [1:0]  |
|   MemRead_o   |      MemReadM       |   1    |
|  RegWrite_o   |      RegWriteM      |   1    |
|  MemtoReg_o   |      MemtoRegM      |   1    |
|  MemWrite_o   |      MemWriteM      |   1    |
|   hiloData    |     HI_LO_dataM     | [63:0] |
|   ALUResult   |       ALUout        | [31:0] |
|    MemData    |       RamData       | [31:0] |
| WriteRegister |    WriteRegister    | [6:0]  |

# MEM 段

### 输入部分

|       变量名        |  位宽  |              功能               |  来自  |
| :-----------------: | :----: | :-----------------------------: | :----: |
|         clk         |   1    |            全局时钟             |  全局  |
|         rst         |   1    |            全局复位             |  全局  |
| HI_LO_write_enableM |   1    |        空传 HILO 写使能         | EX/MEM |
|     HI_LO_dataM     | [63:0] |       空传乘除法运算结果        | EX/MEM |
|      MemtoRegM      |   1    |          空传写回选择           | EX/MEM |
|      RegWriteM      |   1    |       空传寄存器堆写使能        | EX/MEM |
|       ALUout        | [31:0] | 空传其他运算结果或 mem 读写地址 | EX/MEM |
|    WriteRegister    | [6:0]  |        空传写回寄存器号         | EX/MEM |
|     MemReadType     | [1:0]  |           mem 读选择            | EX/MEM |
|      MemReadM       |   1    |           mem 读使能            | EX/MEM |
|      MemWriteM      |   1    |           mem 写使能            | EX/MEM |
|       RamData       | [31:0] |           mem 写数据            | EX/MEM |

### 输出部分

|       变量名        |  位宽  |        功能        |  去往  |
| :-----------------: | :----: | :----------------: | :----: |
|      MemtoRegW      |   1    |    空传写回选择    | MEM/WB |
|      RegWriteW      |   1    | 空传寄存器堆写使能 | MEM/WB |
| HI_LO_write_enableW |   1    |  空传 HILO 写使能  | MEM/WB |
|     HI_LO_dataW     | [63:0] | 空传乘除法计算结果 | MEM/WB |
|       RAMout        | [31:0] |     RAM 读结果     | MEM/WB |
|       ALUoutW       | [31:0] |  空传其他计算结果  | MEM/WB |
|   WriteRegisterW    | [6:0]  |  空传写回寄存器号  | MEM/WB |

# MEM/WB 段间寄存器

|        来自         |        去往         |  位宽  |
| :-----------------: | :-----------------: | :----: |
|      MemtoRegW      |      MemtoRegW      |   1    |
|      RegWriteW      |      RegWriteW      |   1    |
| HI_LO_write_enableW | HI_LO_writeenablein |   1    |
|     HI_LO_dataW     |      HILO_data      | [63:0] |
|       RAMout        |       Memdata       | [31:0] |
|       ALUoutW       |       aluout        | [31:0] |
|   WriteRegisterW    |   WritetoRFaddrin   | [6:0]  |

# WB 段

### 输入部分

|    变量名     |  位宽  |          功能          |  来自  |
| :-----------: | :----: | :--------------------: | :----: |
| aluout | [31:0] | ALU 计算结果 | MEM/WB |
| Memdata | [31:0] | mem 读取结果 | MEM/WB |
| MemtoRegW | 1 | 写回选择 | MEM/WB |
| RegWriteW | 1 | 寄存器堆写使能 | MEM/WB |
| WritetoRFaddrin | [6:0] | 空传写回通用寄存器号 | MEM/WB |
| HILO_data | [63:0] | 写回 HILO 寄存器的值 | MEM/WB |
| Exception_Write_addr_sel | 1 | 1选择写回异常处理写的CP0地址，否则写回指令写回的地址 | Hazard |
| Exception_Write_data_sel | 1 | 1选择异常处理单元生成的字，否则写回指令要求写回的数 | Hazard |
| Exception_RF_addr | [6:0] | 异常处理模块生成的写寄存器文件端口 | Hazard |
| Exceptiondata | [31:0] | 寄存器文件生成的写CP0字 | Hazard |
| Exception_RF_addr | [6:0] | 异常处理模块生成的写寄存器文件端口 | Hazard |

### 输出部分


|        变量名        |  位宽  |          功能          | 去往 |
| :------------------: | :----: | :--------------------: | :--: |
|   WritetoRFaddrout   | [6:0]  |  空传写回通用寄存器号  |  ID  |
|    WritetoRFdata     | [31:0] | 空传写回通用寄存器的值 |  ID  |
| HI_LO_writeenablein  |   1    |      HILO 写使能       |  ID  |
| WriteinRF_HI_LO_data | [63:0] |  写回 HILO 寄存器的值  |  ID  |
|       RegWrite       |   1    |     寄存器堆写使能     |  ID  |

# Hazard

### 输入部分

|  变量名   | 位宽  |              功能               | 来自 |
| :-------: | :---: | :-----------------------------: | :--: |
|  BranchD  |   1   |         Branch 是否成功         |  ID  |
|    RsD    | [6:0] |       ID 段的 Rs 寄存器号       |  ID  |
|    RtD    | [6:0] |       ID 段的 Rt 寄存器号       |  ID  |
|    RsE    | [6:0] |       EX 段的 Rs 寄存器号       |  EX  |
|    RtE    | [6:0] |       EX 段的 Rt 寄存器号       |  EX  |
| MemReadE  |   1   |       EX 段指令是否读 mem       |  EX  |
| MemtoRegE |   1   | EX 段指令是否将 mem 写回寄存器  |  EX  |
| RegWriteM |   1   |   MEM 段指令是否要写回寄存器    | MEM  |
| WriteRegM | [6:0] |    MEM 段指令的写回寄存器号     | MEM  |
| MemReadM  |   1   |      MEM 段指令是否读 mem       | MEM  |
| MemtoRegM |   1   | MEM 段指令是否将 mem 写回寄存器 | MEM  |
| RegWriteW |   1   |    WB 段指令是否要写回寄存器    |  WB  |
| WriteRegW | [6:0] |     WB 段指令的写回寄存器号     |  WB  |

### 输出部分


|  变量名   | 位宽  |          功能          |  去往  |
| :-------: | :---: | :--------------------: | :----: |
|  StallF   |   1   |   关闭 PC 寄存器使能   |   IF   |
|  StallD   |   1   | 关闭 IF/ID 寄存器使能  | IF/ID  |
|  StallE   |   1   | 关闭 ID/EX 寄存器使能  | ID/EX  |
|  StallM   |   1   | 关闭 EX/MEM 寄存器使能 | EX/MEM |
|  StallW   |   1   | 关闭 MEM/WB 寄存器使能 | MEM/WB |
|  FlushD   |   1   |   清空 IF/ID 寄存器    | IF/ID  |
|  FlushE   |   1   |   清空 ID/EX 寄存器    | ID/EX  |
|  FlushM   |   1   |   清空 EX/MEM 寄存器   | EX/MEM |
|  FlushW   |   1   |   清空 MEM/WB 寄存器   | MEM/WB |
| ForwardAD | [1:0] |   选 ID 段 A 的旁路    |   ID   |
| ForwardBD | [1:0] |   选 ID 段 B 的旁路    |   ID   |
| ForwardAE | [1:0] |   选 EX 段 A 的旁路    |   EX   |
| ForwardBE | [1:0] |   选 EX 段 B 的旁路    |   EX   |

