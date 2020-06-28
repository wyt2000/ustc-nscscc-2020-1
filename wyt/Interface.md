# CPU_TOP

以下主要是不通过段间寄存器直接跨越模块的接口。

|             去往              |                来自                |  位宽  |
| :---------------------------: | :--------------------------------: | :----: |
|            IF.Jump            |              ID.Jump               |   1    |
|          IF.BranchD           |             ID.BranchD             |   1    |
|          IF.EPC_sel           |             ID.EPC_sel             |   1    |
|            IF.EPC             |               ID.EPC               | [31:0] |
|          IF.Jump_reg          |            ID.PCSrc_reg            | [31:0] |
|         IF.Jump_addr          |            ID.Jump_addr            | [31:0] |
|          IF.beq_addr          |           ID.Branch_addr           | [31:0] |
|           IF.StallF           |           Hazard.StallF            |   1    |
|         ID.RegWriteW          |            WB.RegWrite             |   1    |
|         ID.WriteRegW          |        WB.WritetoRFaddrout         | [6:0]  |
|          ID.ResultW           |          WB.WritetoRFdata          | [31:0] |
| ID.HI_LO_write_enable_from_WB |      WB.HI_LO_writeenableout       |   1    |
|         ID.HI_LO_data         |      WB.WriteinRF_HI_LO_data       | [63:0] |
|          ID.ALUoutE           |            EX.ALUResult            | [31:0] |
|          ID.ALUoutM           |            MEM.ALUoutW             | [31:0] |
|          ID.RAMoutM           |             MEM.RAMout             | [31:0] |
|         ID.ForwardAD          |          Hazard.ForwardAD          | [1:0]  |
|         ID.ForwardBD          |          Hazard.ForwardBD          | [1:0]  |
|         EX.ForwardMEM         |             MEM.RAMout             | [31:0] |
|         EX.ForwardWB          |          WB.WritetoRFdata          | [31:0] |
|          EX.ForwardA          |          Hazard.ForwardAE          | [1:0]  |
|          EX.ForwardB          |          Hazard.ForwardBE          | [1:0]  |
|  WB.Exception_Write_addr_sel  | Exception.Exception_Write_addr_sel |   1    |
|  WB.Exception_Write_data_sel  | Exception.Exception_Write_data_sel |   1    |
|     WB.Exception_RF_addr      |    Exception.Exception_RF_addr     | [6:0]  |
|       WB.Exceptiondata        |      Exception.Exceptiondata       | [31:0] |

# IF 段

### 输入部分
|  变量名   |  位宽  |            功能             |     来自      |
| :-------: | :----: | :-------------------------: | :-----------: |
|    clk    |   1    |          全局时钟           |     全局      |
|    rst    |   1    |          全局复位           |     全局      |
|   Jump    |   1    |        Jump 是否成功        |      ID       |
|  BranchD  |   1    |       Branch 是否成功       |      ID       |
|  EPC_sel  |   1    |     选择 PC 是否为 EPC      |      ID       |
|    EPC    | [31:0] |       作为 NPC 的 EPC       |      ID       |
| Jump_reg  | [31:0] |      作为 NPC 的 Rs 值      |      ID       |
| Jump_addr | [31:0] |  作为 NPC 的 Jump 跳转地址  |      ID       |
| beq_addr  | [31:0] | 作为 NPC 的 Branch 跳转地址 |      ID       |
|  StallF   |   1    |     是否暂停取下一个 PC     | Hazard.StallF |

### 输出部分


|   变量名    |  位宽  |   功能   |    来自    | 去往  |
| :---------: | :----: | :------: | :--------: | :---: |
| Instruction | [31:0] | 完整指令 | 指令存储器 | IF/ID |
|  PC_add_4   | [31:0] |   PC+4   | PC 寄存器  | IF/ID |

# IF/ID 段间寄存器

|    来自     |   去往    | 位宽 |
| :---------: | :-------: | :--: |
| Instruction |   instr   |  32  |
|  PC_add_4   | pc_plus_4 |  32  |

# ID 段

### 输入部分

|           变量名           |  位宽  |             功能             |          来自           |
| :------------------------: | :----: | :--------------------------: | :---------------------: |
|            clk             |   1    |           全局时钟           |          全局           |
|            rst             |   1    |           全局复位           |          全局           |
|           instr            | [31:0] |         ID 段的指令          |          IF/ID          |
|         pc_plus_4          | [31:0] |         ID 段的 PC+4         |          IF/ID          |
|         RegWriteW          |   1    |   WB 段是否要写通用寄存器    |       WB.RegWrite       |
|         WriteRegW          | [6:0]  |  WB 段要写回的通用寄存器号   |   WB.WritetoRFaddrout   |
|          ResultW           | [31:0] |  WB 段要写回的通用寄存器值   |    WB.WritetoRFdata     |
| HI_LO_write_enable_from_WB |   1    |  WB 段是否要写 HILO 寄存器   | WB.HI_LO_writeenablein  |
|         HI_LO_data         | [63:0] | WB 段要写回的 HILO 寄存器值  | WB.WriteinRF_HI_LO_data |
|          ALUoutE           | [31:0] |       来自 EX 段的旁路       |      EX.ALUResult       |
|          ALUoutM           | [31:0] |  来自 MEM 段的计算结果旁路   |       MEM.ALUoutW       |
|          RAMoutM           | [31:0] | 来自 MEM 段的 RAM 读数据旁路 |       MEM.RAMout        |
|         ForwardAD          | [1:0]  |      选 RsValue 的旁路       |    Hazard.ForwardAD     |
|         ForwardBD          | [1:0]  |      选 RtValue 的旁路       |    Hazard.ForwardBD     |

### 输出部分

|          变量名          |  位宽  |                 功能                  |  去往  |
| :----------------------: | :----: | :-----------------------------------: | :----: |
|          ALUOp           | [5:0]  |      decoder 算出的 ALUOp（EX）       | ID/EX  |
|         ALUSrcDA         |   1    |     空传选 a 是 A 或立即数（EX）      | ID/EX  |
|         ALUSrcDB         |   1    |     空传选 b 是 B 或立即数（EX）      | ID/EX  |
|         RegDstD          |   1    |       空传选写回 Rt 或 Rd（EX）       | ID/EX  |
|         MemReadD         |   1    |            空传 mem 读使能            | ID/EX  |
|       MemReadType        | [2:0]  |            空传 mem 读选择            | ID/EX  |
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
|        jump_addr         | [31:0] |  传回 IF 段作为 NPC 的 Jump 跳转地址  |   IF   |
|       branch_addr        | [31:0] | 传回 IF 段作为 NPC 的 Branch 跳转地址 |   IF   |
|          CLR_EN          |   1    |         清空 IF/ID 段间寄存器         | IF/ID  |
|        exception         |   1    |             指令是否无效              | Hazard |

# ID/EX 段间寄存器

|           来自           |     去往      |  位宽  |
| :----------------------: | :-----------: | :----: |
|          ALUOp           |  ALUControl   |   6    |
|         ALUSrcDA         |    ALUSrcA    |   1    |
|         ALUSrcDB         |    ALUSrcB    |   1    |
|         RegDstD          |    RegDst     |   1    |
|         MemReadD         |   MemRead_i   |   1    |
|       MemReadType        | MemReadType_i |   3    |
|        MemWriteD         |  MemWrite_i   |   1    |
|        MemtoRegD         |  MemtoReg_i   |   1    |
|   HI_LO_write_enableD    |  hiloWrite_i  |   1    |
|        RegWriteD         |  RegWrite_i   |   1    |
| Imm_sel_and_Branch_taken |    immSel     |   1    |
|         RsValue          |       A       |   32   |
|         RtValue          |       B       |   32   |
|        pc_plus_8         |    PCplus8    |   32   |
|            Rs            |      Rs       | 7  |
|            Rt            |      Rt       |   7    |
|            Rd            |      Rd       |   7    |
|         imm          |    imm    | 32 |

*零扩展

# EX 段

### 输入部分

|    变量名     |  位宽  |          功能          |  来自  |
| :-----------: | :----: | :--------------------: | :----: |
|      clk      |   1    |        全局时钟        |  全局  |
|      rst      |   1    |        全局复位        |  全局  |
|  hiloWrite_i  |   1    |    空传 HILO 写使能    | ID/EX  |
| MemReadType_i | [2:0]  |    空传 mem 读选择     | ID/EX  |
|   MemRead_i   |   1    |    空传 mem 读使能     | ID/EX  |
|  RegWrite_i   |   1    |   空传寄存器堆写使能   | ID/EX  |
|  MemtoReg_i   |   1    |      空传写回选择      | ID/EX  |
|  MemWrite_i   |   1    |    空传 mem 写使能     | ID/EX  |
|  ALUControl   | [5:0]  |         ALUop          | ID/EX  |
|    ALUSrcA    |   1    |   选 a 是 A 或立即数   | ID/EX  |
|    ALUSrcB    |   1    |   选 b 是 B 或立即数   | ID/EX  |
|    RegDst     |   1    |    选写回 Rt 或 Rd     | ID/EX  |
|    immSel     |   1    | 选立即数是 PC+8 或 Imm | ID/EX  |
|       A       | [31:0] |       Rs 的内容        | ID/EX  |
|       B       | [31:0] |       Rt 的内容        | ID/EX  |
|    PCplus8    | [31:0] |          PC+8          | ID/EX  |
|      Rs       | [6:0]  |     Rs 的寄存器号      | ID/EX  |
|      Rt       | [6:0]  |     Rt 的寄存器号      | ID/EX  |
|      Rd       | [6:0]  |     Rd 的寄存器号      | ID/EX  |
|      imm      | [31:0] |   0 扩展的 ins[15:0]   | ID/EX  |
|  ForwardMEM   | [31:0] |   来自 MEM 段的旁路    |  MEM   |
|   ForwardWB   | [31:0] |    来自 WB 段的旁路    |   WB   |
|   ForwardA    | [1:0]  |      选 A 的旁路       | Hazard |
|   ForwardB    | [1:0]  |      选 B 的旁路       | Hazard |

### 输出部分

|    变量名     |  位宽  |            功能             |  去往  |
| :-----------: | :----: | :-------------------------: | :----: |
|  hiloWrite_o  |   1    |      空传 HILO 写使能       | EX/MEM |
| MemReadType_o | [2:0]  |       空传 mem 读选择       | EX/MEM |
|   MemRead_o   |   1    |       空传 mem 读使能       | EX/MEM |
|  RegWrite_o   |   1    |     空传寄存器堆写使能      | EX/MEM |
|  MemtoReg_o   |   1    |        空传写回选择         | EX/MEM |
|  MemWrite_o   |   1    |       空传 mem 写使能       | EX/MEM |
|   hiloData    | [63:0] |       乘除法计算结果        | EX/MEM |
|   ALUResult   | [31:0] | 其他运算结果或 mem 读写地址 | EX/MEM |
|    MemData    | [31:0] |         mem 写数据          | EX/MEM |
| WriteRegister | [6:0]  |       写回的寄存器号        | EX/MEM |
|     Rs_o      | [6:0]  |    传 Rs 供 Hazard 判断     | Hazard |
|     Rt_o      | [6:0]  |    传 Rt 供 Hazard 判断     | Hazard |
|     done      |   1    |        是否算出结果         | Hazard |
|   exception   | [2:0]  |            异常             | Hazard |
|     stall     |   1    |       是否暂停流水线        | Hazard |

# EX/MEM 段间寄存器

|     来自      |        去往         |  位宽  |
| :-----------: | :-----------------: | :----: |
|  hiloWrite_o  | HI_LO_write_enableM |   1    |
| MemReadType_o |     MemReadType     |   3    |
|   MemRead_o   |      MemReadM       |   1    |
|  RegWrite_o   |      RegWriteM      |   1    |
|  MemtoReg_o   |      MemtoRegM      |   1    |
|  MemWrite_o   |      MemWriteM      |   1    |
|   hiloData    |     HI_LO_dataM     |   64   |
|   ALUResult   |       ALUout        | 32  |
|    MemData    |       RamData       | 32 |
| WriteRegister |    WriteRegister    | 7  |

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
|     MemReadType     | [2:0]  |           mem 读选择            | EX/MEM |
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
|     HI_LO_dataW     |      HILO_data      |   64   |
|       RAMout        |       Memdata       |   32   |
|       ALUoutW       |       aluout        |   32   |
|   WriteRegisterW    |   WritetoRFaddrin   |   7    |

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

|        来自         |    变量名    | 位宽  |              功能               |
| :-----------------: | :----------: | :---: | :-----------------------------: |
|     ID.BranchD      |   BranchD    |   1   |         Branch 是否成功         |
|        ID.Rs        |     RsD      | [6:0] |       ID 段的 Rs 寄存器号       |
|        ID.Rt        |     RtD      | [6:0] |       ID 段的 Rt 寄存器号       |
|    ID.exception     | ID_exception |   1   |            无效指令             |
|       EX.Rs_o       |     RsE      | [6:0] |       EX 段的 Rs 寄存器号       |
|       EX.Rt_o       |     RtE      | [6:0] |       EX 段的 Rt 寄存器号       |
|    EX.MemRead_o     |   MemReadE   |   1   |       EX 段指令是否读 mem       |
|    EX.MemtoReg_o    |  MemtoRegE   |   1   | EX 段指令是否将 mem 写回寄存器  |
|    EX.exception     | EX_exception | [2:0] |          EX 段异常类型          |
|      EX.stall       |    stall     |   1   |           暂停流水线            |
|       EX.done       |     done     |   1   |      乘除指令是否算出结果       |
|Exception_deal_module|Exception_Stall|1|出现异常在写CP0寄存器的周期要停顿流水线，这是输出停顿流水线的信号|
|Exception_deal_module|Exception_clean|1|出现异常开始要清零所有段间寄存器|
|    MEM.RegWriteM    |  RegWriteM   |   1   |   MEM 段指令是否要写回寄存器    |
|  MEM.WriteRegister  |  WriteRegM   | [6:0] |    MEM 段指令的写回寄存器号     |
|    MEM.MemReadM     |   MemReadM   |   1   |      MEM 段指令是否读 mem       |
|    MEM.MemtoRegM    |  MemtoRegM   |   1   | MEM 段指令是否将 mem 写回寄存器 |
|     WB.RegWrite     |  RegWriteW   |   1   |    WB 段指令是否要写回寄存器    |
| WB.WritetoRFaddrout |  WriteRegW   | [6:0] |     WB 段指令的写回寄存器号     |

### 输出部分


|          变量名          |  位宽  |                         功能                         |  去往  |
| :----------------------: | :----: | :--------------------------------------------------: | :----: |
|          StallF          |   1    |                  关闭 PC 寄存器使能                  |   IF   |
|          StallD          |   1    |                关闭 IF/ID 寄存器使能                 | IF/ID  |
|          StallE          |   1    |                关闭 ID/EX 寄存器使能                 | ID/EX  |
|          StallM          |   1    |                关闭 EX/MEM 寄存器使能                | EX/MEM |
|          StallW          |   1    |                关闭 MEM/WB 寄存器使能                | MEM/WB |
|          FlushD          |   1    |                  清空 IF/ID 寄存器                   | IF/ID  |
|          FlushE          |   1    |                  清空 ID/EX 寄存器                   | ID/EX  |
|          FlushM          |   1    |                  清空 EX/MEM 寄存器                  | EX/MEM |
|          FlushW          |   1    |                  清空 MEM/WB 寄存器                  | MEM/WB |
|        ForwardAD         | [1:0]  |                  选 ID 段 A 的旁路                   |   ID   |
|        ForwardBD         | [1:0]  |                  选 ID 段 B 的旁路                   |   ID   |
|        ForwardAE         | [1:0]  |                  选 EX 段 A 的旁路                   |   EX   |
|        ForwardBE         | [1:0]  |                  选 EX 段 B 的旁路                   |   EX   |

# Exception_deal_module

### 输入部分
|          变量名          |  位宽  |                         功能                         |  来自  |
| :----------------------: | :----: | :--------------------------------------------------: | :----: |
|Exception_code|未定|出现的异常编码|各个流水段和功能部件产生|
|clk|1|时钟，控制状态机|外部|

### 输出部分
|          变量名          |  位宽  |                         功能                         |  去往  |
| :----------------------: | :----: | :--------------------------------------------------: | :----: |
|Exception_Stall|1|出现异常在写CP0寄存器的周期要停顿流水线，这是输出停顿流水线的信号|Harzard|
|Exception_clean|1|出现异常开始要清零所有段间寄存器,输出到Harzard部分|Harzard|
| Exception_Write_addr_sel |   1    | 1选择写回异常处理写的CP0地址，否则写回指令写回的地址 |   WB   |
| Exception_Write_data_sel |   1    | 1选择异常处理单元生成的字，否则写回指令要求写回的数  |   WB   |
|    Exception_RF_addr     | [6:0]  |          异常处理模块生成的写寄存器文件端口          |   WB   |
|      Exceptiondata       | [31:0] |               寄存器文件生成的写CP0字                |   WB   |

# CPU_TOP

以下主要是不通过段间寄存器直接跨越模块的接口。

|              来自               |             去往              |  位宽  |
| :-----------------------------: | :---------------------------: | :----: |
|             ID.Jump             |            IF.Jump            |   1    |
|           ID.BranchD            |          IF.BranchD           |   1    |
|           ID.EPC_sel            |          IF.EPC_sel           |   1    |
|             ID_EPC              |            IF_EPC             | [31:0] |
|          ID.PCSrc_reg           |          IF.Jump_reg          | [31:0] |
|          ID.Jump_addr           |         IF.Jump_addr          | [31:0] |
|         ID.Branch_addr          |          IF.beq_addr          | [31:0] |
|          Hazard.StallF          |           IF.StallF           |   1    |
|           WB.RegWrite           |         ID.RegWriteW          |   1    |
|       WB.WritetoRFaddrout       |         ID.WriteRegW          | [6:0]  |
|        WB.WritetoRFdata         |          ID.ResultW           | [31:0] |
|     WB.HI_LO_writeenablein      | ID.HI_LO_write_enable_from_WB |   1    |
|     WB.WriteinRF_HI_LO_data     |         ID.HI_LO_data         | [63:0] |
|          EX.ALUResult           |          ID.ALUoutE           | [31:0] |
|           MEM.ALUoutW           |          ID.ALUoutM           | [31:0] |
|           MEM.RAMout            |          ID.RAMoutM           | [31:0] |
|        Hazard.ForwardAD         |         ID.ForwardAD          | [1:0]  |
|        Hazard.ForwardBD         |         ID.ForwardBD          | [1:0]  |
|           MEM.ALUoutW           |         EX.ForwardMEM         | [31:0] |
|        WB.WritetoRFdata         |         EX.ForwardWB          | [31:0] |
|        Hazard.ForwardAE         |          EX.ForwardA          | [1:0]  |
|        Hazard.ForwardBE         |          EX.ForwardB          | [1:0]  |
| Hazard.Exception_Write_addr_sel |  WB.Exception_Write_addr_sel  |   1    |
| Hazard.Exception_Write_data_sel |  WB.Exception_Write_data_sel  |   1    |
|    Hazard.Exception_RF_addr     |     WB.Exception_RF_addr      | [6:0]  |
|      Hazard.Exceptiondata       |       WB.Exceptiondata        | [31:0] |

# IF 段

### 输入部分
|  变量名   |  位宽  |            功能             |     来自      |
| :-------: | :----: | :-------------------------: | :-----------: |
|    clk    |   1    |          全局时钟           |     全局      |
|    rst    |   1    |          全局复位           |     全局      |
|   Jump    |   1    |        Jump 是否成功        |      ID       |
|  BranchD  |   1    |       Branch 是否成功       |      ID       |
|  EPC_sel  |   1    |     选择 PC 是否为 EPC      |      ID       |
|    EPC    | [31:0] |       作为 NPC 的 EPC       |      ID       |
| Jump_reg  | [31:0] |      作为 NPC 的 Rs 值      |      ID       |
| Jump_addr | [31:0] |  作为 NPC 的 Jump 跳转地址  |      ID       |
| beq_addr  | [31:0] | 作为 NPC 的 Branch 跳转地址 |      ID       |
|  StallF   |   1    |     是否暂停取下一个 PC     | Hazard.StallF |

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

|           变量名           |  位宽  |             功能             |          来自           |
| :------------------------: | :----: | :--------------------------: | :---------------------: |
|            clk             |   1    |           全局时钟           |          全局           |
|            rst             |   1    |           全局复位           |          全局           |
|           instr            | [31:0] |         ID 段的指令          |          IF/ID          |
|         pc_plus_4          | [31:0] |         ID 段的 PC+4         |          IF/ID          |
|         RegWriteW          |   1    |   WB 段是否要写通用寄存器    |       WB.RegWrite       |
|         WriteRegW          | [6:0]  |  WB 段要写回的通用寄存器号   |   WB.WritetoRFaddrout   |
|          ResultW           | [31:0] |  WB 段要写回的通用寄存器值   |    WB.WritetoRFdata     |
| HI_LO_write_enable_from_WB |   1    |  WB 段是否要写 HILO 寄存器   | WB.HI_LO_writeenablein  |
|         HI_LO_data         | [63:0] | WB 段要写回的 HILO 寄存器值  | WB.WriteinRF_HI_LO_data |
|          ALUoutE           | [31:0] |       来自 EX 段的旁路       |      EX.ALUResult       |
|          ALUoutM           | [31:0] |  来自 MEM 段的计算结果旁路   |       MEM.ALUoutW       |
|          RAMoutM           | [31:0] | 来自 MEM 段的 RAM 读数据旁路 |       MEM.RAMout        |
|         ForwardAD          | [1:0]  |      选 RsValue 的旁路       |    Hazard.ForwardAD     |
|         ForwardBD          | [1:0]  |      选 RtValue 的旁路       |    Hazard.ForwardBD     |

### 输出部分

|          变量名          |  位宽  |                 功能                  |  去往  |
| :----------------------: | :----: | :-----------------------------------: | :----: |
|          ALUOp           | [5:0]  |      decoder 算出的 ALUOp（EX）       | ID/EX  |
|         ALUSrcDA         |   1    |     空传选 a 是 A 或立即数（EX）      | ID/EX  |
|         ALUSrcDB         |   1    |     空传选 b 是 B 或立即数（EX）      | ID/EX  |
|         RegDstD          |   1    |       空传选写回 Rt 或 Rd（EX）       | ID/EX  |
|         MemReadD         |   1    |            空传 mem 读使能            | ID/EX  |
|       MemReadType        | [2:0]  |            空传 mem 读选择            | ID/EX  |
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
|       MemReadType        | MemReadType_i |   [2:0]    |
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
| MemReadType_i | [2:0]  |    空传 mem 读选择     | ID/EX  |
|   MemRead_i   |   1    |    空传 mem 读使能     | ID/EX  |
|  RegWrite_i   |   1    |   空传寄存器堆写使能   | ID/EX  |
|  MemtoReg_i   |   1    |      空传写回选择      | ID/EX  |
|  MemWrite_i   |   1    |    空传 mem 写使能     | ID/EX  |
|  ALUControl   | [5:0]  |         ALUop          | ID/EX  |
|    ALUSrcA    |   1    |   选 a 是 A 或立即数   | ID/EX  |
|    ALUSrcB    |   1    |   选 b 是 B 或立即数   | ID/EX  |
|    RegDst     |   1    |    选写回 Rt 或 Rd     | ID/EX  |
|    immSel     |   1    | 选立即数是 PC+8 或 Imm | ID/EX  |
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
| MemReadType_o | [2:0]  |       空传 mem 读选择       | EX/MEM |
|   MemRead_o   |   1    |       空传 mem 读使能       | EX/MEM |
|  RegWrite_o   |   1    |     空传寄存器堆写使能      | EX/MEM |
|  MemtoReg_o   |   1    |        空传写回选择         | EX/MEM |
|  MemWrite_o   |   1    |       空传 mem 写使能       | EX/MEM |
|   hiloData    | [63:0] |       乘除法计算结果        | EX/MEM |
|   ALUResult   | [31:0] | 其他运算结果或 mem 读写地址 | EX/MEM |
|    MemData    | [31:0] |         mem 写数据          | EX/MEM |
| WriteRegister | [6:0]  |       写回的寄存器号        | EX/MEM |
|     Rs_o      | [6:0]  |    传 Rs 供 Hazard 判断     | Hazard |
|     Rt_o      | [6:0]  |    传 Rt 供 Hazard 判断     | Hazard |
|     done      |   1    |        是否算出结果         | Hazard |
|   exception   | [2:0]  |            异常             | Hazard |
|     stall     |   1    |       是否暂停流水线        | Hazard |

# EX/MEM 段间寄存器

|     来自      |        去往         |  位宽  |
| :-----------: | :-----------------: | :----: |
|  hiloWrite_o  | HI_LO_write_enableM |   1    |
| MemReadType_o |     MemReadType     | [2:0]  |
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
|     MemReadType     | [2:0]  |           mem 读选择            | EX/MEM |
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
| HI_LO_writeenablein | 1 | HILO 写使能 | MEM/WB |
| HILO_data | [63:0] | 写回 HILO 寄存器的值 | MEM/WB |
| Exception_Write_addr_sel | 1 | 1选择写回异常处理写的CP0地址，否则写回指令写回的地址 | Hazard |
| Exception_Write_data_sel | 1 | 1选择异常处理单元生成的字，否则写回指令要求写回的数 | Hazard |
| Exception_RF_addr | [6:0] | 异常处理模块生成的写寄存器文件端口 | Hazard |
| Exceptiondata | [31:0] | 寄存器文件生成的写CP0字 | Hazard |

### 输出部分


|        变量名        |  位宽  |          功能          | 去往 |
| :------------------: | :----: | :--------------------: | :--: |
|   WritetoRFaddrout   | [6:0]  |  空传写回通用寄存器号  |  ID  |
|    WritetoRFdata     | [31:0] | 空传写回通用寄存器的值 |  ID  |
| HI_LO_writeenableout |   1    |      HILO 写使能       |  ID  |
| WriteinRF_HI_LO_data | [63:0] |  写回 HILO 寄存器的值  |  ID  |
|       RegWrite       |   1    |     寄存器堆写使能     |  ID  |

# Hazard

### 输入部分

|    变量名    | 位宽  |              功能               |        来自         |
| :----------: | :---: | :-----------------------------: | :-----------------: |
|   BranchD    |   1   |         Branch 是否成功         |     ID.BranchD      |
|     RsD      | [6:0] |       ID 段的 Rs 寄存器号       |        ID.Rs        |
|     RtD      | [6:0] |       ID 段的 Rt 寄存器号       |        ID.Rt        |
| ID_exception |   1   |            无效指令             |    ID.exception     |
|     RsE      | [6:0] |       EX 段的 Rs 寄存器号       |       EX.Rs_o       |
|     RtE      | [6:0] |       EX 段的 Rt 寄存器号       |       EX.Rt_o       |
|   MemReadE   |   1   |       EX 段指令是否读 mem       |    EX.MemRead_o     |
|  MemtoRegE   |   1   | EX 段指令是否将 mem 写回寄存器  |    EX.MemtoReg_o    |
| EX_exception | [2:0] |          EX 段异常类型          |    EX.exception     |
|    stall     |   1   |           暂停流水线            |      EX.stall       |
|     done     |   1   |      乘除指令是否算出结果       |       EX.done       |
|Exception_Stall|1|出现异常在写CP0寄存器的周期要停顿流水线，这是输出停顿流水线的信号|Exception_deal_module|
|Exception_clean|1|出现异常开始要清零所有段间寄存器|Exception_deal_module|
|  RegWriteM   |   1   |   MEM 段指令是否要写回寄存器    |    MEM.RegWriteM    |
|  WriteRegM   | [6:0] |    MEM 段指令的写回寄存器号     |  MEM.WriteRegister  |
|   MemReadM   |   1   |      MEM 段指令是否读 mem       |    MEM.MemReadM     |
|  MemtoRegM   |   1   | MEM 段指令是否将 mem 写回寄存器 |    MEM.MemtoRegM    |
|  RegWriteW   |   1   |    WB 段指令是否要写回寄存器    |     WB.RegWrite     |
|  WriteRegW   | [6:0] |     WB 段指令的写回寄存器号     | WB.WritetoRFaddrout |

### 输出部分


|          变量名          |  位宽  |                         功能                         |  去往  |
| :----------------------: | :----: | :--------------------------------------------------: | :----: |
|          StallF          |   1    |                  关闭 PC 寄存器使能                  |   IF   |
|          StallD          |   1    |                关闭 IF/ID 寄存器使能                 | IF/ID  |
|          StallE          |   1    |                关闭 ID/EX 寄存器使能                 | ID/EX  |
|          StallM          |   1    |                关闭 EX/MEM 寄存器使能                | EX/MEM |
|          StallW          |   1    |                关闭 MEM/WB 寄存器使能                | MEM/WB |
|          FlushD          |   1    |                  清空 IF/ID 寄存器                   | IF/ID  |
|          FlushE          |   1    |                  清空 ID/EX 寄存器                   | ID/EX  |
|          FlushM          |   1    |                  清空 EX/MEM 寄存器                  | EX/MEM |
|          FlushW          |   1    |                  清空 MEM/WB 寄存器                  | MEM/WB |
|        ForwardAD         | [1:0]  |                  选 ID 段 A 的旁路                   |   ID   |
|        ForwardBD         | [1:0]  |                  选 ID 段 B 的旁路                   |   ID   |
|        ForwardAE         | [1:0]  |                  选 EX 段 A 的旁路                   |   EX   |
|        ForwardBE         | [1:0]  |                  选 EX 段 B 的旁路                   |   EX   |

# Exception_deal_module

### 输入部分

|          变量名          |  位宽  |                         功能                         |  来自  |
| :----------------------: | :----: | :--------------------------------------------------: | :----: |
|Exception_code|未定|出现的异常编码|各个流水段和功能部件产生|
|clk|1|时钟，控制状态机|外部|

### 输出部分

|          变量名          |  位宽  |                         功能                         |  去往  |
| :----------------------: | :----: | :--------------------------------------------------: | :----: |
|Exception_Stall|1|出现异常在写CP0寄存器的周期要停顿流水线，这是输出停顿流水线的信号|Harzard|
|Exception_clean|1|出现异常开始要清零所有段间寄存器,输出到Harzard部分|Harzard|
| Exception_Write_addr_sel |   1    | 1选择写回异常处理写的CP0地址，否则写回指令写回的地址 |   WB   |
| Exception_Write_data_sel |   1    | 1选择异常处理单元生成的字，否则写回指令要求写回的数  |   WB   |
|    Exception_RF_addr     | [6:0]  |          异常处理模块生成的写寄存器文件端口          |   WB   |
|      Exceptiondata       | [31:0] |               寄存器文件生成的写CP0字                |   WB   |