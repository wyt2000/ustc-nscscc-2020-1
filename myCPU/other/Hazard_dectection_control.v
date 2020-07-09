module Hazard_module(
    input clk,
    input rst,
    input Exception_Stall,
    input Exception_clean,
    input BranchD,
    input isaBranchInstruction,//the signal produced by the control unit in the ID,if it is valid(1),then it mean the instrution in the ID is a branch instruction
    input [6:0] RsD,RtD,
    input [6:0] RsE,RtE,
    input [6:0] WriteRegE,WriteRegM,WriteRegW,
    input MemReadM,MemReadE,
    input MemtoRegE,MemtoRegM,
    input stall,done,
    input RegWriteE,RegWriteM,RegWriteW,//Whether write the Register File
    input [2:0] EX_exception,
    input ID_exception,
    output reg StallF,StallD,StallE,StallM,StallW,
    output reg FlushD,FlushE,FlushM,FlushW,
    output reg [1:0] ForwardAD,ForwardBD,ForwardAE,ForwardBE
);

    //reg StallF_reg, StallD_reg, StallM_reg, StallW_reg;

    always@(*)
        if(rst || RsD == 0) ForwardAD=2'b00;
    	else if(RegWriteE&&WriteRegE==RsD&&MemtoRegE&&RsD) ForwardAD=2'b01;//add+use,forwardtoID
    	else if(RegWriteM&&WriteRegM==RsD&&MemtoRegM&&
                //isaBranchInstruction&&
                RsD) ForwardAD=2'b10;//add+nop+Branch
    	else ForwardAD=2'b00;
    always@(*)
    	if(rst || RtD == 0) ForwardBD=2'b00;
        else if(RegWriteE&&WriteRegE==RtD&&MemtoRegE&&RtD) ForwardBD=2'b01;
    	else if(RegWriteM&&WriteRegM==RtD&&MemtoRegM&&
                //isaBranchInstruction&&
                RtD) ForwardBD=2'b10;//add+nop+Branch
    	else ForwardBD=2'b00;
    always@(*)
        if(rst || RsE == 0) ForwardAE=2'b00;
        else if(RegWriteW&&WriteRegW==RsE&&RsE) ForwardAE=2'b01;//add+nop+use(non-branch)
    	else if(RegWriteM&&WriteRegM==RsE&&MemtoRegM&&RsE) ForwardAE=2'b10;//add+use(non-Branch)
    	else ForwardAE=2'b00;
    always@(*)
        if(rst || RtE == 0) ForwardBE=2'b00;
        // else if(WriteRegW&&WriteRegW==RtE&&RtE) ForwardBE=2'b01;
        else if(RegWriteW&&WriteRegW==RtE&&RtE) ForwardBE=2'b01;
    	else if(RegWriteM&&WriteRegM==RtE&&MemtoRegM&&RtE) ForwardBE=2'b10;
    	else ForwardBE=2'b00;
    reg [3:0] State;
    reg [3:0] next_state;
    always@(posedge clk)begin
        if(rst)
            State<=4'b0000;
        else
            State<=next_state;
    end
    always@(*)begin
        if(rst) next_state=4'b0000;
        else if (Exception_clean||Exception_Stall) next_state = 4'b0001;//Exception situation (clean and Stall all the Registers)
        else if (MemReadM&&((WriteRegM==RsD)||(WriteRegM==RtD))&&RegWriteM&&isaBranchInstruction) next_state = 4'b0100;//lw+use(Branch),WB-->>EX
        else if (stall && !done) next_state = 4'b1000; //stall requested by alu
        else if (State == 4'b1000) next_state = 4'b1001; //mul/div stall 1
        else if (State == 4'b1001) next_state = 4'b1010; //mul/div stall 2
        else next_state=4'b0000;
    end
    always@(next_state)begin
        case (next_state)
            4'b0000: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW}=9'b000000000;
            4'b0001: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW}=9'b111111111;
            4'b0100: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW}=9'b111100010;
            4'b1000: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW}=9'b111000010;
            4'b1001: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW}=9'b110000100;
            4'b1010: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW}=9'b110000100;
            default: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW}=9'b000000000;
        endcase
    end
        
endmodule // Hazard_detection_control