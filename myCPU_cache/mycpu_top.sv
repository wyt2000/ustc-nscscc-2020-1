`timescale 1ns / 1ps
`include "./other/aluop.vh"

typedef struct packed {
    //Input
    logic Jump;
    logic BranchD;
    logic EPC_sel;
    logic [31:0] EPC;
    logic [31:0] Jump_reg;
    logic [31:0] Jump_addr;
    logic [31:0] beq_addr;
    logic StallF;
    logic Error_happend;
    //output
    logic [31:0] PC_add_4;
    logic [31:0] PCout;

    logic is_newPC;
    
    logic [31:0] instr;
    logic stall;
    
//========instr axi bus========
    //ar
    logic       [3:0]   instr_arid      ;
    logic       [31:0]  instr_araddr    ;
    logic       [3:0]   instr_arlen     ;
    logic       [2:0]   instr_arsize    ;
    logic       [1:0]   instr_arburst   ;
    logic       [1:0]   instr_arlock    ;
    logic       [3:0]   instr_arcache   ;
    logic       [2:0]   instr_arprot    ;
    logic               instr_arvalid   ;
    logic               instr_arready   ;
    //r
    logic       [3:0]   instr_rid       ;
    logic       [31:0]  instr_rdata     ;
    logic       [1:0]   instr_rresp     ;
    logic               instr_rlast     ;
    logic               instr_rvalid    ;
    logic               instr_rready    ;
    //aw
    logic       [3:0]   instr_awid      ;
    logic       [31:0]  instr_awaddr    ;
    logic       [3:0]   instr_awlen     ;
    logic       [2:0]   instr_awsize    ;
    logic       [1:0]   instr_awburst   ;
    logic       [1:0]   instr_awlock    ;
    logic       [3:0]   instr_awcache   ;
    logic       [2:0]   instr_awprot    ;
    logic               instr_awvalid   ;
    logic               instr_awready   ;
    //w
    logic       [3:0]   instr_wid       ;
    logic       [31:0]  instr_wdata     ;
    logic       [3:0]   instr_wstrb     ;
    logic               instr_wlast     ;
    logic               instr_wvalid    ;
    logic               instr_wready    ;
    //b
    logic       [3:0]   instr_bid       ;
    logic       [1:0]   instr_bresp     ;
    logic               instr_bvalid    ;
    logic               instr_bready    ;

} IF_interface;

typedef struct packed {
    //input
    logic [31:0] instr;
    logic [31:0] pc_plus_4;
    logic RegWriteW;
    logic [6:0] WriteRegW;
    logic [31:0] ResultW;
    logic HI_LO_write_enable_from_WB;
    logic [63:0] HI_LO_data;
    logic [31:0] ALUoutE;
    logic [31:0] ALUoutM;
    logic [1:0] ForwardAD;
    logic [1:0] ForwardBD;
    logic [31:0] PCin;
	logic [31:0] EPCin;
    //output
    logic [5:0] ALUOp;
    logic ALUSrcDA;
    logic ALUSrcDB;
    logic RegDstD;
    logic MemReadD;
    logic [2:0] MemReadType;
    logic MemWriteD;
    logic MemtoRegD;
    logic HI_LO_write_enableD;
    logic RegWriteD;
    logic Imm_sel;
    logic [31:0] RsValue;
    logic [31:0] RtValue;
    logic [31:0] pc_plus_8;
    logic [6:0] Rs;
    logic [6:0] Rt;
    logic [6:0] Rd;
    logic [15:0] imm;
    logic EPC_sel;
    logic BranchD;
    logic Jump;
    logic [31:0] PCSrc_reg;
    logic [31:0] EPCout;
    logic new_IE;
    logic [31:0] Jump_addr;
    logic [31:0] Branch_addr;
    logic exception;
    logic isBranch;
    logic [31:0] PCout;
    logic [31:0]  Status;
    logic [31:0]  cause;
    logic [31:0]  we;
    logic [4:0]   Exception_code;
    logic Exception_EXL;
    logic [5:0]   hardware_interruption;
    logic [1:0]   software_interruption;
    logic [31:0]  BADADDR;
    logic Branch_delay;
    logic is_ds;
    logic StallD;
} ID_interface;

typedef struct packed {
    //input
    logic hiloWrite_i;
    logic [2:0] MemReadType_i;
    logic MemRead_i;
    logic RegWrite_i;
    logic MemtoReg_i;
    logic MemWrite_i;
    logic [5:0] ALUControl;
    logic ALUSrcA;
    logic ALUSrcB;
    logic RegDst;
    logic immSel;
    logic [31:0] A;
    logic [31:0] B;
    logic [31:0] PCplus8;
    logic [6:0] Rs;
    logic [6:0] Rt;
    logic [6:0] Rd;
    logic [31:0] imm;
    logic [31:0] ForwardMEM;
    logic [31:0] ForwardWB;
    logic [1:0] ForwardA;
    logic [1:0] ForwardB;
    logic [31:0] PCin;
    //output
    logic hiloWrite_o;
    logic [2:0] MemReadType_o;
    logic MemRead_o;
    logic RegWrite_o;
    logic MemtoReg_o;
    logic MemWrite_o;
    logic [63:0] hiloData;
    logic [31:0] ALUResult;
    logic [31:0] MemData;
    logic [6:0] WriteRegister;
    logic [6:0] Rs_o;
    logic [6:0] Rt_o;
    logic done;
    logic [3:0] exception;
    logic stall;
    logic [31:0] PCout;
    logic exceptionD;
    logic is_ds_in;
    logic is_ds_out;
} EX_interface;

typedef struct packed {
    //input
    logic HI_LO_write_enableM;
    logic [63:0] HI_LO_dataM;
    logic MemtoRegM;
    logic RegWriteM;
    logic MemReadM;
    logic MemWriteM;
    logic [31:0] ALUout;
    logic [31:0] RamData;
    logic [6:0] WriteRegister;
    logic [2:0] MemReadType;
    logic [31:0] PCin;
    //output
    logic MemtoRegW;
    logic RegWriteW;
    logic HI_LO_write_enableW;
    logic [63:0] HI_LO_dataW;
    logic [31:0] ALUoutW;
    logic [6:0] WriteRegisterW;
    logic [31:0] PCout;
    logic [2:0] MemReadTypeW;
    logic [3:0] exception_in;
    logic [3:0] exception_out;
    logic MemWriteW;
    logic is_ds_in;
    logic is_ds_out;

    logic [31:0] Memdata;

    logic data_req;
    logic data_wr;
    logic [1:0] data_size;
    logic [31:0] data_addr;
    logic [31:0] data_wdata;
    logic [31:0] data_rdata;
    logic data_addr_ok;
    logic data_data_ok;

    logic CLR;
    logic stall;

} MEM_interface;

typedef struct packed {
    //input
    logic [31:0] aluout;
    logic [31:0] Memdata;
    logic MemtoRegW;
    logic RegWriteW;
    logic [6:0] WritetoRFaddrin;
    logic [63:0] HILO_data;
    logic HI_LO_writeenablein;
    logic [31:0] PCin;
    logic [2:0] MemReadTypeW;
    //output
    logic [6:0] WritetoRFaddrout;
    logic [31:0] WritetoRFdata;
    logic HI_LO_writeenableout;
    logic [63:0] WriteinRF_HI_LO_data;
    logic RegWrite;
    logic [31:0] PCout;
    logic [3:0] exception_in;
    logic [3:0] exception_out;
    logic MemWrite;
    logic MemWriteW;
    logic is_ds_in;
    logic is_ds_out;
	logic [31:0] EPCD;
} WB_interface;

typedef struct packed {
    //input
    logic BranchD;
    logic [6:0] RsD;
    logic [6:0] RtD;
    logic ID_exception;
    logic [6:0] RsE;
    logic [6:0] RtE;
    logic MemReadE;
    logic MemtoRegE;
    logic [3:0] EX_exception;
    logic ALU_stall;
    logic ALU_done;
    logic Exception_Stall;
    logic Exception_clean;
    logic RegWriteM;
    logic [6:0] WriteRegM;
    logic MemReadM;
    logic MemtoRegM;
    logic RegWriteW;
    logic [6:0] WriteRegW;
    logic isaBranchInstruction;
    logic [6:0] WriteRegE;
    logic RegWriteE;
    //output
    logic StallF;
    logic StallD;
    logic StallE;
    logic StallM;
    logic StallW;
    logic FlushD;
    logic FlushE;
    logic FlushM;
    logic FlushW;
    logic [1:0] ForwardAD;
    logic [1:0] ForwardBD;
    logic [1:0] ForwardAE;
    logic [1:0] ForwardBE;

    logic IF_stall;
    logic MEM_stall;
} Hazard_interface;

typedef struct packed{
    //input
    logic address_error;
    logic MemWrite;
    logic overflow_error;
    logic reserved;
    logic [5:0] hardware_abortion;//硬件中断
    logic [1:0] software_abortion;//软件中断
    logic [31:0] Status;//Status寄存器当前的值
    logic [31:0] Cause;//Cause寄存器当前的值
    logic [31:0] pc;//错误指令pc
    //output
    logic [31:0] BadVAddr;//输出置BadVaddr
    logic [31:0] EPC;//输出置EPC
    //epc
    logic [31:0] we;//写使能字
    logic Branch_delay;//给cause寄存器赋新值
    logic Stall;//异常发生（Stall，Clear）
    logic EXL;
    logic [7:0] enable;
    logic new_Status_IE;//给Status寄存器赋新值
    logic [7:0] Status_IM;//给Status寄存器赋新值
    logic [4:0] ExcCode;//异常编码
    logic [31:0] ErrorAddr;
    logic isERET;
    logic is_ds;
	logic [31:0] EPCD;
	logic syscall;
	logic _break;
    logic StallW;
    logic FlushW;
} Exception_interface;

typedef struct packed{

    //inst sram-like 
    logic         inst_req     ;
    logic         inst_wr      ;
    logic  [1 :0] inst_size    ;
    logic  [31:0] inst_addr    ;
    logic  [31:0] inst_wdata   ;
    logic [31:0] inst_rdata   ;
    logic        inst_addr_ok ;
    logic        inst_data_ok ;
    
    //data sram-like 
    logic         data_req     ;
    logic         data_wr      ;
    logic  [1 :0] data_size    ;
    logic  [31:0] data_addr    ;
    logic  [31:0] data_wdata   ;
    logic [31:0] data_rdata   ;
    logic        data_addr_ok ;
    logic        data_data_ok ;

    //axi
    //ar
    logic [3 :0] arid         ;
    logic [31:0] araddr       ;
    logic [3 :0] arlen        ;
    logic [2 :0] arsize       ;
    logic [1 :0] arburst      ;
    logic [1 :0] arlock        ;
    logic [3 :0] arcache      ;
    logic [2 :0] arprot       ;
    logic        arvalid      ;
    logic         arready      ;
    //r           
    logic  [3 :0] rid          ;
    logic  [31:0] rdata        ;
    logic  [1 :0] rresp        ;
    logic         rlast        ;
    logic         rvalid       ;
    logic        rready       ;
    //aw          
    logic [3 :0] awid         ;
    logic [31:0] awaddr       ;
    logic [3 :0] awlen        ;
    logic [2 :0] awsize       ;
    logic [1 :0] awburst      ;
    logic [1 :0] awlock       ;
    logic [3 :0] awcache      ;
    logic [2 :0] awprot       ;
    logic        awvalid      ;
    logic         awready      ;
    //w          
    logic [3 :0] wid          ;
    logic [31:0] wdata        ;
    logic [3 :0] wstrb        ;
    logic        wlast        ;
    logic        wvalid       ;
    logic         wready       ;
    //b           
    logic  [3 :0] bid          ;
    logic  [1 :0] bresp        ;
    logic         bvalid       ;
    logic        bready    ;   
}axi_interface;

module mycpu_top(
	input aclk,
	input aresetn,
	input [5:0] ext_int,
    //axi
    //ar
    output [3 :0] arid         ,
    output [31:0] araddr       ,
    output [3 :0] arlen        ,
    output [2 :0] arsize       ,
    output [1 :0] arburst      ,
    output [1 :0] arlock        ,
    output [3 :0] arcache      ,
    output [2 :0] arprot       ,
    output        arvalid      ,
    input         arready      ,
    //r           
    input  [3 :0] rid          ,
    input  [31:0] rdata        ,
    input  [1 :0] rresp        ,
    input         rlast        ,
    input         rvalid       ,
    output        rready       ,
    //aw          
    output [3 :0] awid         ,
    output [31:0] awaddr       ,
    output [3 :0] awlen        ,
    output [2 :0] awsize       ,
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output        awvalid      ,
    input         awready      ,
    //w          
    output [3 :0] wid          ,
    output [31:0] wdata        ,
    output [3 :0] wstrb        ,
    output        wlast        ,
    output        wvalid       ,
    input         wready       ,
    //b           
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input         bvalid       ,
    output        bready       ,

    output [31:0] debug_wb_pc,
	output [3:0] debug_wb_rf_wen,
	output [4:0] debug_wb_rf_wnum,
	output [31:0] debug_wb_rf_wdata
	);
/*
    ila ila(
        .clk        (clk),
        .probe0     (WB.PCout)
    );
*/
	logic rst;

	IF_interface IF;
	ID_interface ID;
	EX_interface EX;
	MEM_interface MEM;
	WB_interface WB;
	Hazard_interface Hazard;
	Exception_interface Exception;    
    axi_interface axi;

    wire   [3:0] awqos,  arqos;
    assign awqos = 4'b0000;
    assign arqos = 4'b0000;
    AXI_Crossbar axi_bridge(
        .aclk           (aclk),
        .aresetn        (aresetn),

        .s_axi_awid     ({axi.awid,        IF.instr_awid}),
        .s_axi_awaddr   ({axi.awaddr,      IF.instr_awaddr}),
        .s_axi_awlen    ({axi.awlen,       IF.instr_awlen}),
        .s_axi_awsize   ({axi.awsize,      IF.instr_awsize}),
        .s_axi_awburst  ({axi.awburst,     IF.instr_awburst}),
        .s_axi_awlock   ({axi.awlock,      IF.instr_awlock}),
        .s_axi_awcache  ({axi.awcache,     IF.instr_awcache}),
        .s_axi_awprot   ({axi.awprot,      IF.instr_awprot}),
        .s_axi_awqos    (0),
        .s_axi_awvalid  ({axi.awvalid,     IF.instr_awvalid}),
        .s_axi_awready  ({axi.awready,     IF.instr_awready}),
        .s_axi_wid      ({axi.wid,         IF.instr_wid}),
        .s_axi_wdata    ({axi.wdata,       IF.instr_wdata}),
        .s_axi_wstrb    ({axi.wstrb,       IF.instr_wstrb}),
        .s_axi_wlast    ({axi.wlast,       IF.instr_wlast}),
        .s_axi_wvalid   ({axi.wvalid,      IF.instr_wvalid}),
        .s_axi_wready   ({axi.wready,      IF.instr_wready}),
        .s_axi_bid      ({axi.bid,         IF.instr_bid}),
        .s_axi_bresp    ({axi.bresp,       IF.instr_bresp}),
        .s_axi_bvalid   ({axi.bvalid,      IF.instr_bvalid}),
        .s_axi_bready   ({axi.bready,      IF.instr_bready}),
        .s_axi_arid     ({axi.arid,        IF.instr_arid}),
        .s_axi_araddr   ({axi.araddr,      IF.instr_araddr}),
        .s_axi_arlen    ({axi.arlen,       IF.instr_arlen}),
        .s_axi_arsize   ({axi.arsize,      IF.instr_arsize}),
        .s_axi_arburst  ({axi.arburst,     IF.instr_arburst}),
        .s_axi_arlock   ({axi.arlock,      IF.instr_arlock}),
        .s_axi_arcache  ({axi.arcache,     IF.instr_arcache}),
        .s_axi_arprot   ({axi.arprot,      IF.instr_arprot}),
        .s_axi_arqos    ({0}),
        .s_axi_arvalid  ({axi.arvalid,     IF.instr_arvalid}),
        .s_axi_arready  ({axi.arready,     IF.instr_arready}),
        .s_axi_rid      ({axi.rid,         IF.instr_rid}),
        .s_axi_rdata    ({axi.rdata,       IF.instr_rdata}),
        .s_axi_rresp    ({axi.rresp,       IF.instr_rresp}),
        .s_axi_rlast    ({axi.rlast,       IF.instr_rlast}),
        .s_axi_rvalid   ({axi.rvalid,      IF.instr_rvalid}),
        .s_axi_rready   ({axi.rready,      IF.instr_rready}),

        .m_axi_awid     (awid),
        .m_axi_awaddr   (awaddr),
        .m_axi_awlen    (awlen),
        .m_axi_awsize   (awsize),
        .m_axi_awburst  (awburst),
        .m_axi_awlock   (awlock),
        .m_axi_awcache  (awcache),
        .m_axi_awprot   (awprot),
        .m_axi_awqos    (awqos),   //?
        .m_axi_awvalid  (awvalid),
        .m_axi_awready  (awready),
        .m_axi_wid      (wid),
        .m_axi_wdata    (wdata),
        .m_axi_wstrb    (wstrb),
        .m_axi_wlast    (wlast),
        .m_axi_wvalid   (wvalid),
        .m_axi_wready   (wready),
        .m_axi_bid      (bid),
        .m_axi_bresp    (bresp),
        .m_axi_bvalid   (bvalid),
        .m_axi_bready   (bready),
        .m_axi_arid     (arid),
        .m_axi_araddr   (araddr),
        .m_axi_arlen    (arlen),
        .m_axi_arsize   (arsize),
        .m_axi_arburst  (arburst),
        .m_axi_arlock   (arlock),
        .m_axi_arcache  (arcache),
        .m_axi_arprot   (arprot),
        .m_axi_arqos    (arqos),    //?
        .m_axi_arvalid  (arvalid),
        .m_axi_arready  (arready),
        .m_axi_rid      (rid),
        .m_axi_rdata    (rdata),
        .m_axi_rresp    (rresp),
        .m_axi_rlast    (rlast),
        .m_axi_rvalid   (rvalid),
        .m_axi_rready   (rready)
    );

	//Data path connect to SRAM
	assign clk								= aclk;
	assign rst 								= ~aresetn;
	assign debug_wb_pc 						= WB.PCout;
	assign debug_wb_rf_wen					= (WB.RegWrite && WB.WritetoRFaddrout[6:5] == 2'b00) ? 4'b1111 : 4'b0000;
	assign debug_wb_rf_wnum					= WB.WritetoRFaddrout[4:0];
	assign debug_wb_rf_wdata				= WB.WritetoRFdata;

	//Data path across modules without registers
	assign IF.Jump                          = ID.Jump;
	assign IF.BranchD                       = ID.BranchD;
	assign IF.EPC_sel                       = ID.EPC_sel;
	assign IF.EPC                           = ID.EPCout;
	assign IF.Jump_reg                      = ID.PCSrc_reg;
	assign IF.Jump_addr                     = ID.Jump_addr;
	assign IF.beq_addr                      = ID.Branch_addr;
	assign IF.StallF                        = Hazard.StallF;
	assign IF.Error_happend					= Exception.Stall;

	assign ID.RegWriteW                     = WB.RegWrite;
	assign ID.WriteRegW                     = WB.WritetoRFaddrout;
	assign ID.ResultW                       = WB.WritetoRFdata;
	assign ID.HI_LO_write_enable_from_WB    = WB.HI_LO_writeenableout;
	assign ID.HI_LO_data                    = WB.WriteinRF_HI_LO_data;
	assign ID.ALUoutE                       = EX.ALUResult;
	assign ID.ALUoutM                       = MEM.ALUoutW;
	assign ID.ForwardAD                     = Hazard.ForwardAD;
	assign ID.ForwardBD                     = Hazard.ForwardBD;
	assign ID.Exception_EXL					= Exception.EXL;
	assign ID.software_interruption         = Exception.software_abortion;
	assign ID.Exception_code				= Exception.ExcCode;
	assign ID.we							= Exception.we;
	assign ID.Branch_delay					= Exception.Branch_delay;
	assign ID.EPCin							= Exception.EPC;
	assign ID.new_IE   						= Exception.new_Status_IE;
	assign ID.hardware_interruption			= ext_int;
	assign ID.BADADDR						= Exception.BadVAddr;
    assign ID.StallD                        = Hazard.StallD;

	assign EX.ForwardMEM                    = MEM.ALUout;
	assign EX.ForwardWB                     = WB.WritetoRFdata;
	assign EX.ForwardA                      = Hazard.ForwardAE;
	assign EX.ForwardB                      = Hazard.ForwardBE;

	assign WB.EPCD							= ID.EPCout;

	assign Hazard.BranchD                   = ID.BranchD;
	assign Hazard.RsD                       = ID.Rs;
	assign Hazard.RtD                       = ID.Rt;
	assign Hazard.ID_exception              = ID.exception;
	assign Hazard.RsE                       = EX.Rs_o;
	assign Hazard.RtE                       = EX.Rt_o;
	assign Hazard.MemReadE                  = EX.MemRead_o;
	assign Hazard.MemtoRegE                 = EX.MemtoReg_o;
	assign Hazard.EX_exception              = EX.exception;
	assign Hazard.ALU_stall                 = EX.stall;
	assign Hazard.ALU_done                  = EX.done;
	assign Hazard.Exception_Stall           = Exception.Stall;
	assign Hazard.Exception_clean           = Exception.Stall;
	assign Hazard.RegWriteM                 = MEM.RegWriteM;
	assign Hazard.WriteRegM                 = MEM.WriteRegister;
	assign Hazard.MemReadM                  = MEM.MemReadM;
	assign Hazard.MemtoRegM                 = MEM.MemtoRegM;
	assign Hazard.RegWriteW                 = WB.RegWrite;
	assign Hazard.WriteRegW                 = WB.WritetoRFaddrout;
	assign Hazard.WriteRegE					= EX.WriteRegister;
	assign Hazard.RegWriteE					= EX.RegWrite_o;
	assign Hazard.isaBranchInstruction		= ID.isBranch;
    assign Hazard.IF_stall                  = IF.stall;
    assign Hazard.MEM_stall                 = MEM.stall;

	assign Exception.Status					= ID.Status;
	assign Exception.Cause					= ID.cause;
	assign Exception.overflow_error         = (WB.exception_out == `EXP_OVERFLOW)   ? 1 : 0;
	assign Exception._break					= (WB.exception_out == `EXP_BREAK)		? 1 : 0;
	assign Exception.syscall				= (WB.exception_out == `EXP_SYSCALL)	? 1 : 0;
    assign Exception.address_error          = (WB.exception_out == `EXP_ADDRERR)   	? 1 : 0;
	assign Exception.ErrorAddr				= (WB.exception_out == `EXP_ADDRERR)	? WB.aluout : 0;
	assign Exception.isERET 				= (WB.exception_out == `EXP_ERET)   	? 1 : 0;
	assign Exception.reserved				= (WB.exception_out == `EXP_RESERVED)	? 1 : 0;
	assign Exception.MemWrite 				= WB.MemWrite;
	assign Exception.hardware_abortion		= ext_int;
    assign Exception.software_abortion      = {2{ID.Status[0]}} & ID.Status[9:8] & ID.cause[9:8];
	assign Exception.Status_IM              = ID.Status[15:8];
    assign Exception.is_ds                  = WB.is_ds_out;
	assign Exception.pc						= WB.PCout;
	assign Exception.EPCD					= ID.EPCout;
    assign Exception.StallW                 = Hazard.StallW;
    assign Exception.FlushW                 = Hazard.FlushW;

    assign axi.inst_req                     = 0;
    assign axi.inst_wr                      = 0;
    assign axi.inst_size                    = 0;
    assign axi.inst_addr                    = 0;
    assign axi.inst_wdata                   = 0;
    
    assign axi.data_req                     = MEM.data_req;
    assign axi.data_wr                      = MEM.data_wr;
    assign axi.data_size                    = MEM.data_size;
    assign axi.data_addr                    = MEM.data_addr;
    assign axi.data_wdata                   = MEM.data_wdata;
    assign MEM.data_rdata                   = axi.data_rdata;
    assign MEM.data_addr_ok                 = axi.data_addr_ok;
    assign MEM.data_data_ok                 = axi.data_data_ok;

	// IF/ID registers

	register #(32) IF_ID_pc_plus_4 (
		.clk(clk),
		.rst(rst),
		.Flush(Hazard.FlushD),
		.en(~Hazard.StallD),
		.d(IF.PC_add_4),
		.q(ID.pc_plus_4)
	);

	register #(32) IF_ID_PCout (
		.clk(clk),
		.rst(rst),
		.Flush(Hazard.FlushD),
		.en(~Hazard.StallD),
		.d(IF.PCout),
		.q(ID.PCin)
	);

    register #(32) IF_ID_instr (
		.clk(clk),
		.rst(rst),
		.Flush(Hazard.FlushD),
		.en(~Hazard.StallD),
        .d(IF.instr),
        .q(ID.instr)
    );

	// ID/EX registers

	register #(6) ID_EX_ALUControl (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.ALUOp),
		.q(EX.ALUControl)
	);

	register #(1) ID_EX_ALUSrcA (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.ALUSrcDA),
		.q(EX.ALUSrcA)
	);

	register #(1) ID_EX_ALUSrcB (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.ALUSrcDB),
		.q(EX.ALUSrcB)
	);

	register #(1) ID_EX_RegDst (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.RegDstD),
		.q(EX.RegDst)
	);

	register #(1) ID_EX_MemRead_i (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.MemReadD),
		.q(EX.MemRead_i)
	);

	register #(3) ID_EX_MemReadType_i (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.MemReadType),
		.q(EX.MemReadType_i)
	);

	register #(1) ID_EX_MemWrite_i (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.MemWriteD),
		.q(EX.MemWrite_i)
	);

	register #(1) ID_EX_MemtoReg_i (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.MemtoRegD),
		.q(EX.MemtoReg_i)
	);

	register #(1) ID_EX_hiloWrite_i (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.HI_LO_write_enableD),
		.q(EX.hiloWrite_i)
	);

	register #(1) ID_EX_RegWrite_i (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.RegWriteD),
		.q(EX.RegWrite_i)
	);

	register #(1) ID_EX_immSel (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.Imm_sel),
		.q(EX.immSel)
	);

	register #(32) ID_EX_A (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.RsValue),
		.q(EX.A)
	);

	register #(32) ID_EX_B (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.RtValue),
		.q(EX.B)
	);

	register #(32) ID_EX_PCplus8 (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.pc_plus_8),
		.q(EX.PCplus8)
	);

	register #(7) ID_EX_Rs (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.Rs),
		.q(EX.Rs)
	);

	register #(7) ID_EX_Rt (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.Rt),
		.q(EX.Rt)
	);

	register #(7) ID_EX_Rd (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.Rd),
		.q(EX.Rd)
	);

	register #(32) ID_EX_imm (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d({16'b0, ID.imm}),
		.q(EX.imm)
	);

	register #(32) ID_EX_PCout (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.PCout),
		.q(EX.PCin)
	);

	register #(1) ID_EX_exception (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.exception),
		.q(EX.exceptionD)
	);

    register #(1) ID_EX_is_ds (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
        .d(ID.is_ds),
        .q(EX.is_ds_in)
    );

	// EX/MEM registers
	
	register #(1) EX_MEM_HI_LO_write_enableM (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
		.d(EX.hiloWrite_o),
		.q(MEM.HI_LO_write_enableM)
	);

	register #(3) EX_MEM_MemReadType (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
		.d(EX.MemReadType_o),
		.q(MEM.MemReadType)
	);

	register #(1) EX_MEM_MemReadM (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
		.d(EX.MemRead_o),
		.q(MEM.MemReadM)
	);

	register #(1) EX_MEM_RegWriteM (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
		.d(EX.RegWrite_o),
		.q(MEM.RegWriteM)
	);

	register #(1) EX_MEM_MemtoRegM (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
		.d(EX.MemtoReg_o),
		.q(MEM.MemtoRegM)
	);

	register #(1) EX_MEM_MemWriteM (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
		.d(EX.MemWrite_o),
		.q(MEM.MemWriteM)
	);

	register #(64) EX_MEM_HI_LO_dataM (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
		.d(EX.hiloData),
		.q(MEM.HI_LO_dataM)
	);

	register #(32) EX_MEM_ALUout (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
		.d(EX.ALUResult),
		.q(MEM.ALUout)
	);

	register #(32) EX_MEM_RamData (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
		.d(EX.MemData),
		.q(MEM.RamData)
	);

	register #(7) EX_MEM_WriteRegister (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
		.d(EX.WriteRegister),
		.q(MEM.WriteRegister)
	);

	register #(32) EX_MEM_PCout (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
		.d(EX.PCout),
		.q(MEM.PCin)
	);

    register #(4) EX_MEM_exception (
        .clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
        .d(EX.exception),
        .q(MEM.exception_in)
    );

    register #(1) EX_MEM_is_ds (
        .clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
        .d(EX.is_ds_out),
        .q(MEM.is_ds_in)
    );

	// MEM/WB registers

	register #(1) MEM_WB_MemtoRegW (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
		.d(MEM.MemtoRegW),
		.q(WB.MemtoRegW)
	);

	register #(1) MEM_WB_RegWriteW (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
		.d(MEM.RegWriteW),
		.q(WB.RegWriteW)
	);

	register #(1) MEM_WB_HI_LO_writeenablein (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
		.d(MEM.HI_LO_write_enableW),
		.q(WB.HI_LO_writeenablein)
	);

	register #(64) MEM_WB_HILO_data (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
		.d(MEM.HI_LO_dataW),
		.q(WB.HILO_data)
	);

	register #(32) MEM_WB_aluout (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
		.d(MEM.ALUoutW),
		.q(WB.aluout)
	);

	register #(7) MEM_WB_WritetoRFaddrin (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
		.d(MEM.WriteRegisterW),
		.q(WB.WritetoRFaddrin)
	);

	register #(32) MEM_WB_PCout (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
		.d(MEM.PCout),
		.q(WB.PCin)
	);

	register #(3) MEM_WB_MemReadTypeW (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
		.d(MEM.MemReadTypeW),
		.q(WB.MemReadTypeW)
	);

    register #(4) MEM_WB_exception(
        .clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
        .d(MEM.exception_out),
        .q(WB.exception_in)
    );

	register #(1) MEM_WB_MemWriteW (
        .clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
        .d(MEM.MemWriteW),
        .q(WB.MemWriteW)
    );

    register #(1) MEM_WB_is_ds (
        .clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
        .d(MEM.is_ds_out),
        .q(WB.is_ds_in)
    );

    register #(32) MEM_WB_Memdata (
        .clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
        .d(MEM.Memdata),
        .q(WB.Memdata)
    );

	IF_module IF_module(
		.clk                        (clk),
		.rst                        (rst),
		.Jump                       (IF.Jump),
		.BranchD                    (IF.BranchD),
		.EPC_sel                    (IF.EPC_sel),
		.EPC                        (IF.EPC),
		.Jump_reg                   (IF.Jump_reg),
		.Jump_addr                  (IF.Jump_addr),
		.beq_addr                   (IF.beq_addr),
        .StallF                     (IF.StallF | IF.stall | MEM.stall),
		.PC_add_4                   (IF.PC_add_4),
		.PCout						(IF.PCout),
        .Error_happend				(IF.Error_happend),
        .is_newPC                   (IF.is_newPC),

        .instr                      (IF.instr),
        .stall                      (IF.stall),

        //========INSTR_AXI_BUS========
        //ar
        .instr_arid                 (IF.instr_arid),
        .instr_araddr               (IF.instr_araddr),
        .instr_arlen                (IF.instr_arlen),
        .instr_arsize               (IF.instr_arsize),
        .instr_arburst              (IF.instr_arburst),
        .instr_arlock               (IF.instr_arlock),
        .instr_arcache              (IF.instr_arcache),
        .instr_arprot               (IF.instr_arprot),
        .instr_arvalid              (IF.instr_arvalid),
        .instr_arready              (IF.instr_arready),
        //r
        .instr_rid                  (IF.instr_rid),
        .instr_rdata                (IF.instr_rdata),
        .instr_rresp                (IF.instr_rresp),
        .instr_rlast                (IF.instr_rlast),
        .instr_rvalid               (IF.instr_rvalid),
        .instr_rready               (IF.instr_rready),
        //aw
        .instr_awid                 (IF.instr_awid),
        .instr_awaddr               (IF.instr_awaddr),
        .instr_awlen                (IF.instr_awlen),
        .instr_awsize               (IF.instr_awsize),
        .instr_awburst              (IF.instr_awburst),
        .instr_awlock               (IF.instr_awlock),
        .instr_awcache              (IF.instr_awcache),
        .instr_awprot               (IF.instr_awprot),
        .instr_awvalid              (IF.instr_awvalid),
        .instr_awready              (IF.instr_awready),
        //w
        .instr_wid                  (IF.instr_wid),
        .instr_wdata                (IF.instr_wdata),
        .instr_wstrb                (IF.instr_wstrb),
        .instr_wlast                (IF.instr_wlast),
        .instr_wvalid               (IF.instr_wvalid),
        .instr_wready               (IF.instr_wready),
        //b
        .instr_bid                  (IF.instr_bid),
        .instr_bresp                (IF.instr_bresp),
        .instr_bvalid               (IF.instr_bvalid),
        .instr_bready               (IF.instr_bready)
	);
	
	ID_module ID_module(
		.clk                        (clk),
		.rst                        (rst),
		.instr                      (ID.instr),
		.pc_plus_4                  (ID.pc_plus_4),
		.WriteRegW                  (ID.WriteRegW),
		.ResultW                    (ID.ResultW),
		.HI_LO_data                 (ID.HI_LO_data),
		.HI_LO_write_enable_from_WB (ID.HI_LO_write_enable_from_WB),
		.RegWriteW                  (ID.RegWriteW),
		.ALUoutE                    (ID.ALUoutE),
		.ALUoutM                    (ID.ALUoutM),
		.ForwardAD                  (ID.ForwardAD),
		.ForwardBD                  (ID.ForwardBD),
		.ALUOp                      (ID.ALUOp),
		.HI_LO_write_enableD        (ID.HI_LO_write_enableD),
		.MemReadType                (ID.MemReadType),
		.MemReadD                   (ID.MemReadD),
		.RegWriteD                  (ID.RegWriteD),
		.MemtoRegD                  (ID.MemtoRegD),
		.MemWriteD                  (ID.MemWriteD),
		.ALUSrcDA                   (ID.ALUSrcDA),
		.ALUSrcDB                   (ID.ALUSrcDB),
		.RegDstD                    (ID.RegDstD),
        .Imm_sel                    (ID.Imm_sel),
		.RsValue                    (ID.RsValue),
		.RtValue                    (ID.RtValue),
		.pc_plus_8                  (ID.pc_plus_8),
		.Rs                         (ID.Rs),
		.Rt                         (ID.Rt),
		.Rd                         (ID.Rd),
		.imm                        (ID.imm),
		.EPC_sel                    (ID.EPC_sel),
		.BranchD                    (ID.BranchD),
		.Jump                       (ID.Jump),
		.PCSrc_reg                  (ID.PCSrc_reg),
		.EPCout                     (ID.EPCout),
		.Branch_addr                (ID.Branch_addr),
		.Jump_addr                  (ID.Jump_addr),
		.exception                  (ID.exception),
		.PCin						(ID.PCin),
		.PCout						(ID.PCout),		
		.we							(ID.we),
    	.Exception_code				(ID.Exception_code),
		.new_IE						(ID.new_IE),
    	.EXL						(ID.Exception_EXL),
    	.EPCin						(ID.EPCin),
    	.BADADDR					(ID.BADADDR),
    	.Branch_delay				(ID.Branch_delay),
    	.hardware_interruption		(ID.hardware_interruption),
    	.software_interruption		(ID.software_interruption),
		.Status_data				(ID.Status),
    	.cause_data					(ID.cause),
		.isBranch					(ID.isBranch),
        .is_ds                      (ID.is_ds),
        .StallD                     (ID.StallD)
	);

	EX_module EX_module(
		.clk                        (clk),
		.rst                        (rst),
		.hiloWrite_i                (EX.hiloWrite_i),
		.MemReadType_i              (EX.MemReadType_i),
		.RegWrite_i                 (EX.RegWrite_i),
		.MemtoReg_i                 (EX.MemtoReg_i),
		.MemWrite_i                 (EX.MemWrite_i),
		.MemRead_i					(EX.MemRead_i),
		.ALUControl                 (EX.ALUControl),
		.ALUSrcA                    (EX.ALUSrcA),
		.ALUSrcB                    (EX.ALUSrcB),
		.RegDst                     (EX.RegDst),
		.immSel                     (EX.immSel),
		.ForwardA                   (EX.ForwardA),
		.ForwardB                   (EX.ForwardB),
		.A                          (EX.A),
		.B                          (EX.B),
		.PCplus8                    (EX.PCplus8),
		.Rs                         (EX.Rs),
		.Rt                         (EX.Rt),
		.Rd                         (EX.Rd),
		.imm                        (EX.imm),
		.ForwardMEM                 (EX.ForwardMEM),
		.ForwardWB                  (EX.ForwardWB),
		.hiloWrite_o                (EX.hiloWrite_o),
		.MemReadType_o              (EX.MemReadType_o),
		.RegWrite_o                 (EX.RegWrite_o),
		.MemtoReg_o                 (EX.MemtoReg_o),
		.MemWrite_o                 (EX.MemWrite_o),
		.MemRead_o					(EX.MemRead_o),
		.Rs_o                       (EX.Rs_o),
		.Rt_o                       (EX.Rt_o),
		.hiloData                   (EX.hiloData),
		.ALUResult                  (EX.ALUResult),
		.done                       (EX.done),
		.exception                  (EX.exception),
		.stall                      (EX.stall),
		.MemData                    (EX.MemData),
		.WriteRegister              (EX.WriteRegister),
		.PCin						(EX.PCin),
		.PCout						(EX.PCout),
		.exceptionD					(EX.exceptionD),
        .is_ds_in                   (EX.is_ds_in),
        .is_ds_out                  (EX.is_ds_out)
	);

	MEM_module MEM_module(
		.clk                        (clk),
		.rst                        (rst),
		.HI_LO_write_enableM        (MEM.HI_LO_write_enableM),
		.HI_LO_dataM                (MEM.HI_LO_dataM),
		.MemReadType                (MEM.MemReadType),
		.RegWriteM                  (MEM.RegWriteM),
		.MemReadM                   (MEM.MemReadM),
		.MemtoRegM                  (MEM.MemtoRegM),
		.MemWriteM                  (MEM.MemWriteM),
		.ALUout                     (MEM.ALUout),
		.RamData                    (MEM.RamData),
		.WriteRegister              (MEM.WriteRegister),
		.MemtoRegW                  (MEM.MemtoRegW),
		.RegWriteW                  (MEM.RegWriteW),
		.HI_LO_write_enableW        (MEM.HI_LO_write_enableW),
		.HI_LO_dataW                (MEM.HI_LO_dataW),
		.ALUoutW                    (MEM.ALUoutW),
		.WriteRegisterW             (MEM.WriteRegisterW),
		.PCin						(MEM.PCin),
		.PCout						(MEM.PCout),
		.MemReadTypeW				(MEM.MemReadTypeW),
        .exception_in               (MEM.exception_in),
        .exception_out              (MEM.exception_out),
		.MemWriteW					(MEM.MemWriteW),
        .is_ds_in                   (MEM.is_ds_in),
        .is_ds_out                  (MEM.is_ds_out),
        
        .Memdata                    (MEM.Memdata),

        .data_req                   (MEM.data_req),
        .data_wr                    (MEM.data_wr),
        .data_size                  (MEM.data_size),
        .data_addr                  (MEM.data_addr),
        .data_wdata                 (MEM.data_wdata),
        .data_rdata                 (MEM.data_rdata),
        .data_addr_ok               (MEM.data_addr_ok),
        .data_data_ok               (MEM.data_data_ok),

        .CLR                        (MEM.CLR),
        .stall                      (MEM.stall)
	);

	WB_module WB_module(
		.aluout                     (WB.aluout),
		.Memdata                    (WB.Memdata),
		.WritetoRFaddrin            (WB.WritetoRFaddrin),
		.MemtoRegW                  (WB.MemtoRegW),
		.RegWriteW                  (WB.RegWriteW),
		.HILO_data                  (WB.HILO_data),
		.WriteinRF_HI_LO_data       (WB.WriteinRF_HI_LO_data),
		.HI_LO_writeenablein        (WB.HI_LO_writeenablein),
		.WritetoRFaddrout           (WB.WritetoRFaddrout),
		.HI_LO_writeenableout       (WB.HI_LO_writeenableout),
		.WritetoRFdata              (WB.WritetoRFdata),
		.RegWrite                   (WB.RegWrite),
		.PCin						(WB.PCin),
		.PCout						(WB.PCout),
		.MemReadTypeW				(WB.MemReadTypeW),
        .exception_in               (WB.exception_in),
        .exception_out              (WB.exception_out),
		.MemWriteW					(WB.MemWriteW),
		.MemWrite					(WB.MemWrite),
		.EPCD						(WB.EPCD),
        .is_ds_in                   (WB.is_ds_in),
        .is_ds_out                  (WB.is_ds_out)
	);

	Hazard_module Hazard_module(
		.clk						(clk),
		.rst 						(rst),
		.BranchD                    (Hazard.BranchD),
		.RsD                        (Hazard.RsD),
		.RtD                        (Hazard.RtD),
		.ID_exception               (Hazard.ID_exception),
		.isaBranchInstruction		(Hazard.isaBranchInstruction),
		.RsE                        (Hazard.RsE),
		.RtE                        (Hazard.RtE),
		.MemReadE                   (Hazard.MemReadE),
		.MemtoRegE                  (Hazard.MemtoRegE),
		.WriteRegE					(Hazard.WriteRegE),
		.RegWriteE					(Hazard.RegWriteE),
		.ALU_stall                  (Hazard.ALU_stall),
		.ALU_done                   (Hazard.ALU_done),
		.Exception_Stall            (Hazard.Exception_Stall),
		.Exception_clean            (Hazard.Exception_clean),
		.RegWriteM                  (Hazard.RegWriteM),
		.WriteRegM                  (Hazard.WriteRegM),
		.MemReadM                   (Hazard.MemReadM),
		.MemtoRegM                  (Hazard.MemtoRegM),
		.RegWriteW                  (Hazard.RegWriteW),
		.WriteRegW                  (Hazard.WriteRegW),
		.StallF                     (Hazard.StallF),
		.StallD                     (Hazard.StallD),
		.StallE                     (Hazard.StallE),
		.StallM                     (Hazard.StallM),
		.StallW                     (Hazard.StallW),
		.FlushD                     (Hazard.FlushD),
		.FlushE                     (Hazard.FlushE),
		.FlushM                     (Hazard.FlushM),
		.FlushW                     (Hazard.FlushW),
		.ForwardAD                  (Hazard.ForwardAD),
		.ForwardBD                  (Hazard.ForwardBD),
		.ForwardAE                  (Hazard.ForwardAE),
		.ForwardBE                  (Hazard.ForwardBE),
        .IF_stall                   (Hazard.IF_stall),
        .MEM_stall                  (Hazard.MEM_stall)
	);

	Exception_module Exception_module(
		.clk						(clk),
        .rst 						(rst),
    	.address_error				(Exception.address_error),
    	.MemWrite					(Exception.MemWrite),					
    	.overflow_error				(Exception.overflow_error),
    	.syscall					(Exception.syscall),
    	._break						(Exception._break),
    	.reserved					(Exception.reserved),
    	.hardware_abortion			(Exception.hardware_abortion),
    	.software_abortion			(Exception.software_abortion),
    	.Status						(Exception.Status),
    	.Cause						(Exception.Cause),
    	.pc							(Exception.pc),
    	.BadVAddr					(Exception.BadVAddr),
    	.EPC						(Exception.EPC),
    	.we							(Exception.we),
    	.new_Cause_BD1				(Exception.Branch_delay),
    	.exception_occur			(Exception.Stall),
    	.new_Status_EXL				(Exception.EXL),
    	.new_Status_IE				(Exception.new_Status_IE),
    	.Cause_IP					(Exception.enable),
    	.Status_IM					(Exception.Status_IM),
    	.ExcCode					(Exception.ExcCode),
		.ErrorAddr					(Exception.ErrorAddr),
		.EPCD						(Exception.EPCD),
		.isERET						(Exception.isERET),
        .is_ds                      (Exception.is_ds),
        .StallW                     (Exception.StallW),
        .FlushW                     (Exception.FlushW)
	);

    cpu_axi_interface cpu_axi_interface(
        .clk                        (clk),
        .resetn                     (aresetn),
        
        .inst_req                   (axi.inst_req),
        .inst_wr                    (axi.inst_wr),
        .inst_size                  (axi.inst_size),
        .inst_addr                  (axi.inst_addr),
        .inst_wdata                 (axi.inst_wdata),
        .inst_rdata                 (axi.inst_rdata),
        .inst_addr_ok               (axi.inst_addr_ok),
        .inst_data_ok               (axi.inst_data_ok),

        .data_req                   (axi.data_req),
        .data_wr                    (axi.data_wr),
        .data_size                  (axi.data_size),
        .data_addr                  (axi.data_addr),
        .data_wdata                 (axi.data_wdata),
        .data_rdata                 (axi.data_rdata),
        .data_addr_ok               (axi.data_addr_ok),
        .data_data_ok               (axi.data_data_ok),

        .arid                       (axi.arid),
        .araddr                     (axi.araddr),
        .arlen                      (axi.arlen),
        .arsize                     (axi.arsize),
        .arburst                    (axi.arburst),
        .arlock                     (axi.arlock),
        .arcache                    (axi.arcache),
        .arprot                     (axi.arprot),
        .arvalid                    (axi.arvalid),
        .arready                    (axi.arready),
        
        .rid                        (axi.rid),
        .rdata                      (axi.rdata),
        .rresp                      (axi.rresp),
        .rlast                      (axi.rlast),
        .rvalid                     (axi.rvalid),
        .rready                     (axi.rready),

        .awid                       (axi.awid),
        .awaddr                     (axi.awaddr),
        .awlen                      (axi.awlen),
        .awsize                     (axi.awsize),
        .awburst                    (axi.awburst),
        .awlock                     (axi.awlock),
        .awcache                    (axi.awcache),
        .awprot                     (axi.awprot),
        .awvalid                    (axi.awvalid),
        .awready                    (axi.awready),

        .wid                        (axi.wid),
        .wdata                      (axi.wdata),
        .wstrb                      (axi.wstrb),
        .wlast                      (axi.wlast),
        .wvalid                     (axi.wvalid),
        .wready                     (axi.wready),

        .bid                        (axi.bid),
        .bresp                      (axi.bresp),
        .bvalid                     (axi.bvalid),
        .bready                     (axi.bready)
        );
        
endmodule