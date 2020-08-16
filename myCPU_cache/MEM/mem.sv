`timescale 1ns / 1ps
`define MAP_UNCACHED
`include "../other/aluop.vh"

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
    output reg [3:0] exception_out,
    output MemWriteW,
    //is_ds
    input is_ds_in,
    output is_ds_out,
    input TLB_we_in,
    output TLB_we_out,
    input [1:0] TLB_CP0we_in,
    output [1:0] TLB_CP0we_out,
    
    output [31:0] WritetoRFdata,

    output          mem_req,
    output          mem_wr,
    output  [1:0]   mem_size,
    output  [31:0]  mem_addr,
    output  [31:0]  mem_wdata,
    input   [31:0]  mem_rdata,
    input           mem_addr_ok,
    input           mem_data_ok,

    output          CLR,
    output          stall,

//=========data axi bus=========
    //ar
    output      [3:0]   data_arid      ,
    output      [31:0]  data_araddr    ,
    output      [3:0]   data_arlen     ,
    output      [2:0]   data_arsize    ,
    output      [1:0]   data_arburst   ,
    output      [1:0]   data_arlock    ,
    output      [3:0]   data_arcache   ,
    output      [2:0]   data_arprot    ,
    output              data_arvalid   ,
    input               data_arready   ,
    //r
    input       [3:0]   data_rid       ,
    input       [31:0]  data_rdata     ,
    input       [1:0]   data_rresp     ,
    input               data_rlast     ,
    input               data_rvalid    ,
    output              data_rready    ,
    //aw
    output      [3:0]   data_awid      ,
    output      [31:0]  data_awaddr    ,
    output      [3:0]   data_awlen     ,
    output      [2:0]   data_awsize    ,
    output      [1:0]   data_awburst   ,
    output      [1:0]   data_awlock    ,
    output      [3:0]   data_awcache   ,
    output      [2:0]   data_awprot    ,
    output              data_awvalid   ,
    input               data_awready   ,
    //w
    output      [3:0]   data_wid       ,
    output      [31:0]  data_wdata     ,
    output      [3:0]   data_wstrb     ,
    output              data_wlast     ,
    output              data_wvalid    ,
    input               data_wready    ,
    //b
    input       [3:0]   data_bid       ,
    input       [1:0]   data_bresp     ,
    input               data_bvalid    ,
    output              data_bready    ,
    output  reg [3:0]   reg_file_byte_we

    //TLB ports
    // output      [31:0]  data_vaddr,
    // input       [31:0]  data_paddr,
    // input               data_avalid,
    // input               data_amiss,
    // input               data_adirty,
    // input       [2:0]   data_acache
    );

    reg [3:0] calWE;
    reg [31:0] TrueRamData;
    reg [31:0] Memdata;
    reg [31:0] reg_Memdata;
    reg [31:0] TrueMemData;
    reg TrueMemWrite;

    reg     [3:0] old_exception;
    always@(posedge clk) begin
        if(rst) begin
            old_exception <= 0;
        end
        else begin
            old_exception   <=  exception_in;
        end
    end

    always@(*)
    begin
        calWE = 0;
        TrueRamData = 0;
        TrueMemWrite = MemWriteM;
        if (exception_in != 0 || PCin[1:0] != 2'b00 || (old_exception != 0 && old_exception != 7)) begin
            TrueMemWrite = 0;
        end 
        else begin
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
                2'b11: begin    //unaligned store
                    case (MemReadType[1:0])
                        1'b0: begin     //swl
                            case (ALUout[1:0])
                                2'b00: begin
                                    calWE = 4'b0001;
                                    TrueRamData[7:0] = RamData[31:24];
                                end
                                2'b01: begin
                                    calWE = 4'b0011;
                                    TrueRamData[15:0] = RamData[31:16];
                                end
                                2'b10: begin
                                    calWE = 4'b0111;
                                    TrueRamData[23:0] = RamData[31:8];
                                end
                                2'b11: begin
                                    calWE = 4'b1111;
                                    TrueRamData = RamData;
                                end
                            endcase
                        end
                        1'b1: begin     //swr
                            case (ALUout[1:0])
                                2'b00: begin
                                    calWE = 4'b1111;
                                    TrueRamData = RamData;
                                end
                                2'b01: begin
                                    calWE = 4'b1110;
                                    TrueRamData[31:8] = RamData[23:0];
                                end
                                2'b10: begin
                                    calWE = 4'b1100;
                                    TrueRamData[31:16] = RamData[15:0];
                                end
                                2'b11: begin
                                    calWE = 4'b1000;
                                    TrueRamData[31:24] = RamData[7:0];
                                end
                            endcase
                        end
                    endcase
                end
            endcase
        end
    end

    assign MemtoRegW = MemtoRegM;
    assign HI_LO_write_enableW=HI_LO_write_enableM;
    assign RegWriteW=RegWriteM;
    assign WriteRegisterW=WriteRegister;
    assign HI_LO_dataW=HI_LO_dataM;
    assign PCout = PCin;
    assign ALUoutW = ALUout;
    assign MemReadTypeW = MemReadType;
    // assign exception_out = exception_in;
    assign MemWriteW = MemWriteM;
    assign is_ds_out = is_ds_in;
    assign WritetoRFdata = MemtoRegM ? ALUout : TrueMemData;
    assign TLB_we_out = TLB_we_in;
    assign TLB_CP0we_out = TLB_CP0we_in;
//==================================================================================//
    wire            miss;
    wire            axi_gnt;
    wire    [31:0]  axi_rd_line[0:15];
    wire    [31:0]  axi_addr;
    wire            axi_rd_req;
    wire    [31:0]  axi_wr_line[0:15];
    wire            axi_wr_req;
    reg             MemRead_cache, MemRead_uncache;
    reg             MemWrite_cache, MemWrite_uncache;
    reg    [31:0]   Memdata_cache,  Memdata_uncache;
    wire            stall_uncache;
    reg     [31:0]  rd_addr;

    `ifdef MAP_UNCACHED
        always@(*) begin
            exception_out    =   exception_in;
            MemRead_cache    =   ((ALUout < 32'hA000_0000) || (ALUout > 32'hBFFF_FFFF)) ? MemReadM : 0;
            MemRead_uncache  =   ((ALUout > 32'h9FFF_FFFF) && (ALUout < 32'hC000_0000)) ? MemReadM : 0;
            MemWrite_cache   =   ((ALUout < 32'hA000_0000) || (ALUout > 32'hBFFF_FFFF)) ? TrueMemWrite : 0;
            MemWrite_uncache =   ((ALUout > 32'h9FFF_FFFF) && (ALUout < 32'hC000_0000)) ? TrueMemWrite : 0;
            Memdata          =   ((ALUout < 32'hA000_0000) || (ALUout > 32'hBFFF_FFFF)) ? Memdata_cache : Memdata_uncache;
            rd_addr          =   {3'b000, ALUout[28:0]};
        end

        // always@(*) begin
        //     exception_out       =   exception_in;
        //     MemRead_cache       =   0;
        //     MemRead_uncache     =   0;
        //     MemWrite_cache      =   0;
        //     MemWrite_uncache    =   0;
        //     Memdata             =   0;
        //     rd_addr             =   0;
        //     if((ALUout > 32'h9FFF_FFFF && ALUout < 32'hC000_0000)) begin
        //         MemRead_uncache     =   MemReadM;
        //         MemWrite_uncache    =   TrueMemWrite;
        //         Memdata             =   Memdata_uncache;
        //         rd_addr             =   {3'b000, ALUout[28:2], 2'b00};
        //     end
        //     else if((ALUout > 32'h7FFF_FFFF && ALUout < 32'hA000_0000)) begin
        //         MemRead_cache       =   MemReadM;
        //         MemWrite_cache      =   TrueMemWrite;
        //         Memdata             =   Memdata_cache;
        //         rd_addr             =   {3'b000, ALUout[28:2], 2'b00};
        //     end
        //     else if(data_avalid && ~data_amiss) begin
        //         if(~(TrueMemWrite && ~data_adirty)) begin
        //             if(data_acache == 3'd3) begin
        //                 MemRead_cache   =   MemReadM;
        //                 MemWrite_cache  =   TrueMemWrite;
        //                 Memdata         =   Memdata_cache;
        //                 rd_addr         =   data_paddr;
        //             end
        //             else begin
        //                 MemRead_uncache =   MemReadM;
        //                 MemWrite_uncache=   TrueMemWrite;
        //                 Memdata         =   Memdata_uncache;
        //                 rd_addr         =   data_paddr;
        //             end
        //         end
        //         else begin
        //             if(exception_in == 0 && TrueMemWrite)
        //                 exception_out = `EXP_DTLBM;
        //         end
        //     end
        //     else begin
        //         if(data_amiss && exception_in == 0 && (MemReadM || TrueMemWrite))
        //             exception_out = `EXP_DTLBR;
        //         else if(exception_in == 0 && ~data_avalid && (MemReadM || TrueMemWrite))
        //             exception_out = `EXP_DTLBI;
        //     end
        // end
    `else
        always@(*) begin
            exception_out           =   exception_in;
            MemRead_cache           =   ({3'b000,ALUout[28:0]} < 32'h1faf0000) || ({3'b000,ALUout[28:0]} > 32'h1fafffff) ? MemReadM : 0;
            MemRead_uncache         =   ({3'b000,ALUout[28:0]} > 32'h1faf0000) && ({3'b000,ALUout[28:0]} < 32'h1fafffff) ? MemReadM : 0;
            MemWrite_cache          =   ({3'b000,ALUout[28:0]} < 32'h1faf0000) || ({3'b000,ALUout[28:0]} > 32'h1fafffff) ? TrueMemWrite : 0;
            MemWrite_uncache        =   ({3'b000,ALUout[28:0]} > 32'h1faf0000) && ({3'b000,ALUout[28:0]} < 32'h1fafffff) ? TrueMemWrite : 0;
            Memdata                 =   ({3'b000,ALUout[28:0]} < 32'h1faf0000) || ({3'b000,ALUout[28:0]} > 32'h1fafffff) ? Memdata_cache : Memdata_uncache;
            rd_addr                 =   {3'b000, ALUout[28:0]};
        end
    `endif

    assign stall = miss || stall_uncache;
    assign data_vaddr = {ALUout[31:2], 2'b00};
    dcache data_cache(
        .clk            (clk),
        .rst            (rst),

        .miss           (miss),
        .addr           (rd_addr),
        .rd_req         (MemRead_cache),
        .rd_data        (Memdata_cache),
        .wr_req         (MemWrite_cache),
        .wr_data        (TrueRamData),
        .valid_lane     (calWE),

        .axi_gnt        (axi_gnt),
        .axi_addr       (axi_addr),
        .axi_rd_req     (axi_rd_req),
        .axi_rd_data    (axi_rd_line),
        .axi_wr_req     (axi_wr_req),
        .axi_wr_data    (axi_wr_line)
    );

    axi #(4) data_axi(
        .gnt        (axi_gnt),
        .addr       (axi_addr),
        .rd_req     (axi_rd_req),
        .rd_line    (axi_rd_line),
        .wr_req     (axi_wr_req),
        .wr_line    (axi_wr_line),

        .aclk       (clk),
        .aresetn    (!rst),

        .awid       (data_awid),
        .awaddr     (data_awaddr),
        .awlen      (data_awlen),
        .awsize     (data_awsize),
        .awburst    (data_awburst),
        .awlock     (data_awlock),
        .awcache    (data_awcache),
        .awprot     (data_awprot),
        .awvalid    (data_awvalid),
        .awready    (data_awready),
        .wid        (data_wid),
        .wdata      (data_wdata),
        .wstrb      (data_wstrb),
        .wlast      (data_wlast),
        .wvalid     (data_wvalid),
        .wready     (data_wready),
        .bid        (data_bid),
        .bresp      (data_bresp),
        .bvalid     (data_bvalid),
        .bready     (data_bready),
        .arid       (data_arid),
        .araddr     (data_araddr),
        .arlen      (data_arlen),
        .arsize     (data_arsize),
        .arburst    (data_arburst),
        .arlock     (data_arlock),
        .arcache    (data_arcache),
        .arprot     (data_arprot),
        .arvalid    (data_arvalid),
        .arready    (data_arready),
        .rid        (data_rid),
        .rdata      (data_rdata),
        .rresp      (data_rresp),
        .rlast      (data_rlast),
        .rvalid     (data_rvalid),
        .rready     (data_rready)
    );


    always@(posedge clk) begin
        if(rst) begin
            reg_Memdata <= 0;
        end
        else if(mem_data_ok) begin
            reg_Memdata <= data_rdata;
        end
        else begin
            reg_Memdata <= reg_Memdata;
        end
    end

    assign Memdata_uncache = mem_data_ok ? mem_rdata : reg_Memdata;

    data_sram   d_sram( .clk            (clk)   ,
                        .rst            (rst)   ,
                    
                        .data_req       (mem_req)      ,
                        .data_wr        (mem_wr)       ,
                        .data_size      (mem_size)     ,
                        .data_addr      (mem_addr)     ,
                        .data_wdata     (mem_wdata)    ,
                        .data_rdata     (mem_rdata)    ,
                        .data_addr_ok   (mem_addr_ok)  ,
                        .data_data_ok   (mem_data_ok)  ,
                    
                        .MemRead        (MemRead_uncache)      ,
                        .MemWrite       (MemWrite_uncache)  ,
                        .calWE          (calWE)         ,
                        .addr           (rd_addr)        ,
                        .wdata          (TrueRamData)   ,
                        .CLR            (CLR)           ,
                        .stall          (stall_uncache)         
                        );
    
    always @(*) begin
        TrueMemData = Memdata;
        reg_file_byte_we = 4'b1111;
        case (MemReadType[1:0])
            2'b00: begin
                case (ALUout[1:0])
                    2'b00: TrueMemData = MemReadType[2] ? {{24{Memdata[7]}},Memdata[7:0]} : {24'b0,Memdata[7:0]};
                    2'b01: TrueMemData = MemReadType[2] ? {{24{Memdata[15]}},Memdata[15:8]} : {24'b0,Memdata[15:8]};
                    2'b10: TrueMemData = MemReadType[2] ? {{24{Memdata[23]}},Memdata[23:16]} : {24'b0,Memdata[23:16]};
                    2'b11: TrueMemData = MemReadType[2] ? {{24{Memdata[31]}},Memdata[31:24]} : {24'b0,Memdata[31:24]};
                endcase
            end
            2'b01: begin
                case (ALUout[1:0])
                    2'b00: TrueMemData = MemReadType[2] ? {{16{Memdata[15]}},Memdata[15:0]} : {16'b0,Memdata[15:0]};
                    2'b10: TrueMemData = MemReadType[2] ? {{16{Memdata[31]}},Memdata[31:16]} : {16'b0,Memdata[31:16]};
                endcase
            end
                        2'b11: begin    //unaligned load
                case (MemReadType[2])
                    1'b0: begin     //lwl
                        case (ALUout)
                            2'b00: begin
                                reg_file_byte_we = 4'b1000;
                                TrueMemData[31:24] = Memdata[7:0];
                            end
                            2'b01: begin
                                reg_file_byte_we = 4'b1100;
                                TrueMemData[31:16] = Memdata[15:0];
                            end
                            2'b10: begin
                                reg_file_byte_we = 4'b1110;
                                TrueMemData[31:8] = Memdata[23:0];
                            end
                            2'b11: begin
                                reg_file_byte_we = 4'b1111;
                                TrueMemData = Memdata;
                            end
                        endcase
                    end
                    1'b1: begin     //lwr
                        case (ALUout)
                            2'b00: begin
                                reg_file_byte_we = 4'b1111;
                                TrueMemData = Memdata;
                            end
                            2'b01: begin
                                reg_file_byte_we = 4'b0111;
                                TrueMemData[23:0] = Memdata[31:8];
                            end
                            2'b10: begin
                                reg_file_byte_we = 4'b0011;
                                TrueMemData[15:0] = Memdata[31:16];
                            end
                            2'b11: begin
                                reg_file_byte_we = 4'b0001;
                                TrueMemData[7:0] = Memdata[31:24];
                            end
                        endcase
                    end
                endcase
            end
        endcase
    end
      
endmodule
