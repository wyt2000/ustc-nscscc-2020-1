`timescale 1ns / 1ps
`include "../other/aluop.vh"
`include "../other/instruction.vh"
module decoder(
    input [31:0] ins,
    output logic [5:0] ALUop,
    output logic [6:0] Rs,
    output logic [6:0] Rt,
    output logic [6:0] Rd,
    output logic [15:0] imm,
    output logic exception
    );
    wire [5:0] op;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] sa;
    wire [5:0] func;

    assign op = ins[31:26];
    assign rs = ins[25:21];
    assign rt = ins[20:16];
    assign rd = ins[15:11];
    assign sa = ins[10:6];
    assign func = ins[5:0]; 
    assign imm = (op == `OP_PRIV && rs == `FUNC_ERET) ? 32'hfffffffe : ins[15:0];

    always_comb begin : set_ALUop
        ALUop = `ALU_NOP;
        case (op)
            `OP_ZERO:
                case (func)
                    `FUNC_ADD:              ALUop = `ALU_ADD;
                    `FUNC_ADDU:             ALUop = `ALU_ADDU;
                    `FUNC_SUB:              ALUop = `ALU_SUB;
                    `FUNC_SUBU:             ALUop = `ALU_SUBU;
                    `FUNC_SLT:              ALUop = `ALU_SLT;
                    `FUNC_SLTU:             ALUop = `ALU_SLTU;
                    `FUNC_DIV:              ALUop = `ALU_DIV;
                    `FUNC_DIVU:             ALUop = `ALU_DIVU;
                    `FUNC_MULT:             ALUop = `ALU_MULT;
                    `FUNC_MULTU:            ALUop = `ALU_MULTU;
                    `FUNC_AND:              ALUop = `ALU_AND;
                    `FUNC_NOR:              ALUop = `ALU_NOR;
                    `FUNC_OR:               ALUop = `ALU_OR;
                    `FUNC_XOR:              ALUop = `ALU_XOR;
                    `FUNC_SLLV:             ALUop = `ALU_SLLV;
                    `FUNC_SLL:              ALUop = `ALU_SLL;
                    `FUNC_SRAV:             ALUop = `ALU_SRAV;
                    `FUNC_SRA:              ALUop = `ALU_SRA;
                    `FUNC_SRLV:             ALUop = `ALU_SRLV;
                    `FUNC_SRL:              ALUop = `ALU_SRL;
                    `FUNC_BREAK:            ALUop = `ALU_BREAK;
                    `FUNC_SYSCALL:          ALUop = `ALU_SYSCALL;
                    `FUNC_JR,`FUNC_JALR,
                    `FUNC_MFHI,`FUNC_MFLO,
                    `FUNC_MTHI,`FUNC_MTLO:  ALUop = `ALU_ADDU;
                endcase
            `OP_PRIV:                       begin   //changed by jbz 7.8.2020
                                            ALUop = `ALU_ADD; 
                                            if(rs == `FUNC_ERET)
                                                ALUop = `ALU_ERET;
                                            end
            `OP_ADDI:                       ALUop = `ALU_ADDI;
            `OP_ADDIU:                      ALUop = `ALU_ADDIU;
            `OP_SLTI:                       ALUop = `ALU_SLTI;
            `OP_SLTIU:                      ALUop = `ALU_SLTIU;
            `OP_ANDI:                       ALUop = `ALU_ANDI;
            `OP_LUI:                        ALUop = `ALU_LUI;
            `OP_ORI:                        ALUop = `ALU_ORI;
            `OP_XORI:                       ALUop = `ALU_XORI;
            `OP_LB:                         ALUop = `ALU_LB;
            `OP_LBU:                        ALUop = `ALU_LBU;
            `OP_LH:                         ALUop = `ALU_LH;
            `OP_LHU:                        ALUop = `ALU_LHU;
            `OP_LW:                         ALUop = `ALU_LW;
            `OP_SB:                         ALUop = `ALU_SB;
            `OP_SH:                         ALUop = `ALU_SH;
            `OP_SW:                         ALUop = `ALU_SW;
            `OP_J,`OP_JAL,
            `OP_BEQ,`OP_BNE,
            `OP_BGTZ,`OP_BLEZ,
            `OP_BELSE:                      ALUop = `ALU_ADDU;
        endcase
    end

    always_comb begin : set_exception 
        exception = 1;
        case (op)
            `OP_ZERO:
                case (func)
                    `FUNC_ADD,`FUNC_ADDU,
                    `FUNC_SUB,`FUNC_SUBU,
                    `FUNC_SLT,`FUNC_SLTU,
                    `FUNC_AND,`FUNC_NOR,
                    `FUNC_OR,`FUNC_XOR,
                    `FUNC_SLLV,`FUNC_SRAV,
                    `FUNC_SRLV:
                        if(sa == 0) exception = 0;
                    `FUNC_DIV,`FUNC_DIVU,
                    `FUNC_MULT,`FUNC_MULTU:
                        if(rd == 0 && sa == 0) exception = 0;
                    `FUNC_SLL,`FUNC_SRA,
                    `FUNC_SRL:
                        if(rs == 0) exception = 0;
                    `FUNC_JR,`FUNC_MTHI,`FUNC_MTLO:
                        if(rt == 0 && rd == 0 && sa == 0) exception = 0;
                    `FUNC_JALR:
                        if(rt == 0 && sa == 0) exception = 0;
                    `FUNC_MFHI,`FUNC_MFLO:
                        if(rs == 0 && rt == 0 && sa == 0) exception = 0;
                    `FUNC_BREAK,`FUNC_SYSCALL:
                        exception = 0;
                endcase
            `OP_PRIV:
                case (rs)
                    `FUNC_ERET:
                        if(rt == 0 && rd == 0 && sa == 0 && func == 6'b011000) exception = 0;
                    `FUNC_MFC0,`FUNC_MTC0:
                        if(sa == 0 && func[5:3] == 0) exception = 0;
                endcase
            `OP_ADDI,`OP_ADDIU,
            `OP_SLTI,`OP_SLTIU,
            `OP_ANDI,`OP_ORI,
            `OP_XORI,`OP_LB,
            `OP_LBU,`OP_LH,
            `OP_LHU,`OP_LW,
            `OP_SB,`OP_SH,
            `OP_SW,`OP_J,
            `OP_JAL,`OP_BEQ,
            `OP_BNE,`OP_BGTZ,
            `OP_BLEZ:
                exception = 0;
            `OP_LUI:
                if(rs == 0) exception = 0;
            `OP_BELSE:
                if(ins[19:17] == 0) exception = 0;                
        endcase
        if(ins == 32'b0) exception = 0;
    end

    always_comb begin : set_Register
        Rd = {2'b00, rd};
        Rs = {2'b00, rs};
        Rt = {2'b00, rt};
        case (op)
            `OP_ZERO:
                case (func)
                    `FUNC_MFHI: Rs = `HI_ADDR;
                    `FUNC_MFLO: Rs = `LO_ADDR;
                    `FUNC_MTHI: Rd = `HI_ADDR;
                    `FUNC_MTLO: Rd = `LO_ADDR;
                endcase
            `OP_J: Rd = 0;
            `OP_JAL: begin
                Rs = 0;
                Rd = 31;
                Rt = 0;
            end
            `OP_BEQ,`OP_BNE,
            `OP_BGTZ,`OP_BLEZ:  Rd = 0;
            `OP_BELSE:
                case (rt)
                    `FUNC_BGEZ,`FUNC_BLTZ: Rd = 0;
                    `FUNC_BGEZAL,`FUNC_BLTZAL: begin
                        Rd = 31;
                        Rt = 0;
                    end
                endcase
            `OP_PRIV:
                case (rs)
                    `FUNC_MFC0: begin
                        Rd = Rt;
                        Rs = 0;
                        Rt = {2'b01, rd};
                    end
                    `FUNC_MTC0: begin
                        Rd = {2'b01, rd};
                        Rs = 0;
                    end
                    `FUNC_ERET: begin
                        Rt = {2'b01, 5'b01100};
                        Rs = 0;
                        Rd = {2'b01, 5'b01100};
                    end
                endcase
        endcase
    end

endmodule
