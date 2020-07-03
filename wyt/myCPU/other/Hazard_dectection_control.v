module Hazard_module(
    input Exception_Stall,
    input Exception_clean,
    input BranchD,
    input isaBranchInstrution,//the signal produced by the control unit in the ID
    input [6:0] RsD,RtD,
    input [6:0] RsE,RtE,
    input [6:0] WriteRegE,WriteRegM,WriteRegW,
    input MemreadM,MemreadE,
    input MemtoRegE,MemtoRegM,
    input stall,done,
    input RegWriteE,RegWriteM,RegWriteW,//Whether write the Register File
    input [2:0] EX_exception,
    input ID_exception,
    output reg StallF,StallD,StallE,StallM,StallW,
    output reg FlushD,FlushE,FlushM,FlushW,
    output reg [1:0] forwardAD,forwardBD,forwardAE,forwardBE
);
    always@(*)
    	if(RegWriteE&&WriteRegE==RsD&&MemtoRegE) forwardAD=2'b01;
    	else if(RegWriteM&&MemreadM&&WriteRegM==RsD&&MemtoRegM==0) forwardAD=2'b10;
    	else if(RegWriteM&&WriteRegM==RsD&&MemtoRegM) forwardAD=2'b11;
    	else forwardAD=2'b00;
    always@(*)
    	if(RegWriteE&&WriteRegE==RtD&&MemtoRegE) forwardBD=2'b01;
    	else if(RegWriteM&&MemreadM&&WriteRegM==RtD&&MemtoRegM==0) forwardBD=2'b10;
    	else if(RegWriteM&&WriteRegM==RtD&&MemtoRegM) forwardBD=2'b11;
    	else forwardAD=2'b00;
    always@(*)
    	if(MemreadM&&WriteRegM==RsE&&MemtoRegM==0) forwardAE=2'b01;
    	else if(WriteRegM==RsE&&MemtoRegM) forwardAE=2'b10;
    	else forwardAE=2'b00;
    always@(*)
    	if(MemreadM&&WriteRegM==RtE&&MemtoRegM==0) forwardBE=2'b01;
    	else if(WriteRegM==RtE&&MemtoRegM) forwardBE=2'b10;
    	else forwardBE=2'b00;
    always@(*)
    	if(Exception_clean) {FlushW,FlushM,FlushE,FlushD,StallF,StallW,StallM,StallE,StallD}=9'b111111111;
    	else if(Exception_Stall||(stall&&!done)) {FlushW,FlushM,FlushE,FlushD,StallF,StallW,StallM,StallE,StallD}=9'b000011111;
    	else if(BranchD) {FlushW,FlushM,FlushE,FlushD,StallF,StallW,StallM,StallE,StallD}=9'b000100000;//branch successful
    	else if(MemreadE&&isaBranchInstrution) {FlushW,FlushM,FlushE,FlushD,StallF,StallW,StallM,StallE,StallD}=9'b000010001;//lw+beq
    	

endmodule // Hazard_detection_control