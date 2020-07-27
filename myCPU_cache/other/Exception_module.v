`timescale 1ns / 1ps
    
module Exception_module(
    input clk,
    input rst,
    input address_error,
    input MemWrite,
    input overflow_error,
    input syscall,
    input _break,
    input reserved,
    input isERET,
    input [31:0] ErrorAddr,
    input is_ds,
    input [31:0] Status,
    input [31:0] Cause,
    input [31:0] pc,
    input [5:0] hardware_abortion,
    input [1:0] software_abortion,
    input [7:0] Status_IM,
    input [31:0] EPCD,
    output [7:0] Cause_IP,
    output [31:0] BadVAddr,
    output reg [31:0] EPC,
    output [31:0] we,
    output new_Status_EXL,
    output new_Cause_BD1,
    output new_Status_IE,
    output reg exception_occur,
    output reg [4:0] ExcCode,
    input StallW,
    input FlushW
    );

    wire PCError;
    wire old_IE;
    wire Status_EXL;
    reg [31:0] pc_old;

    always@(posedge clk) begin
        if(rst)
            pc_old <= 32'b0;
        else if(pc != 32'b0)
            pc_old <= pc;
    end

    assign PCError                          = (pc[1:0]!=2'b00 || (isERET && EPCD[1:0]!=2'b00)) ? 1 : 0;
    assign old_IE                           = Status[0];
    assign Status_EXL                       = Status[1];
    assign we[7:0]                          = 0;
    assign we[11:9]                         = 0;
    assign we[31:15]                        = 0;
    assign we[8]                            = (StallW && !FlushW) ? 0 : exception_occur && (address_error || PCError);
    assign we[12]                           = (StallW && !FlushW) ? 0 : exception_occur || (isERET && !PCError);
    assign we[13]                           = (StallW && !FlushW) ? 0 : exception_occur;
    assign we[14]                           = (StallW && !FlushW) ? 0 : exception_occur;
    assign Cause_IP                         = {hardware_abortion, software_abortion};
    assign new_Status_EXL                   = exception_occur;
    assign new_Cause_BD1                    = is_ds;
    assign new_Status_IE                    = ~|{hardware_abortion, software_abortion};
    assign BadVAddr                         = PCError ? (isERET ? EPCD : pc) : ErrorAddr;

    always @(*) begin
        if (|(Cause_IP & Status_IM))            ExcCode = 5'b00000;
        else if (PCError)                       ExcCode = 5'b00100; // next PC or EPC load_ex
        else if (reserved)                      ExcCode = 5'b01010;
        else if (overflow_error)                ExcCode = 5'b01100;
        else if (syscall)                       ExcCode = 5'b01000;
        else if (_break)                        ExcCode = 5'b01001;
        else if (address_error && !MemWrite)    ExcCode = 5'b00100; // mem load_ex
        else if (address_error && MemWrite)     ExcCode = 5'b00101; // store_ex
        else                                    ExcCode = 5'b00000;
    end

    always @(*) begin
        if (PCError && isERET)                                   EPC = EPCD;
        else if (|{hardware_abortion, software_abortion})        EPC = is_ds ? pc_old : pc_old + 4;
        else                                                     EPC = is_ds ? pc - 4 : pc;
    end

    always @(*) begin
        if (Status_EXL)                                                  exception_occur = 0;
        else if ( ( | (hardware_abortion & Status_IM[7:2]) ) & old_IE)   exception_occur = 1;
        else if ( ( | (software_abortion & Status_IM[1:0]) ) & old_IE)   exception_occur = 1;
        else if (PCError)                                                exception_occur = 1;
        else if (reserved)                                               exception_occur = 1;
        else if (address_error)                                          exception_occur = 1;
        else if (overflow_error)                                         exception_occur = 1;
        else if (syscall)                                                exception_occur = 1;
        else if (_break)                                                 exception_occur = 1;
        else                                                             exception_occur = 0;
    end

endmodule