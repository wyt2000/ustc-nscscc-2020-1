`timescale 1ns / 1ps

module Instruction_Memory( //the simplified Instruction_Memory, which is read only for the processor we designed
    input clk,
    input [7:0] addr,
    output reg [31:0] data);
    reg [31:0] mem [31:0];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) mem[i] = 0;
    end
    always@(posedge clk) begin
        data <= mem[addr];
    end
endmodule
