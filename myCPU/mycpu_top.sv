`timescale 1ns / 1ps
`include "interface.sv"

module mycpu_top(
	input clk,
	input resetn,
	input [5:0] ext_int,
	input [31:0] inst_sram_rdata,
	input [31:0] data_sram_rdata,
	output inst_sram_en,
	output [3:0] inst_sram_wen,
	output [31:0] inst_sram_addr,
	output [31:0] inst_sram_wdata,
	output data_sram_en,
	output [3:0] data_sram_wen,
	output [31:0] data_sram_addr,
	output [31:0] data_sram_wdata,
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

	//Data path connect to SRAM
	assign rst 								= ~resetn;
	assign WB.Memdata 						= data_sram_rdata;
	assign inst_sram_en 					= resetn;
	assign inst_sram_wen 					= 0;
	assign inst_sram_addr 					= IF.PCout;
	assign inst_sram_wdata	 				= 0;
	assign data_sram_en 					= 1;
	assign data_sram_wen 					= MEM.calWE;
	assign data_sram_addr 					= {3'b000, MEM.ALUout[28:0]};
	assign data_sram_wdata 					= MEM.RamData;
	assign debug_wb_pc 						= WB.PCout;
	assign debug_wb_rf_wen					= (WB.RegWrite && WB.WritetoRFaddrout[6:5] == 2'b00) ? 4'b1111 : 4'b0000;
	assign debug_wb_rf_wnum					= WB.WritetoRFaddrout[4:0];
	assign debug_wb_rf_wdata				= WB.WritetoRFdata;

	//Data path across modules without registers
	assign IF.Jump                          = EX.Jump;
	assign IF.BranchD                       = EX.BranchD;
	assign IF.EPC_sel                       = EX.EPC_sel;
	assign IF.EPC                           = EX.EPC;
	assign IF.Jump_reg                      = EX.PCSrc_reg;
	assign IF.Jump_addr                     = EX.Jump_addr;
	assign IF.beq_addr                      = EX.Branch_addr;
	assign IF.StallF                        = Hazard.StallF;
	assign ID.RegWriteW                     = WB.RegWrite;
	assign ID.WriteRegW                     = WB.WritetoRFaddrout;
	assign ID.ResultW                       = WB.WritetoRFdata;
	assign ID.HI_LO_write_enable_from_WB    = WB.HI_LO_writeenableout;
	assign ID.HI_LO_data                    = WB.WriteinRF_HI_LO_data;
	assign ID.ALUoutE                       = EX.ALUResult;
	assign ID.ALUoutM                       = MEM.ALUoutW;
	assign ID.ForwardAD                     = Hazard.ForwardAD;
	assign ID.ForwardBD                     = Hazard.ForwardBD;
	assign EX.ForwardMEM                    = MEM.ALUout;
	assign EX.ForwardWB                     = WB.WritetoRFdata;
	assign EX.ForwardA                      = Hazard.ForwardAE;
	assign EX.ForwardB                      = Hazard.ForwardBE;
	assign Hazard.BranchD                   = ID.BranchD;
	assign Hazard.RsD                       = ID.Rs;
	assign Hazard.RtD                       = ID.Rt;
	assign Hazard.ID_exception              = ID.exception;
	assign Hazard.RsE                       = EX.Rs_o;
	assign Hazard.RtE                       = EX.Rt_o;
	assign Hazard.MemReadE                  = EX.MemRead_o;
	assign Hazard.MemtoRegE                 = EX.MemtoReg_o;
	assign Hazard.EX_exception              = EX.exception;
	assign Hazard.stall                     = EX.stall;
	assign Hazard.done                      = EX.done;
	assign Hazard.Exception_Stall           = Exception.Stall;
	assign Hazard.Exception_clean           = Exception.clean;
	assign Hazard.RegWriteM                 = MEM.RegWriteM;
	assign Hazard.WriteRegM                 = MEM.WriteRegister;
	assign Hazard.MemReadM                  = MEM.MemReadM;
	assign Hazard.MemtoRegM                 = MEM.MemtoRegM;
	assign Hazard.RegWriteW                 = WB.RegWrite;
	assign Hazard.WriteRegW                 = WB.WritetoRFaddrout;
	assign Hazard.WriteRegE					= EX.WriteRegister;
	assign Hazard.RegWriteE					= EX.RegWrite_o;
	assign Hazard.isaBranchInstruction		= ID.isBranch;

	// IF/ID registers	
	assign Hazard.Exception_Stall			= Exception.Stall;
	assign Hazard.Exception_clean			= Exception.Stall;
	assign ID.Exception_EXL					= Exception.EXL;
	assign ID.Exception_enable				= Exception.enable;
	assign ID.hardware_interruption			= Exception.Status_IM[7:2];
	assign ID.software_interruption			= Exception.Status_IM[1:0];
	assign ID.Exception_code				= Exception.ExcCode;
	assign ID.we							= Exception.we;
	assign ID.Branch_delay					= Exception.Branch_delay;
	assign ID.EPC							= Exception.EPC;
	assign Exception.Status					= ID.Status;
	assign Exception.Cause					= ID.cause;
	assign IF.Error_happend					= Exception.Stall;


	register #(32) IF_ID_pc_plus_4 (
		.clk(clk),
		.rst(rst),
		.Flush(Hazard.FlushD | IF.is_newPC),
		.en(~Hazard.StallD),
		.d(IF.PC_add_4),
		.q(ID.pc_plus_4)
	);

	register #(32) IF_ID_PCout (
		.clk(clk),
		.rst(rst),
		.Flush(Hazard.FlushD | IF.is_newPC),
		.en(~Hazard.StallD),
		.d(IF.PCout),
		.q(ID.PCin)
	);

    register #(32) IF_ID_instr (
		.clk(clk),
		.rst(rst),
		.Flush(Hazard.FlushD | IF.is_newPC),
		.en(~Hazard.StallD),
        .d(inst_sram_rdata),
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
		.d(ID.Imm_sel),//_and_Branch_taken),
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

	register #(1) ID_EX_Branch (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.BranchD),
		.q(EX.BranchD)
	);
	register #(1) ID_EX_Jump (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.Jump),
		.q(EX.JumpD)
	);
	register #(1) ID_EX_EPC_sel (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.EPC_sel),
		.q(EX.EPC_selD)
	);
	register #(32) ID_EX_Branch_addr (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.Branch_addr),
		.q(EX.Branch_addrD)
	);
	register #(32) ID_EX_Jump_addr (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.Jump_addr),
		.q(EX.Jump_addrD)
	);
	register #(32) ID_EX_PCSrc_reg (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.PCSrc_reg),
		.q(EX.PCSrc_regD)
	);
	register #(32) ID_EX_EPC (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.EPC),
		.q(EX.EPCD)
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
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(EX.PCout),
		.q(MEM.PCin)
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
		// .StallF                     (IF.StallF),
        .StallF                     (IF.StallF | IF.is_newPC),
		.PC_add_4                   (IF.PC_add_4),
		.PCout						(IF.PCout),
        
        .is_newPC                   (IF.is_newPC)
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
		//.Imm_sel_and_Branch_taken   (ID.Imm_sel_and_Branch_taken),
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
		.EPC                        (ID.EPC),
		.Branch_addr                (ID.Branch_addr),
		.Jump_addr                  (ID.Jump_addr),
		.exception                  (ID.exception),
		.PCin						(ID.PCin),
		.PCout						(ID.PCout),		
		.we							(ID.we),
    	.interrupt_enable			(ID.Exception_enable),
    	.Exception_code				(ID.Exception_code),
    	.EXL						(ID.Exception_EXL),
    	.epc						(32'h00000000),
    	.BADADDR					(32'h00000000),
    	.Branch_delay				(ID.Branch_delay),
    	.hardware_interruption		(ext_int),
    	.software_interruption		(2'b00),
		.Status_data				(ID.Status),
    	.cause_data					(ID.cause),
		.isBranch					(ID.isBranch)
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
		.BranchD					(EX.BranchD),
		.JumpD						(EX.JumpD),
		.EPC_selD					(EX.EPC_selD),
		.Branch_addrD				(EX.Branch_addrD),
		.Jump_addrD					(EX.Jump_addrD),
		.PCSrc_regD					(EX.PCSrc_regD),
		.EPCD						(EX.EPCD),
		.Branch						(EX.Branch),
		.Jump						(EX.Jump),
		.EPC_sel					(EX.EPC_sel),
		.Branch_addr				(EX.Branch_addr),
		.Jump_addr					(EX.Jump_addr),
		.PCSrc_reg					(EX.PCSrc_reg),
		.EPC						(EX.EPC)
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
		.MemReadTypeW				(MEM.MemReadTypeW)
	);

	WB_module WB_module(
		.aluout                     (WB.aluout),
		.Memdata                    (WB.Memdata),
		.WritetoRFaddrin            (WB.WritetoRFaddrin),
		.MemtoRegW                  (WB.MemtoRegW),
		.RegWriteW                  (WB.RegWriteW),
		.Exception_Write_addr_sel   (1'b0),
		.Exception_Write_data_sel   (1'b0),
		.Exception_RF_addr          (7'b0000000),
		.Exceptiondata              (32'h00000000),
		.HILO_data                  (WB.HILO_data),
		.WriteinRF_HI_LO_data       (WB.WriteinRF_HI_LO_data),
		.HI_LO_writeenablein        (WB.HI_LO_writeenablein),
		.WritetoRFaddrout           (WB.WritetoRFaddrout),
		.HI_LO_writeenableout       (WB.HI_LO_writeenableout),
		.WritetoRFdata              (WB.WritetoRFdata),
		.RegWrite                   (WB.RegWrite),
		.PCin						(WB.PCin),
		.PCout						(WB.PCout),
		.MemReadTypeW				(WB.MemReadTypeW)
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
		.EX_exception               (Hazard.EX_exception),
		.stall                      (Hazard.stall),
		.done                       (Hazard.done),
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
		.ForwardBE                  (Hazard.ForwardBE)
	);

	Exception_module Exception_module(
		.clk						(clk),
    	.address_error				(1'b0),
    	.memread					(1'b0),					
    	.overflow_error				(1'b0),
    	.syscall					(1'b0),
    	._break						(1'b0),
    	.reversed					(1'b0),
    	.hardware_abortion			(ext_int),
    	.software_abortion			(2'b00),
    	.Status						(Exception.Status),
    	.Cause						(Exception.Cause),
    	.pc							(WB.PCout),
    	.BadVAddr					(Exception.BadVAddr),
    	.EPC						(Exception.EPC),
    	.NewPC						(Exception.NewPc),
    	.we							(Exception.we),
    	.new_Cause_BD1				(Exception.Branch_delay),
    	.exception_occur			(Exception.Stall),
    	.new_Status_EXL				(Exception.EXL),
    	.new_Status_IE				(Exception.new_Status_IE),
    	.Cause_IP					(Exception.enable),
    	.Status_IM					(Exception.Status_IM),
    	.ExcCode					(Exception.ExcCode)
	);


endmodule
