module IF_module
    #(parameter WIDTH=32)
(
    input clk,
    input rst,
    input Jump,BranchD,
    input EPC_sel,
    input StallF,
    input [WIDTH-1:0] EPC,//The last time Error PC
    input [WIDTH-1:0] Jump_reg,//The NPC of Jump to Reg Instruction
    input [WIDTH-1:0] Jump_addr,//The NPC of Jump Instruction
    input [WIDTH-1:0] beq_addr,//The NPC of Beq Instrcution
    input [WIDTH-1:0] Instruction_in,
    output [WIDTH-1:0] Instruction,
    output [WIDTH-1:0] PC_add_4,
    output reg [WIDTH-1:0] PCout
);	
    assign Instruction = Instruction_in;
    assign PC_add_4 = PCout + 4;
    always@(posedge clk)
        if(rst) PCout <= 0;
        else if(EPC_sel == 0)             PCout <= EPC;
        else if({Jump,BranchD} == 2'b11)  PCout <= Jump_addr;
        else if({Jump,BranchD} == 2'b10)  PCout <= Jump_reg;
        else if({Jump,BranchD} == 2'b01)  PCout <= beq_addr;
        else if({Jump,BranchD} == 2'b00)  PCout <= PC_add_4;
        else PCout <= 0;

endmodule