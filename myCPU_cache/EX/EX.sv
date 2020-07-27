`timescale 1ns / 1ps

module EX_module(
    input clk,
    input rst,
    input hiloWrite_i,
    input [2:0] MemReadType_i,
    input RegWrite_i,
    input MemtoReg_i,
    input MemWrite_i,
    input MemRead_i,
    input [5:0] ALUControl,
    input ALUSrcA,
    input ALUSrcB,
    input RegDst,
    input immSel,
    input [1:0] ForwardA,
    input [1:0] ForwardB,
    input [31:0] A,
    input [31:0] B,
    input [31:0] PCplus8,
    input [6:0] Rs,
    input [6:0] Rt,
    input [6:0] Rd,
    input [31:0] imm,
    input [31:0] ForwardMEM,
    input [31:0] ForwardWB,
    input [31:0] PCin,
    input exceptionD,
    input is_ds_in,
    output hiloWrite_o,
    output [2:0] MemReadType_o,
    output RegWrite_o,
    output MemtoReg_o,
    output MemWrite_o,
    output [6:0] Rs_o,
    output [6:0] Rt_o,
    output [63:0] hiloData,
    output [31:0] ALUResult,
    output done,
    output [3:0] exception,
    output stall,
    output [31:0] MemData,
    output [6:0] WriteRegister,
    output [31:0] PCout,
    output MemRead_o,
    output is_ds_out
    );
    
    wire [31:0] imm_o;
    wire [31:0] A_o;
    wire [31:0] B_o;
    wire [31:0] a;
    wire [31:0] b;
    wire [63:0] hilo;

    //pass control signals and MemAddress
    assign hiloWrite_o = hiloWrite_i;
    assign MemReadType_o = MemReadType_i;
    assign RegWrite_o = RegWrite_i;
    assign MemtoReg_o = MemtoReg_i;
    assign MemWrite_o = MemWrite_i;
    assign MemData = B_o;
    assign Rs_o = Rs;
    assign Rt_o = Rt;
    assign PCout = PCin;
    assign MemRead_o = MemRead_i;
    assign is_ds_out = is_ds_in;

    //mux
    assign imm_o = immSel ? PCplus8 : imm;
    assign WriteRegister = RegDst ? Rd : Rt;
    assign A_o = ForwardA[1] ? ForwardMEM : (ForwardA[0] ? ForwardWB : A);
    assign B_o = ForwardB[1] ? ForwardMEM : (ForwardB[0] ? ForwardWB : B);
    assign a = ALUSrcA ? imm_o : A_o;
    assign b = ALUSrcB ? imm_o : B_o;

    //ALU
    alu alu(
        .clk        (clk),
        .rst        (rst),
        .a          (a),
        .b          (b),
        .op         (ALUControl),
        .result     (ALUResult),
        .exceptionD (exceptionD),
        .exception  (exception),
        .hilo       (hilo),
        .stall      (stall),
        .done       (done)
    );

    reg [63:0] reg_hiloData;
    assign hiloData = done ? hilo : reg_hiloData;
    always_ff @(posedge clk) begin
        if(rst)
            reg_hiloData <= 0;
        else if(done)
            reg_hiloData <= hilo;
        else
            reg_hiloData <= reg_hiloData;
    end

endmodule
