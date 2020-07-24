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

    // output          inst_req,
    // output          inst_wr,
    // output  [1:0]   inst_size,
    // output  [31:0]  inst_addr,
    // output  [31:0]  inst_wdata,
    // input   [31:0]  inst_rdata,
    // input           inst_addr_ok,
    // input           inst_data_ok,

    output          CLR,
    output          stall,

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
    output              instr_bready    

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
    wire    [31:0]  axi_rd_line[8];
    wire    [31:0]  axi_addr;
    wire            axi_rd_req;

    assign stall = miss;
    cache instr_cache(
        .clk            (clk),
        .rst            (rst),
        .miss           (miss),
        .addr           (PCout),
        .rd_req         (1),
        .rd_data        (instr),

        .mem_gnt        (axi_gnt),
        .ins            (axi_rd_line),
        .mem_addr       (axi_addr),
        .mem_read_req   (axi_rd_req)
    );

    axi instr_axi(
        .gnt        (axi_gnt),
        .addr       (axi_addr),
        .rd_req     (axi_rd_req),
        .rd_line    (axi_rd_line),
        .wr_req     (0),

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
    // reg [31:0] reg_instr;
    // always@(posedge clk) begin
    //     if(rst) begin
    //         reg_instr <= 0;
    //     end
    //     else if(inst_data_ok) begin
    //         reg_instr <= inst_rdata;
    //     end
    //     else begin
    //         reg_instr <= reg_instr;
    //     end
    // end
    // assign instr = inst_data_ok ? inst_rdata : reg_instr;

    // inst_sram i_sram(.clk    (clk),
    //                 .rst    (rst),
                    
    //                 .inst_req   (inst_req)  ,
    //                 .inst_wr    (inst_wr)   ,
    //                 .inst_size  (inst_size) ,
    //                 .inst_addr  (inst_addr) ,
    //                 .inst_wdata (inst_wdata),
    //                 .inst_rdata (inst_rdata),
    //                 .inst_addr_ok   (inst_addr_ok)  ,
    //                 .inst_data_ok   (inst_data_ok)  ,
                    
    //                 .is_newPC   (is_newPC)  ,
    //                 .PC         (PCout)     ,
    //                 .CLR        (CLR)       ,
    //                 .stall      (stall)     );


endmodule