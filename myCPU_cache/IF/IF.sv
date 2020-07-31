`timescale 1ns / 1ps

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

    output          stall,

    output          inst_req,
    output          inst_wr,
    output  [1:0]   inst_size,
    output  [31:0]  inst_addr,
    output  [31:0]  inst_wdata,
    input   [31:0]  inst_rdata,
    input           inst_addr_ok,
    input           inst_data_ok,

    //=========instr axi bus=========
    //ar
    output      [3:0]   instr_arid      ,
    output      [31:0]  instr_araddr    ,
    output      [3:0]   instr_arlen     ,
    output      [2:0]   instr_arsize    ,
    output      [1:0]   instr_arburst   ,
    output      [1:0]   instr_arlock    ,
    output      [3:0]   instr_arcache   ,
    output      [2:0]   instr_arprot    ,
    output              instr_arvalid   ,
    input               instr_arready   ,
    //r
    input       [3:0]   instr_rid       ,
    input       [31:0]  instr_rdata     ,
    input       [1:0]   instr_rresp     ,
    input               instr_rlast     ,
    input               instr_rvalid    ,
    output              instr_rready    ,
    //aw
    output      [3:0]   instr_awid      ,
    output      [31:0]  instr_awaddr    ,
    output      [3:0]   instr_awlen     ,
    output      [2:0]   instr_awsize    ,
    output      [1:0]   instr_awburst   ,
    output      [1:0]   instr_awlock    ,
    output      [3:0]   instr_awcache   ,
    output      [2:0]   instr_awprot    ,
    output              instr_awvalid   ,
    input               instr_awready   ,
    //w
    output      [3:0]   instr_wid       ,
    output      [31:0]  instr_wdata     ,
    output      [3:0]   instr_wstrb     ,
    output              instr_wlast     ,
    output              instr_wvalid    ,
    input               instr_wready    ,
    //b
    input       [3:0]   instr_bid       ,
    input       [1:0]   instr_bresp     ,
    input               instr_bvalid    ,
    output              instr_bready    ,

//==========pre_fetch AXI bus==========//
    //ar
    output      [3:0]   pre_fetch_arid      ,
    output      [31:0]  pre_fetch_araddr    ,
    output      [3:0]   pre_fetch_arlen     ,
    output      [2:0]   pre_fetch_arsize    ,
    output      [1:0]   pre_fetch_arburst   ,
    output      [1:0]   pre_fetch_arlock    ,
    output      [3:0]   pre_fetch_arcache   ,
    output      [2:0]   pre_fetch_arprot    ,
    output              pre_fetch_arvalid   ,
    input               pre_fetch_arready   ,
    //r
    input       [3:0]   pre_fetch_rid       ,
    input       [31:0]  pre_fetch_rdata     ,
    input       [1:0]   pre_fetch_rresp     ,
    input               pre_fetch_rlast     ,
    input               pre_fetch_rvalid    ,
    output              pre_fetch_rready    ,
    //aw
    output      [3:0]   pre_fetch_awid      ,
    output      [31:0]  pre_fetch_awaddr    ,
    output      [3:0]   pre_fetch_awlen     ,
    output      [2:0]   pre_fetch_awsize    ,
    output      [1:0]   pre_fetch_awburst   ,
    output      [1:0]   pre_fetch_awlock    ,
    output      [3:0]   pre_fetch_awcache   ,
    output      [2:0]   pre_fetch_awprot    ,
    output              pre_fetch_awvalid   ,
    input               pre_fetch_awready   ,
    //w
    output      [3:0]   pre_fetch_wid       ,
    output      [31:0]  pre_fetch_wdata     ,
    output      [3:0]   pre_fetch_wstrb     ,
    output              pre_fetch_wlast     ,
    output              pre_fetch_wvalid    ,
    input               pre_fetch_wready    ,
    //b
    input       [3:0]   pre_fetch_bid       ,
    input       [1:0]   pre_fetch_bresp     ,
    input               pre_fetch_bvalid    ,
    output              pre_fetch_bready    

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

//==================================================================================//
    wire            miss;
    wire            axi_gnt;
    wire    [31:0]  axi_rd_line[0:7];
    reg     [31:0]  axi_addr;
    reg             axi_rd_req;
    wire            instr_rd_req_cached, instr_rd_req_uncached;
    wire    [31:0]  instr_cached, instr_uncached;
    wire            stall_uncached;
    wire    [19:0]  icache_tag;
    wire            icache_we_way[0:3];
    wire    [6 :0]  icache_tagv_index;
    wire            icache_valid;
    reg             icache_gnt;
    reg     [31:0]  icache_data[0:7];
    wire    [31:0]  icache_addr;
    wire            icache_rd_req;
    wire    [31:0]  buff_addr;
    wire    [31:0]  buff_data[0:7];
    wire            buff_ready;

    assign stall = miss || stall_uncached;
    assign instr_rd_req_cached      =   (PCout > 32'hBFFF_FFFF || PCout < 32'hA000_0000) ? 1 : 0;
    assign instr_rd_req_uncached    =   (PCout > 32'h9FFF_FFFF && PCout < 32'hC000_0000) ? is_newPC : 0;
    assign instr                    =   (PCout > 32'hBFFF_FFFF || PCout < 32'hA000_0000) ? instr_cached : instr_uncached;
    // assign instr_rd_req_cached      =   1;
    // assign instr_rd_req_uncached    =   0;
    // assign instr                    =   instr_cached;

    reg [31:0] reg_instr;
    always@(posedge clk) begin
        if(rst) begin
            reg_instr <= 0;
        end
        else if(inst_data_ok) begin
            reg_instr <= inst_rdata;
        end
        else begin
            reg_instr <= reg_instr;
        end
    end
    assign instr_uncached = inst_data_ok ? inst_rdata : reg_instr;

//==============================arbitrate part start====================================
    always@(*) begin
        if(icache_addr == buff_addr) begin
            axi_addr    =   0;
            axi_rd_req  =   0;
            icache_data =   buff_data;
            icache_gnt  =   buff_ready;
        end
        else begin
            axi_addr    =   icache_addr;
            axi_rd_req  =   icache_rd_req;
            icache_data =   axi_rd_line;
            icache_gnt  =   axi_gnt;
        end
    end
//==============================arbitrate part end  ====================================

    icache instr_cache(
        .clk            (clk),
        .rst            (rst),
        .miss           (miss),
        .addr           ({3'b000, PCout[28:0]}),
        .rd_req         (instr_rd_req_cached),
        .rd_data        (instr_cached),

        .icache_gnt     (icache_gnt),
        .icache_data    (icache_data),
        .icache_addr    (icache_addr),
        .icache_rd_req  (icache_rd_req),

        .tag            (icache_tag),
        .we_way         (icache_we_way),
        .tagv_index     (icache_tagv_index),
        .valid          (icache_valid)
    );

    axi instr_axi(
        .gnt        (axi_gnt),
        .addr       (axi_addr),
        .rd_req     (axi_rd_req),
        .rd_line    (axi_rd_line),
        .wr_req     (1'b0),

        .aclk       (clk),
        .aresetn    (!rst),

        .awid       (instr_awid),
        .awaddr     (instr_awaddr),
        .awlen      (instr_awlen),
        .awsize     (instr_awsize),
        .awburst    (instr_awburst),
        .awlock     (instr_awlock),
        .awcache    (instr_awcache),
        .awprot     (instr_awprot),
        .awvalid    (instr_awvalid),
        .awready    (instr_awready),
        .wid        (instr_wid),
        .wdata      (instr_wdata),
        .wstrb      (instr_wstrb),
        .wlast      (instr_wlast),
        .wvalid     (instr_wvalid),
        .wready     (instr_wready),
        .bid        (instr_bid),
        .bresp      (instr_bresp),
        .bvalid     (instr_bvalid),
        .bready     (instr_bready),
        .arid       (instr_arid),
        .araddr     (instr_araddr),
        .arlen      (instr_arlen),
        .arsize     (instr_arsize),
        .arburst    (instr_arburst),
        .arlock     (instr_arlock),
        .arcache    (instr_arcache),
        .arprot     (instr_arprot),
        .arvalid    (instr_arvalid),
        .arready    (instr_arready),
        .rid        (instr_rid),
        .rdata      (instr_rdata),
        .rresp      (instr_rresp),
        .rlast      (instr_rlast),
        .rvalid     (instr_rvalid),
        .rready     (instr_rready)
    );

    inst_sram i_sram(.clk           (clk),
                    .rst            (rst),
                    
                    .inst_req       (inst_req)  ,
                    .inst_wr        (inst_wr)   ,
                    .inst_size      (inst_size) ,
                    .inst_addr      (inst_addr) ,
                    .inst_wdata     (inst_wdata),
                    .inst_rdata     (inst_rdata),
                    .inst_addr_ok   (inst_addr_ok)  ,
                    .inst_data_ok   (inst_data_ok)  ,
                    
                    .is_newPC       (instr_rd_req_uncached)  ,
                    .PC             ( {3'b000, PCout[28:0]} )     ,
                    .stall          (stall_uncached)     
                    );

    pre_fetch icache_pre_fetch(
        .clk        (clk),
        .rst        (rst),

        .tag        (icache_tag),
        .we_way     (icache_we_way),
        .tagv_index (icache_tagv_index),
        .valid      (icache_valid),
        .miss       (miss),

        .rd_req     (instr_rd_req_cached),
        .rd_addr    ({3'b000, PCout[28:0]}),

        .buff_addr  (buff_addr),
        .buff_data  (buff_data),
        .buff_ready (buff_ready),

        .arid       (pre_fetch_arid),
        .araddr     (pre_fetch_araddr),
        .arlen      (pre_fetch_arlen),
        .arsize     (pre_fetch_arsize),
        .arburst    (pre_fetch_arburst),
        .arlock     (pre_fetch_arlock),
        .arcache    (pre_fetch_arcache),
        .arprot     (pre_fetch_arprot),
        .arvalid    (pre_fetch_arvalid),
        .arready    (pre_fetch_arready),
        .rid        (pre_fetch_rid),
        .rdata      (pre_fetch_rdata),
        .rresp      (pre_fetch_rresp),
        .rlast      (pre_fetch_rlast),
        .rvalid     (pre_fetch_rvalid),
        .rready     (pre_fetch_rready),
        .awid       (pre_fetch_awid),
        .awaddr     (pre_fetch_awaddr),
        .awlen      (pre_fetch_awlen),
        .awsize     (pre_fetch_awsize),
        .awburst    (pre_fetch_awburst),
        .awlock     (pre_fetch_awlock),
        .awcache    (pre_fetch_awcache),
        .awprot     (pre_fetch_awprot),
        .awvalid    (pre_fetch_awvalid),
        .awready    (pre_fetch_awready),
        .wid        (pre_fetch_wid),
        .wdata      (pre_fetch_wdata),
        .wstrb      (pre_fetch_wstrb),
        .wlast      (pre_fetch_wlast),
        .wvalid     (pre_fetch_wvalid),
        .wready     (pre_fetch_wready),
        .bid        (pre_fetch_bid),
        .bresp      (pre_fetch_bresp),
        .bvalid     (pre_fetch_bvalid),
        .bready     (pre_fetch_bready)
    );
    

endmodule