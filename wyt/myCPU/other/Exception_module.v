`timescale 1ns / 1ps

module Exception_module(
    input clk,
    input Exception_code,
    output Exception_Stall,
    output Exception_clean,
    output Exception_Write_addr_sel,
    output Exception_Write_data_sel,
    output [6:0] Exception_RF_addr,
    output [31:0] Exceptiondata
    );
endmodule
