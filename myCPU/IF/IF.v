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
    input Error_happend,
    output [WIDTH-1:0] PC_add_4,
    output reg [WIDTH-1:0] PCout,

    output is_newPC
);	
    assign PC_add_4 = PCout + 4;
    always@(posedge clk)
        if(rst) PCout <= 32'hbfc0_0000;
        else if(Error_happend) PCout <= 32'hbfc0_0380;
        else if(StallF) PCout <= PCout;
        // else if(EPC_sel == 0)             PCout <= EPC;
        else if(EPC_sel == 1)             PCout <= EPC;
        else if({Jump,BranchD} == 2'b11)  PCout <= Jump_addr;
        else if({Jump,BranchD} == 2'b10)  PCout <= Jump_reg;
        else if({Jump,BranchD} == 2'b01)  PCout <= beq_addr;
        else PCout <= PCout + 4;

    reg [31:0] old_PC;
    always@(posedge clk) begin
        if(rst)
            old_PC <= 32'b0;
        else
            old_PC <= PCout;
    end
    assign is_newPC = (PCout == old_PC) ? 0 : 1;

endmodule