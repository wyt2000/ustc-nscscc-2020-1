# ID模块

branch_judge改动：branch_taken在Op为000000时也有效。

控制单元：删除了ALUControl信号，传给ID/EX段间寄存器的RegWriteD由RegWriteBD（来自branch_judge）和RegWriteCD（来自Control Unit）相或后生成。

寄存器堆(register_file)读CP0的端口改为read_addr_2，因为只有MFC0指令需要读CP0寄存器且读取字段为RT。

ID增加输出branch_addr，原jump_addr更改为数据通路中最左边的多选器的第三个端口的信号，branch_addr为上述多选器中第一个端口的信号。

控制单元的控制信号详见control unit signals.xlsx文件，使用了吴钰同的instruction.vh头文件。控制信号可能存在错误，欢迎指出。

修正了一些小错：MemReadType和RS、RD、RT宽度。

添加了新的旁路端口。

## Branch_judge模块的信号

| 情形                 | RegWriteBD | BranchD | branch_taken |
| -------------------- | ---------- | ------- | ------------ |
| beq                  | 0          | 1       | 1            |
| bne                  | 0          | 1       | 1            |
| bgez                 | 0          | 1       | 1            |
| bltz                 | 0          | 1       | 1            |
| bgezal               | 1          | 1       | 1            |
| bltzal               | 1          | 1       | 1            |
| bgtz                 | 0          | 1       | 1            |
| blez                 | 0          | 1       | 1            |
| j                    | 0          | 1       | 1            |
| jal                  | 1          | 1       | 1            |
| jr或jalr             | 1          | 0       | 1            |
| 分支不发生及其他情况 | 0          | 0       | 0            |

## Register_file接口说明

### 输入

| 变量名                  | 位宽   | 功能                 | 来自         |
| ----------------------- | ------ | -------------------- | ------------ |
| clk                     | 1      | 时钟                 | global       |
| rst                     | 1      | 复位                 | global       |
| regwrite                | 1      | 寄存器堆写使能       | WB           |
| hl_write_enable_from_wb | 1      | HI/LO写使能          | WB           |
| read_addr_1             | [6:0]  | 读地址1              | decoder      |
| read_addr_2             | [6:0]  | 读地址2              | decoder      |
| hl_data                 | [63:0] | HI/LO写数据          | WB           |
| write_addr              | [6:0]  | 写目标寄存器         | WB           |
| write_data              | [31:0] | 写的数据             | WB           |
| we                      | [31:0] | 多个写CP0寄存器使能  | error_detect |
| interrupt_enable        | [7:0]  | 中断使能             | error_detect |
| Exception_code          | [4:0]  | 例外代码             | error_detect |
| EXL                     | 1      | 处理器状态标识       | error_detect |
| hardware_interruption   | [5:0]  | 6个硬件中断          | error_detect |
| software_interruption   | [1:0]  | 两个软件中断         | error_detect |
| epc                     | [31:0] | 恢复地址             | error_detect |
| BADADDR                 | [31:0] | 发生例外地址         | ？           |
| Branch_delay            | 1      | 异常指令是否在延迟槽 | ?            |

### 输出

| 变量名      | 位宽   | 功能                  | 去往         |
| ----------- | ------ | --------------------- | ------------ |
| read_data_1 | [31:0] | 读数据1               | ID/EX        |
| read_data_2 | [31:0] | 读数据2               | ID/EX        |
| Status_data | [31:0] | CP0的Status寄存器数据 | error_detect |
| EPC_data    | [31:0] | 恢复地址              | IF           |
| cause_data  | [31:0] | CP0的cause寄存器数据  | error_detect |

