`timescale 1ns / 1ps

module Control_Unit(
    input [5:0] Op,
    input [4:0] func,

    output EPC_sel,
    output HI_LO_write_enableD,
    output [1:0] MemReadType,
    output Jump,
    output MemReadD,
    output RegWriteCD,
    output MemtoRegD,
    output MemWriteD,
    output ALUSrcDA,
    output ALUSrcDB,
    output RegDstD,
    output Imm_sel
);

    /*see control unit signals.xlsx for detail, this file will be written according to it*/

endmodule