`include "../other/stall.vh"
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
    input IF_stall, MEM_stall,
    input EX_HILOwe, MEM_HILOwe,
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
    
    reg [3:0] state;
    
    always@(*) begin
        if (rst)                                                                                                state = `STALL_IDLE;
        else if ((Exception_clean || Exception_Stall) && (IF_stall || MEM_stall))                               state = `CLEAN_ALL_1; //Exception: hold WB.Exception
        else if (Exception_clean || Exception_Stall)                                                            state = `CLEAN_ALL_2; //Exception: clean all registers
        else if (ALU_stall && !ALU_done)                                                                        state = `STALL_ALL; //mul/div: stall all pipeline
        else if (MEM_stall)                                                                                     state = `STALL_ALL; //load/store: stall all pipeline
        else if (MemReadM && ((WriteRegM == RsE) || (WriteRegM == RtE)) && RegWriteM && WriteRegM)              state = `STALL_EX;  //R-Type: wait MemData to WB
        else if (MemReadM && ((WriteRegM == RsD) || (WriteRegM == RtD)) && RegWriteM && isaBranchInstruction)   state = `STALL_ID;  //Branch: wait MemData to WB
        else if (((WriteRegE == RsD) || (WriteRegE == RtD)) && RegWriteE && isaBranchInstruction)               state = `STALL_ID;  //Branch: wait EX.ALUout to MEM
        else if ((WriteRegE[5] && !WriteRegE[6]) && RegWriteE)                                                  state = `STALL_ID;  //mtc0: in EX
        else if ((WriteRegM[5] && !WriteRegM[6]) && RegWriteM)                                                  state = `STALL_ID;  //mtc0: in MEM
        else if ((WriteRegW[5] && !WriteRegW[6]) && RegWriteW)                                                  state = `STALL_ID;  //mtc0: in WB
        else if (EX_HILOwe)                                                                                     state = `STALL_ID;  //mul/div: in MEM
        else if (MEM_HILOwe)                                                                                    state = `STALL_ID;  //mul/div: in WB
        else if (IF_stall)                                                                                      state = `STALL_ID;  //IF operates RAM
        else                                                                                                    state = `STALL_IDLE;
    end

    always@(state) begin
        case (state)
            `STALL_IDLE: {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b000000000;
            `CLEAN_ALL_1:{StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b111111110;
            `CLEAN_ALL_2:{StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b111111111;
            `STALL_ALL:  {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b111110001;
            `STALL_EX:   {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b111000010;
            `STALL_ID:   {StallF,StallD,StallE,StallM,StallW,FlushD,FlushE,FlushM,FlushW} = 9'b110000100;
        endcase
    end

        
endmodule // Hazard_detection_control