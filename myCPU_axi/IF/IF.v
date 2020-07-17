module IF_module
    #(parameter WIDTH=32)
    (
    input clk,
    input rst,
    input Jump,BranchD,
    input EPC_sel,
    input StallF,
    input [WIDTH-1:0] EPC,
    input [WIDTH-1:0] Jump_reg,
    input [WIDTH-1:0] Jump_addr,
    input [WIDTH-1:0] beq_addr,
    input Error_happend,
    output [WIDTH-1:0] PC_add_4,
    output reg [WIDTH-1:0] PCout,
    output is_newPC,
    
    output  [31:0]  instr,

    output          inst_req,
    output          inst_wr,
    output  [1:0]   inst_size,
    output  [31:0]  inst_addr,
    output  [31:0]  inst_wdata,
    input   [31:0]  inst_rdata,
    input           inst_addr_ok,
    input           inst_data_ok,

    output          CLR,
    output          stall
    );
    
    assign PC_add_4 = PCout + 4;
    always@(posedge clk) begin
        if(rst) PCout <= 32'hbfc0_0000;
        else if(Error_happend && !stall) PCout <= 32'hbfc0_0380;
        else if(StallF) PCout <= PCout;
        else if(EPC_sel == 1)             PCout <= EPC;
        else if({Jump,BranchD} == 2'b11)  PCout <= Jump_addr;
        else if({Jump,BranchD} == 2'b10)  PCout <= Jump_reg;
        else if({Jump,BranchD} == 2'b01)  PCout <= beq_addr;
        else PCout <= PCout + 4; 
    end
    reg [31:0] old_PC;
    always@(posedge clk) begin
        if(rst)
            old_PC <= 32'b0;
        else
            old_PC <= PCout;
    end
    assign is_newPC = (PCout == old_PC) ? 0 : 1;
    reg [31:0] reg_instr;
    always@(posedge clk) begin
        if(inst_data_ok)
            reg_instr <= inst_rdata;
    end
    assign instr = inst_data_ok ? inst_rdata : reg_instr;

    inst_sram i_sram(.clk    (clk),
                    .rst    (rst),
                    
                    .inst_req   (inst_req)  ,
                    .inst_wr    (inst_wr)   ,
                    .inst_size  (inst_size) ,
                    .inst_addr  (inst_addr) ,
                    .inst_wdata (inst_wdata),
                    .inst_rdata (inst_rdata),
                    .inst_addr_ok   (inst_addr_ok)  ,
                    .inst_data_ok   (inst_data_ok)  ,
                    
                    .is_newPC   (is_newPC)  ,
                    .PC         (PCout)     ,
                    .CLR        (CLR)       ,
                    .stall      (stall)     );
endmodule