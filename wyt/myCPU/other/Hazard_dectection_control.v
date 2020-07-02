module Hazard_module(
    input rst,
    input Exception_Stall,
    input Exception_clean,
    input BranchD,
    input isaBranchInstrution,//the signal produced by the control unit in the ID
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
    always@(*)
        if(rst || RsD == 0) ForwardAD=2'b00;
    	else if(RegWriteE&&WriteRegE==RsD&&MemtoRegE) ForwardAD=2'b01;
    	else if(RegWriteM&&MemReadM&&WriteRegM==RsD&&MemtoRegM==0) ForwardAD=2'b10;
    	else if(RegWriteM&&WriteRegM==RsD&&MemtoRegM) ForwardAD=2'b11;
    	else ForwardAD=2'b00;
    always@(*)
    	if(rst || RtD == 0) ForwardBD=2'b00;
        else if(RegWriteE&&WriteRegE==RtD&&MemtoRegE) ForwardBD=2'b01;
    	else if(RegWriteM&&MemReadM&&WriteRegM==RtD&&MemtoRegM==0) ForwardBD=2'b10;
    	else if(RegWriteM&&WriteRegM==RtD&&MemtoRegM) ForwardBD=2'b11;
    	else ForwardBD=2'b00;
    always@(*)
        if(rst || RsE == 0) ForwardAE=2'b00;
    	else if(MemReadM&&WriteRegM==RsE&&MemtoRegM==0) ForwardAE=2'b01;
    	else if(WriteRegM==RsE&&MemtoRegM) ForwardAE=2'b10;
    	else ForwardAE=2'b00;
    always@(*)
        if(rst || RtE == 0) ForwardBE=2'b00;
    	else if(MemReadM&&WriteRegM==RtE&&MemtoRegM==0) ForwardBE=2'b01;
    	else if(WriteRegM==RtE&&MemtoRegM) ForwardBE=2'b10;
    	else ForwardBE=2'b00;
    always@(*)
        if(rst) {FlushW,FlushM,FlushE,FlushD,StallF,StallW,StallM,StallE,StallD} = 9'b000000000;
    	else if(Exception_clean) {FlushW,FlushM,FlushE,FlushD,StallF,StallW,StallM,StallE,StallD} = 9'b111111111;
    	else if(Exception_Stall||(stall&&!done)) {FlushW,FlushM,FlushE,FlushD,StallF,StallW,StallM,StallE,StallD} = 9'b000011111;
    	else if(BranchD) {FlushW,FlushM,FlushE,FlushD,StallF,StallW,StallM,StallE,StallD} = 9'b000100000;//branch successful
    	else if(MemReadE&&isaBranchInstrution) {FlushW,FlushM,FlushE,FlushD,StallF,StallW,StallM,StallE,StallD} = 9'b000010001;//lw+beq
        else {FlushW,FlushM,FlushE,FlushD,StallF,StallW,StallM,StallE,StallD} = 9'b000000000;
endmodule // Hazard_detection_control