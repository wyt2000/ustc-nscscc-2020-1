# ALU

ALU 是 EX 模块的子模块，ALUOp 由控制单元根据指令字生成。

ALU 分为三个部分：

- alu 模块，进行乘法和除法以外的所有运算，是纯组合逻辑。

- multiplier 是一个乘法器 ip 核的例化，一次乘法运算需要 5 个周期完成。
- divider 是一个除法器 ip 核的例化，一次除法运算需要 34 个周期完成。（这两个周期数都可以调整）

ALU 支持的指令及对应结果：

|   指令    |                     result                      |          hi           |          lo          |                     exception                     |
| :-------: | :---------------------------------------------: | :-------------------: | :------------------: | :-----------------------------------------------: |
| ADD,ADDI  |                       a+b                       |           -           |          -           | overflow = (a[31] ~^ b[31]) & (a[31] ^ res_1[31]) |
|   ADDU    |                       a+b                       |           -           |          -           |                         -                         |
|   ADDIU   |               a+$signed(b[15:0])                |           -           |          -           |                         -                         |
|    SUB    |                       a-b                       |           -           |          -           | overflow = (a[31]  ^ b[31]) & (a[31] ^ res_1[31]) |
|   SUBU    |                       a-b                       |           -           |          -           |                         -                         |
|    SLT    |    \$signed(a) < ​\$signed(b) ? 32'd1 : 32'd0    |           -           |          -           |                         -                         |
|   SLTI    | \$signed(a) < ​\$signed(b[15:0]) ? 32'd1 : 32'd0 |           -           |          -           |                         -                         |
|   SLTU    |              a < b? 32'd1 : 32'd0               |           -           |          -           |                         -                         |
|   SLTIU   |      a < $signed(b[15:0]) ? 32'd1 : 32'd0       |           -           |          -           |                         -                         |
|    DIV    |                        -                        |     $signed(a//b)     |     $signed(a%b)     |                divZero = (b == 0)                 |
|   DIVU    |                        -                        |         a//b          |         a%b          |                divZero = (b == 0)                 |
|   MULT    |                        -                        | ($signed(a*b))[63:32] | ($signed(a*b))[31:0] |                         -                         |
|   MULTU   |                        -                        |     (a*b)[63:32]      |     (a*b)[31:0]      |                         -                         |
| AND,ANDI  |                       a&b                       |           -           |          -           |                         -                         |
|    LUI    |                 {b[15:0],16'b0}                 |           -           |          -           |                         -                         |
|    NOR    |                     ~(a\|b)                     |           -           |          -           |                         -                         |
|  OR,ORI   |                      a\|b                       |           -           |          -           |                         -                         |
| XOR,XORI  |                       a^b                       |           -           |          -           |                         -                         |
| SLLV,SLL  |                   b << a[4:0]                   |           -           |          -           |                         -                         |
| SRAV,SRA  |              $signed(b) >>> a[4:0]              |           -           |          -           |                         -                         |
| SRLV,SRL  |                   b >> a[4:0]                   |           -           |          -           |                         -                         |
|   BREAK   |                        -                        |           -           |          -           |                     break = 1                     |
|  SYSCALL  |                        -                        |           -           |          -           |                    syscall = 1                    |
| LB,LBU,SB |               a+$signed(b[15:0])                |           -           |          -           |                         -                         |
| LH,LHU,SH |               a+$signed(b[15:0])                |           -           |          -           |            addrErr = (res_1[0]==1'b1)             |
|   LW,SW   |               a+$signed(b[15:0])                |           -           |          -           |           addrErr = (res_1[1:0]!=2'b00)           |
|   MFHI    |                       hi                        |           -           |          -           |                         -                         |
|   MFLO    |                       lo                        |           -           |          -           |                         -                         |
|   MTHI    |                        -                        |           a           |          -           |                         -                         |
|   MTLO    |                        -                        |           -           |          a           |                         -                         |
|   ERET    |                        -                        |           -           |          -           |                                                   |


问题：

- beq 指令放在 ID 段执行？
- 计算乘法和除法时，怎么 stall 流水线？是不是要搞两个 ALU ？
- 访存指令要有额外的模块做虚实地址转换。‘
- 协处理器相关的指令没写。
- lw 用不用判断地址溢出？
- 负数除法的余数和被除数同号。

- 乘法除法和数据移动指令同时完成怎么办？