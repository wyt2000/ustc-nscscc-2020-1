`timescale 1ns / 1ps

module Exception_module(
    input clk,
    input rst,
    input Exception_code,
    output Exception_Stall,
    output Exception_clean,
    output Exception_Write_addr_sel,
    output Exception_Write_data_sel,
    output [6:0] Exception_RF_addr,
    output [31:0] Exceptiondata
    );
    assign Exception_Stall = 0;
    assign Exception_clean = 0;
    assign Exception_Write_addr_sel = 0;
    assign Exception_Write_data_sel = 0;
    assign Exception_RF_addr = 7'b0;
    assign Exceptiondata = 32'b0;
endmodule
