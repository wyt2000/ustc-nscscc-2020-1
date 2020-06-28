`timescale 1ns / 1ps

`include "instruction.vh"

module Control_Unit(
    input [5:0] Op,
    input [4:0] func,

    output reg EPC_sel,
    output reg HI_LO_write_enableD,
    output reg [2:0] MemReadType,
    output reg Jump,
    output reg MemReadD,
    output reg RegWriteCD,
    output reg MemtoRegD,
    output reg MemWriteD,
    output reg ALUSrcDA,
    output reg ALUSrcDB,
    output reg RegDstD,
    output reg Imm_sel
);

    //HI_LO_write_enableD
    always@(*) begin
        HI_LO_write_enableD = 0;
        if(Op == `OP_ZERO && 
            (func == `FUNC_DIV||
            func == `FUNC_DIVU||
            func == `FUNC_MULT||
            func == `FUNC_MULTU))
            HI_LO_write_enableD = 1;
    end

    //MemReadType
    always@(*) begin
        MemReadType = 3'b111;
        case(Op)
        `OP_LB:  begin
            //LB
            MemReadType = 3'b100;
        end
        `OP_LBU: begin
            //LBU
            MemReadType = 3'b000;
        end
        `OP_LH: begin
            //LH
            MemReadType = 3'b101;
        end
        `OP_LHU: begin
            //LHU
            MemReadType = 3'b001;
        end
        `OP_LW: begin
            //LW
            MemReadType = 3'b010;
        end
        `OP_SB: begin
            //SB
            MemReadType = 3'b000;
        end
        `OP_SH: begin
            //SH
            MemReadType = 3'b001;
        end
        `OP_SW: begin
            //SW
            MemReadType = 3'b010;
        end
        default: ;
        endcase
    end

    //Jump
    always@(*) begin
        Jump = 0;
        if(Op == `OP_J ||
           Op == `OP_JAL ||
          (Op == `OP_ZERO && func == `FUNC_JR) ||
          (Op == `OP_ZERO && func == `FUNC_JALR))
          Jump = 1;
    end

    //MemReadD
    always@(*) begin
        MemReadD = 0;
        if(Op == `OP_LB ||
           Op == `OP_LBU ||
           Op == `OP_LH ||
           Op == `OP_LHU ||
           Op == `OP_LW)
           MemReadD = 1;
    end

    //RegWriteCD
    always@(*) begin
        RegWriteCD = 1;
        if(Op == `OP_BELSE ||
           Op == `OP_BEQ ||
           Op == `OP_BNE ||
           Op == `OP_BGTZ ||
           Op == `OP_BLEZ ||
           Op == `OP_J ||
           (Op == `OP_ZERO && func == `FUNC_JR) ||
           (Op == `OP_ZERO && func == `FUNC_BREAK) ||
           (Op == `OP_ZERO && func == `FUNC_SYSCALL) ||
           Op == `OP_SB ||
           Op == `OP_SH ||
           Op == `OP_SW
           )
           RegWriteCD = 0;
    end

    //MemtoRegD
    always@(*) begin
        MemtoRegD = 1;
        if(Op == `OP_LB ||
           Op == `OP_LBU ||
           Op == `OP_LH ||
           Op == `OP_LHU ||
           Op == `OP_LW)
           MemtoRegD = 0;
    end

    //MemWriteD
    always@(*) begin
        MemWriteD = 0;
        if(Op == `OP_SB ||
           Op == `OP_SH ||
           Op == `OP_SW)
           MemWriteD = 1;
    end

    //ALUSrcDA
    always@(*) begin
        ALUSrcDA = 0;
        if((Op == `OP_ZERO && func == `FUNC_SLL) ||
           (Op == `OP_ZERO && func == `FUNC_SRA) ||
           (Op == `OP_ZERO && func == `FUNC_SRL) ||
           (Op == `OP_ZERO && func == `FUNC_JALR))
           ALUSrcDA = 1;
    end

    //ALUSrcDB
    always@(*) begin
        ALUSrcDB = 0;
        if((Op == `OP_BELSE && (func == `FUNC_BGEZAL ||
                                 func == `FUNC_BLTZAL)) ||
            Op == `OP_ADDI ||
            Op == `OP_ADDIU ||
            Op == `OP_SLTI ||
            Op == `OP_SLTIU ||
            Op == `OP_ANDI ||
            Op == `OP_LUI ||
            Op == `OP_ORI ||
            Op == `OP_XORI ||
            Op == `OP_JAL ||
            Op == `OP_LB ||
            Op == `OP_LBU ||
            Op == `OP_LH ||
            Op == `OP_LHU ||
            Op == `OP_LW ||
            Op == `OP_SB ||
            Op == `OP_SH ||
            Op == `OP_SW)
            ALUSrcDB = 1;
    end

    //RegDstD
    always@(*) begin
        RegDstD = ~ALUSrcDB;
        if(Op == `OP_ZERO && func == `FUNC_JALR)
            RegDstD = 0;
    end

    //Imm_sel
    always@(*) begin
        Imm_sel = 0;
        if(Op == `OP_BELSE ||
           Op == `OP_JAL ||
           (Op == `OP_ZERO && func == `FUNC_JALR))
           Imm_sel = 1;
    end

    //EPC_sel
    always@(*) begin
        EPC_sel = 1;
        if(Op == `OP_PRIV && func == `FUNC_ERET)
            EPC_sel = 0;
    end

endmodule