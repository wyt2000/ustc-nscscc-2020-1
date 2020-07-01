module PC_Reg_enable
	#(parameter WIDTH=32	)
(
    input [WIDTH-1:0] data,
    input clk,
    input rst,
    input enable,
    output reg [WIDTH-1:0] readregister
	);
    always@(posedge clk)
        if(rst)
            readregister<=32'h00000000;
        else if(enable)
            readregister<=data;
        else readregister<=readregister;

endmodule


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
    output [WIDTH-1:0] Instruction,
    output [WIDTH-1:0] PC_add_4
);	
    wire [WIDTH-1:0] PCout;
    reg [WIDTH-1:0] PCin;
    PC_Reg_enable PC(.clk(clk),.rst(rst),.enable(!StallF),.data(PCin),.readregister(PCout));
    assign PC_add_4=PCout+4;
    always@({Jump,BranchD,EPC_sel})
    if(EPC_sel==0)
        PCin=EPC;
    else if({Jump,BranchD}==2'b11)begin
        PCin=Jump_addr;
    end
    else if({Jump,BranchD}==2'b10)begin
        PCin=Jump_reg;
    end
    else if({Jump,BranchD}==2'b01)begin
        PCin=beq_addr;
    end
    else if({Jump,BranchD}==2'b00)begin
        PCin=PC_add_4;
    end
    Instruction_Memory Instruction_Memory(.clk(clk),.addr(PCout[9:2]),.data(Instruction));


endmodule