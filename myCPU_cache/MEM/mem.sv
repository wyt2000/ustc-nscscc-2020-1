`timescale 1ns / 1ps

module MEM_module (
    input clk,
    input rst,
    input HI_LO_write_enableM,
    input [63:0] HI_LO_dataM,
    input [2:0] MemReadType,
    input RegWriteM, 
    input MemReadM,
    input MemtoRegM,
    input MemWriteM,
    input [31:0] ALUout,
    input [31:0] RamData,
    input [6:0] WriteRegister,
    input [31:0] PCin,
    output MemtoRegW,
    output RegWriteW,
    output HI_LO_write_enableW,
    output [63:0] HI_LO_dataW,
    output [31:0] ALUoutW,
    output [6:0] WriteRegisterW,
    output [31:0] PCout,
    output [2:0] MemReadTypeW,
    //exception
    input [3:0] exception_in,
    output [3:0] exception_out,
    output MemWriteW,
    //is_ds
    input is_ds_in,
    output is_ds_out,
    
    output [31:0] Memdata,

    output          data_req,
    output          data_wr,
    output  [1:0]   data_size,
    output  [31:0]  data_addr,
    output  [31:0]  data_wdata,
    input   [31:0]  data_rdata,
    input           data_addr_ok,
    input           data_data_ok,

    output          CLR,
    output          stall
    );

    reg [3:0] calWE;
    reg [31:0] TrueRamData;
    reg [31:0] reg_Memdata;

    always@(*)
    begin
        calWE = 0;
        TrueRamData = 0;
        if (exception_in != 0 || PCin[1:0] != 2'b00 || (old_exception != 0 && old_exception != 7)) calWE = 0;
        else if(MemWriteM) begin
            case (MemReadType[1:0])
                2'b00:
                    case (ALUout[1:0])
                        2'b00: begin
                            calWE = 4'b0001;
                            TrueRamData[7:0] = RamData[7:0];
                        end
                        2'b01: begin
                            calWE = 4'b0010;
                            TrueRamData[15:8] = RamData[7:0];
                        end
                        2'b10: begin
                            calWE = 4'b0100;
                            TrueRamData[23:16] = RamData[7:0];
                        end
                        2'b11: begin
                            calWE = 4'b1000;
                            TrueRamData[31:24] = RamData[7:0];
                        end
                    endcase
                2'b01:
                    case (ALUout[1:0])
                        2'b00: begin
                            calWE = 4'b0011;
                            TrueRamData[15:0] = RamData[15:0];
                        end
                        2'b10: begin
                            calWE = 4'b1100;
                            TrueRamData[31:16] = RamData[15:0];
                        end
                    endcase
                2'b10: begin
                    calWE = 4'b1111;
                    TrueRamData = RamData; 
                end
            endcase
        end
    end

    assign MemtoRegW=MemtoRegM;
    assign HI_LO_write_enableW=HI_LO_write_enableM;
    assign RegWriteW=RegWriteM;
    assign WriteRegisterW=WriteRegister;
    assign HI_LO_dataW=HI_LO_dataM;
    assign PCout = PCin;
    assign ALUoutW = ALUout;
    assign MemReadTypeW = MemReadType;
    assign exception_out = exception_in;
    assign MemWriteW = MemWriteM;
    assign is_ds_out = is_ds_in;
    
    always@(posedge clk) begin
        if(rst) begin
            reg_Memdata <= 0;
        end
        else if(data_data_ok) begin
            reg_Memdata <= data_rdata;
        end
        else begin
            reg_Memdata <= reg_Memdata;
        end
    end

    assign Memdata = data_data_ok ? data_rdata : reg_Memdata;

    data_sram   d_sram( .clk            (clk)   ,
                        .rst            (rst)   ,
                    
                        .data_req       (data_req)      ,
                        .data_wr        (data_wr)       ,
                        .data_size      (data_size)     ,
                        .data_addr      (data_addr)     ,
                        .data_wdata     (data_wdata)    ,
                        .data_rdata     (data_rdata)    ,
                        .data_addr_ok   (data_addr_ok)  ,
                        .data_data_ok   (data_data_ok)  ,
                    
                        .MemRead        (MemReadM)      ,
                        .MemWrite       (calWE)         ,
                        .addr           (ALUout)       ,
                        .wdata          (TrueRamData)   ,
                        .CLR            (CLR)           ,
                        .stall          (stall)         
                        );

    reg     [3:0] old_exception;
    always@(posedge clk)
        old_exception   <=  exception_in;
endmodule
