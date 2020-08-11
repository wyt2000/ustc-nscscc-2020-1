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
    input MemtoRegE,MemtoRegM,MemtoRegW,
    input ALU_stall,ALU_done,
    input RegWriteE,RegWriteM,RegWriteW,//Whether write the Register File
    input ID_exception,
    input IF_stall,MEM_stall,
    output reg StallF,StallD,StallE,StallM,StallW,
    output reg FlushD,FlushE,FlushM,FlushW,
    output reg [1:0] ForwardAD,ForwardBD,ForwardAE,ForwardBE
    );

    always@(*)
        if(rst || RsD == 0)                                         ForwardAD = 2'b00;
    	else if(RegWriteM && WriteRegM == RsD && MemtoRegM)         ForwardAD = 2'b10;  //MEM.ALUout -> ID
    	else if(RegWriteW && WriteRegW == RsD && !MemtoRegW)        ForwardAD = 2'b01;  //WB.MemData -> ID
    	else                                                        ForwardAD = 2'b00;
    always@(*)
        if(rst || RtD == 0)                                         ForwardBD = 2'b00;
    	else if(RegWriteM && WriteRegM == RtD && MemtoRegM)         ForwardBD = 2'b10;  //MEM.ALUout -> ID
    	else if(RegWriteW && WriteRegW == RtD && !MemtoRegW)        ForwardBD = 2'b01;  //WB.MemData -> ID
    	else                                                        ForwardBD = 2'b00;
    
    always@(*)
        if(rst || RsE == 0)                                         ForwardAE = 2'b00;
    	else if(RegWriteM && WriteRegM == RsE && MemtoRegM)         ForwardAE = 2'b10;  //MEM.ALUout -> EX
        else if(RegWriteW && WriteRegW == RsE && !MemtoRegW)        ForwardAE = 2'b01;  //WB.MemData -> EX
    	else                                                        ForwardAE = 2'b00;
    always@(*)
        if(rst || RtE == 0)                                         ForwardBE = 2'b00;
    	else if(RegWriteM && WriteRegM == RtE && MemtoRegM)         ForwardBE = 2'b10;  //MEM.ALUout -> EX
        else if(RegWriteW && WriteRegW == RtE && !MemtoRegW)        ForwardBE = 2'b01;  //WB.MemData -> EX
    	else                                                        ForwardBE = 2'b00;
    
    reg [3:0] State, next_state;
    always@(posedge clk) begin
        if(rst)
            State <= 4'b0000;
        else
            State <= next_state;
    end
    
    always@(*) begin
        if(rst)                                                                                                 next_state = 4'b0000;
        else if ((Exception_clean || Exception_Stall) && (IF_stall || MEM_stall))                               next_state = 4'b1110;
        else if (Exception_clean || Exception_Stall)                                                            next_state = 4'b0001;// Exception situation (clean and Stall all the Registers)
        else if ((WriteRegW[5] && !WriteRegW[6]) && RegWriteW)                                                  next_state = 4'b1111;// write_cp0 instruction in WB
        else if (MEM_stall)                                                                                     next_state = 4'b1101;// MEM operates RAM
        else if (MemReadM && ((WriteRegM == RsE) || (WriteRegM == RtE)) && RegWriteM && WriteRegM)              next_state = 4'b0101;// R-Type: wait MemData to WB
        else if (MemReadM && ((WriteRegM == RsD) || (WriteRegM == RtD)) && RegWriteM && isaBranchInstruction)   next_state = 4'b0100;// Branch: wait MemData to WB
        else if (ALU_stall && !ALU_done)                                                                        next_state = 4'b0011;// stall requested by alu
        else if ((WriteRegM[5] && !WriteRegM[6]) && RegWriteM)                                                  next_state = 4'b1000;// write_cp0 instruction in MEM
        else if (State == 4'b0011)                                                                              next_state = 4'b1001;// mul/div stall 1
        else if (State == 4'b1001)                                                                              next_state = 4'b1010;// mul/div stall 2
        else if (IF_stall && !MEM_stall)                                                                        next_state = 4'b1100;// IF operates RAM
        else if (((WriteRegE == RsD) || (WriteRegE == RtD)) && RegWriteE && isaBranchInstruction)               next_state = 4'b1100;// Branch: wait EX.ALUout to MEM
        else if ((WriteRegE[5] && !WriteRegE[6]) && RegWriteE)                                                  next_state = 4'b1100;// write_cp0 instruction in EX
        else                                                                                                    next_state = 4'b0000;
    end
    always@(next_state) begin
        case (next_state)
            4'b0000: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b000000000;
            4'b0001: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b111111111;
            4'b0100: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b111000010;
            4'b0011: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b111110001;
            4'b1000: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b110000100;
            4'b1001: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b110000100;
            4'b1010: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b110000100;
            4'b1100: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b110000100;
            4'b1101: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b111110001;
            4'b1110: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b111111110;
            4'b1111: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b111100001;
            4'b0101: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b111000010;
            default: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b000000000;
        endcase
    end

        
endmodule // Hazard_detection_control