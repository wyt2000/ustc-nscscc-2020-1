// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Wed Jul 22 17:33:01 2020
// Host        : DESKTOP-7LO5JPI running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top TAG_V_RAM -prefix
//               TAG_V_RAM_ dist_mem_gen_0_stub.v
// Design      : dist_mem_gen_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_13,Vivado 2019.1" *)
module TAG_V_RAM(a, d, clk, we, spo)
/* synthesis syn_black_box black_box_pad_pin="a[6:0],d[20:0],clk,we,spo[20:0]" */;
  input [6:0]a;
  input [20:0]d;
  input clk;
  input we;
  output [20:0]spo;
endmodule
