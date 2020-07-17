`timescale 1ns / 1ps
`include "./other/aluop.vh"
`include "./other/Interface.sv"

module mycpu_top(
	input aclk,
	input aresetn,
	input [5:0] ext_int,
    //axi
    //ar
    output [3 :0] arid         ,
    output [31:0] araddr       ,
    output [7 :0] arlen        ,
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
    output [7 :0] awlen        ,
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

	logic rst;

	IF_interface IF;
	ID_interface ID;
	EX_interface EX;
	MEM_interface MEM;
	WB_interface WB;
	Hazard_interface Hazard;
	Exception_interface Exception;    
    axi_interface axi;

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
	assign ID.Exception_enable				= Exception.new_Status_IM;
	assign ID.software_interruption         = Exception.software_abortion;
	assign ID.Exception_code				= Exception.ExcCode;
	assign ID.we							= Exception.we;
	assign ID.Branch_delay					= Exception.Branch_delay;
	assign ID.EPCin							= Exception.EPC;
	assign ID.IE   							= Exception.new_Status_IE;
	assign ID.hardware_interruption			= ext_int;
	assign ID.BADADDR						= Exception.BadVAddr;

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
	assign Hazard.Exception_Stall			= Exception.Stall;
	assign Hazard.Exception_clean			= Exception.Stall;
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

    assign axi.inst_req                     = IF.inst_req;
    assign axi.inst_wr                      = IF.inst_wr;
    assign axi.inst_size                    = IF.inst_size;
    assign axi.inst_addr                    = IF.inst_addr;
    assign axi.inst_wdata                   = IF.inst_wdata;
    assign IF.inst_rdata                    = axi.inst_rdata;
    assign IF.inst_addr_ok                  = axi.inst_addr_ok;
    assign IF.inst_data_ok                  = axi.inst_data_ok;
    
    assign axi.data_req                     = MEM.data_req;
    assign axi.data_wr                      = MEM.data_wr;
    assign axi.data_size                    = MEM.data_size;
    assign axi.data_addr                    = MEM.data_addr;
    assign axi.data_wdata                   = MEM.data_wdata;
    assign MEM.data_rdata                   = axi.data_rdata;
    assign MEM.data_addr_ok                 = axi.data_addr_ok;
    assign MEM.data_data_ok                 = axi.data_data_ok;

    assign arid                             = axi.arid;
    assign araddr                           = axi.araddr;
    assign arlen                            = axi.arlen;
    assign arsize                           = axi.arsize;
    assign arburst                          = axi.arburst;
    assign arlock                           = axi.arlock;
    assign arcache                          = axi.arcache;
    assign arprot                           = axi.arprot;
    assign arvalid                          = axi.arvalid;
    assign axi.arready                      = arready;
    assign axi.rid                          = rid;
    assign axi.rdata                        = rdata;
    assign axi.rresp                        = rresp;
    assign axi.rlast                        = rlast;
    assign axi.rvalid                       = rvalid;
    assign rready                           = axi.rready;
    assign awid                             = axi.awid;
    assign awaddr                           = axi.awaddr;
    assign awlen                            = axi.awlen;
    assign awsize                           = axi.awsize;
    assign awburst                          = axi.awburst;
    assign awlock                           = axi.awlock;
    assign awcache                          = axi.awcache;
    assign awprot                           = axi.awprot;
    assign awvalid                          = axi.awvalid;
    assign axi.awready                      = awready;
    assign wid                              = axi.wid;
    assign wdata                            = axi.wdata;
    assign wstrb                            = axi.wstrb;
    assign wlast                            = axi.wlast;
    assign wvalid                           = axi.wvalid;
    assign axi.wready                       = axi.wready;
    assign axi.bid                          = bid;
    assign axi.bresp                        = bresp;
    assign axi.bvalid                       = bvalid;
    assign bready                           = axi.bready;

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

	// register #(1) ID_EX_Branch (
	// 	.clk(clk),
	// 	.rst(rst),
    //     .Flush(Hazard.FlushE),
	// 	.en(~Hazard.StallE),
	// 	.d(ID.BranchD),
	// 	.q(EX.BranchD)
	// );
	// register #(1) ID_EX_Jump (
	// 	.clk(clk),
	// 	.rst(rst),
    //     .Flush(Hazard.FlushE),
	// 	.en(~Hazard.StallE),
	// 	.d(ID.Jump),
	// 	.q(EX.JumpD)
	// );
	// register #(1) ID_EX_EPC_sel (
	// 	.clk(clk),
	// 	.rst(rst),
    //     .Flush(Hazard.FlushE),
	// 	.en(~Hazard.StallE),
	// 	.d(ID.EPC_sel),
	// 	.q(EX.EPC_selD)
	// );
	// register #(32) ID_EX_Branch_addr (
	// 	.clk(clk),
	// 	.rst(rst),
    //     .Flush(Hazard.FlushE),
	// 	.en(~Hazard.StallE),
	// 	.d(ID.Branch_addr),
	// 	.q(EX.Branch_addrD)
	// );
	// register #(32) ID_EX_Jump_addr (
	// 	.clk(clk),
	// 	.rst(rst),
    //     .Flush(Hazard.FlushE),
	// 	.en(~Hazard.StallE),
	// 	.d(ID.Jump_addr),
	// 	.q(EX.Jump_addrD)
	// );
	// register #(32) ID_EX_PCSrc_reg (
	// 	.clk(clk),
	// 	.rst(rst),
    //     .Flush(Hazard.FlushE),
	// 	.en(~Hazard.StallE),
	// 	.d(ID.PCSrc_reg),
	// 	.q(EX.PCSrc_regD)
	// );
	// register #(32) ID_EX_EPC (
	// 	.clk(clk),
	// 	.rst(rst),
    //     .Flush(Hazard.FlushE),
	// 	.en(~Hazard.StallE),
	// 	.d(ID.EPCout),
	// 	.q(EX.EPCD)
	// );

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

        .inst_req                   (IF.inst_req),
        .inst_wr                    (IF.inst_wr),
        .inst_size                  (IF.inst_size),
        .inst_addr                  (IF.inst_addr),
        .inst_wdata                 (IF.inst_wdata),
        .inst_rdata                 (IF.inst_rdata),
        .inst_addr_ok               (IF.inst_addr_ok),
        .inst_data_ok               (IF.inst_data_ok),
        .CLR                        (IF.CLR),
        .stall                      (IF.stall)
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
    	.interrupt_enable			(ID.Exception_enable),
    	.Exception_code				(ID.Exception_code),
		.IE							(ID.IE),
    	.EXL						(ID.Exception_EXL),
    	.EPCin						(ID.EPCin),
    	.BADADDR					(ID.BADADDR),
    	.Branch_delay				(ID.Branch_delay),
    	.hardware_interruption		(ID.hardware_interruption),
    	.software_interruption		(ID.software_interruption),
		.Status_data				(ID.Status),
    	.cause_data					(ID.cause),
		.isBranch					(ID.isBranch),
        .is_ds                      (ID.is_ds)
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
		.calWE						(MEM.calWE),
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
		.TrueRamData				(MEM.TrueRamData),
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
        .new_Status_IM              (Exception.new_Status_IM),
        .is_ds                      (Exception.is_ds)
	);

    cpu_axi_interface cpu_axi_interface(
        .clk                        (clk),
        .resetn                     (!rst),
        
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