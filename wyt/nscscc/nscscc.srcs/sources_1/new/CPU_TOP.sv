`timescale 1ns / 1ps
`include "interface.sv"

module CPU_TOP(
    input clk,
    input rst
    );

    IF_interface IF;
    ID_interface ID;
    EX_interface EX;
    MEM_interface MEM;
    WB_interface WB;
    Hazard_interface Hazard;
    Exception_interface Exception;

    //Data path across modules without registers
    assign IF.Jump                          = ID.Jump;
    assign IF.BranchD                       = ID.BranchD;
    assign IF.EPC_sel                       = ID.EPC_sel;
    assign IF.EPC                           = ID.EPC;
    assign IF.Jump_reg                      = ID.PCSrc_reg;
    assign IF.Jump_addr                     = ID.Jump_addr;
    assign IF.beq_addr                      = ID.Branch_addr;
    assign IF.StallF                        = Hazard.StallF;
    assign ID.RegWriteW                     = WB.RegWrite;
    assign ID.WriteRegW                     = WB.WritetoRFaddrout;
    assign ID.ResultW                       = WB.WritetoRFdata;
    assign ID.HI_LO_write_enable_from_WB    = WB.HI_LO_writeenableout;
    assign ID.HI_LO_data                    = WB.WriteinRF_HI_LO_data;
    assign ID.ALUoutE                       = EX.ALUResult;
    assign ID.ALUoutM                       = MEM.ALUoutW;
    assign ID.RAMoutM                       = MEM.RAMout;
    assign ID.ForwardAD                     = Hazard.ForwardAD;
    assign ID.ForwardBD                     = Hazard.ForwardBD;
    assign EX.ForwardMEM                    = MEM.RAMout;
    assign EX.ForwardWB                     = WB.WritetoRFdata;
    assign EX.ForwardA                      = Hazard.ForwardAE;
    assign EX.ForwardB                      = Hazard.ForwardBE;
    assign WB.Exception_Write_addr_sel      = Exception.Exception_Write_addr_sel;
    assign WB.Exception_Write_data_sel      = Exception.Exception_Write_data_sel;
    assign WB.Exception_RF_addr             = Exception.Exception_RF_addr;
    assign WB.Exceptiondata                 = Exception.Exceptiondata;
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
    assign Hazard.Exception_Stall           = Exception.Exception_Stall;
    assign Hazard.Exception_clean           = Exception.Exception_clean;
    assign Hazard.RegWriteM                 = MEM.RegWriteM;
    assign Hazard.WriteRegM                 = MEM.WriteRegister;
    assign Hazard.MemReadM                  = MEM.MemReadM;
    assign Hazard.MemtoRegM                 = MEM.MemtoRegM;
    assign Hazard.RegWriteW                 = WB.RegWrite;
    assign Hazard.WriteRegW                 = WB.WritetoRFaddrout;
	assign Hazard.WriteRegE					= EX.WriteRegister;
	assign Hazard.RegWriteE					= EX.RegWrite_o;

    // IF/ID registers

    register #(32) IF_ID_instr (
        .clk(clk),
        .rst(FlushD | CLR_EN),
        .en(~StallD),
        .d(IF.Instruction),
        .q(ID.instr)
    );

    register #(32) IF_ID_pc_plus_4 (
        .clk(clk),
        .rst(FlushD | CLR_EN),
        .en(~StallD),
        .d(IF.PC_add_4),
        .q(ID.pc_plus_4)
    );

    // ID/EX registers

    register #(6) ID_EX_ALUControl (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.ALUOp),
        .q(EX.ALUControl)
	);

	register #(1) ID_EX_ALUSrcA (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.ALUSrcDA),
        .q(EX.ALUSrcA)
	);

	register #(1) ID_EX_ALUSrcB (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.ALUSrcDB),
        .q(EX.ALUSrcB)
	);

	register #(1) ID_EX_RegDst (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.RegDstD),
        .q(EX.RegDst)
	);

	register #(1) ID_EX_MemRead_i (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.MemReadD),
        .q(EX.MemRead_i)
	);

	register #(3) ID_EX_MemReadType_i (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.MemReadType),
        .q(EX.MemReadType_i)
	);

	register #(1) ID_EX_MemWrite_i (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.MemWriteD),
        .q(EX.MemWrite_i)
	);

	register #(1) ID_EX_MemtoReg_i (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.MemtoRegD),
        .q(EX.MemtoReg_i)
	);

	register #(1) ID_EX_hiloWrite_i (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.HI_LO_write_enableD),
        .q(EX.hiloWrite_i)
	);

	register #(1) ID_EX_RegWrite_i (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.RegWriteD),
        .q(EX.RegWrite_i)
	);

	register #(1) ID_EX_immSel (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.Imm_sel_and_Branch_taken),
        .q(EX.immSel)
	);

	register #(32) ID_EX_A (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.RsValue),
        .q(EX.A)
	);

	register #(32) ID_EX_B (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.RtValue),
        .q(EX.B)
	);

	register #(32) ID_EX_PCplus8 (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.pc_plus_8),
        .q(EX.PCplus8)
	);

	register #(7) ID_EX_Rs (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.Rs),
        .q(EX.Rs)
	);

	register #(7) ID_EX_Rt (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.Rt),
        .q(EX.Rt)
	);

	register #(7) ID_EX_Rd (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d(ID.Rd),
        .q(EX.Rd)
	);

	register #(32) ID_EX_imm (
        .clk(clk),
        .rst(FlushE),
        .en(~StallE),
        .d({16'b0, ID.imm}),
        .q(EX.imm)
	);

    // EX/MEM registers
    
	register #(1) EX_MEM_HI_LO_write_enableM (
        .clk(clk),
        .rst(FlushM),
        .en(~StallM),
        .d(EX.hiloWrite_o),
        .q(MEM.HI_LO_write_enableM)
	);

	register #(3) EX_MEM_MemReadType (
        .clk(clk),
        .rst(FlushM),
        .en(~StallM),
        .d(EX.MemReadType_o),
        .q(MEM.MemReadType)
	);

	register #(1) EX_MEM_MemReadM (
        .clk(clk),
        .rst(FlushM),
        .en(~StallM),
        .d(EX.MemRead_o),
        .q(MEM.MemReadM)
	);

	register #(1) EX_MEM_RegWriteM (
        .clk(clk),
        .rst(FlushM),
        .en(~StallM),
        .d(EX.RegWrite_o),
        .q(MEM.RegWriteM)
	);

	register #(1) EX_MEM_MemtoRegM (
        .clk(clk),
        .rst(FlushM),
        .en(~StallM),
        .d(EX.MemtoReg_o),
        .q(MEM.MemtoRegM)
	);

	register #(1) EX_MEM_MemWriteM (
        .clk(clk),
        .rst(FlushM),
        .en(~StallM),
        .d(EX.MemWrite_o),
        .q(MEM.MemWriteM)
	);

	register #(64) EX_MEM_HI_LO_dataM (
        .clk(clk),
        .rst(FlushM),
        .en(~StallM),
        .d(EX.hiloData),
        .q(MEM.HI_LO_dataM)
	);

	register #(32) EX_MEM_ALUout (
        .clk(clk),
        .rst(FlushM),
        .en(~StallM),
        .d(EX.ALUResult),
        .q(MEM.ALUout)
	);

	register #(32) EX_MEM_RamData (
        .clk(clk),
        .rst(FlushM),
        .en(~StallM),
        .d(EX.MemData),
        .q(MEM.RamData)
	);

	register #(7) EX_MEM_WriteRegister (
        .clk(clk),
        .rst(FlushM),
        .en(~StallM),
        .d(EX.WriteRegister),
        .q(MEM.WriteRegister)
	);

    // MEM/WB registers

    register #(1) MEM_WB_MemtoRegW (
        .clk(clk),
        .rst(FlushW),
        .en(~StallW),
        .d(MEM.MemtoRegW),
        .q(WB.MemtoRegW)
	);

	register #(1) MEM_WB_RegWriteW (
        .clk(clk),
        .rst(FlushW),
        .en(~StallW),
        .d(MEM.RegWriteW),
        .q(WB.RegWriteW)
	);

	register #(1) MEM_WB_HI_LO_writeenablein (
        .clk(clk),
        .rst(FlushW),
        .en(~StallW),
        .d(MEM.HI_LO_write_enableW),
        .q(WB.HI_LO_writeenablein)
	);

	register #(64) MEM_WB_HILO_data (
        .clk(clk),
        .rst(FlushW),
        .en(~StallW),
        .d(MEM.HI_LO_dataW),
        .q(WB.HILO_data)
	);

	register #(32) MEM_WB_Memdata (
        .clk(clk),
        .rst(FlushW),
        .en(~StallW),
        .d(MEM.RAMout),
        .q(WB.Memdata)
	);

	register #(32) MEM_WB_aluout (
        .clk(clk),
        .rst(FlushW),
        .en(~StallW),
        .d(MEM.ALUoutW),
        .q(WB.aluout)
	);

	register #(7) MEM_WB_WritetoRFaddrin (
        .clk(clk),
        .rst(FlushW),
        .en(~StallW),
        .d(MEM.WriteRegisterW),
        .q(WB.WritetoRFaddrin)
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
        .StallF                     (IF.StallF),
        .Instruction                (IF.Instruction),
        .PC_add_4                   (IF.PC_add_4)
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
        .RAMoutM                    (ID.RAMoutM),
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
        .Imm_sel_and_Branch_taken   (ID.Imm_sel_and_Branch_taken),
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
        .CLR_EN                     (ID.CLR_EN),
        .exception                  (ID.exception)
    );

    EX_module EX_module(
        .clk                        (clk),
        .rst                        (rst),
        .hiloWrite_i                (EX.hiloWrite_i),
        .MemReadType_i              (EX.MemReadType_i),
        .RegWrite_i                 (EX.RegWrite_i),
        .MemtoReg_i                 (EX.MemtoReg_i),
        .MemWrite_i                 (EX.MemWrite_i),
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
        .Rs_o                       (EX.Rs_o),
        .Rt_o                       (EX.Rt_o),
        .hiloData                   (EX.hiloData),
        .ALUResult                  (EX.ALUResult),
        .done                       (EX.done),
        .exception                  (EX.exception),
        .stall                      (EX.stall),
        .MemData                    (EX.MemData),
        .WriteRegister              (EX.WriteRegister)
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
        .RAMout                     (MEM.RAMout),
        .ALUoutW                    (MEM.ALUoutW),
        .WriteRegisterW             (MEM.WriteRegisterW)
    );

    WB_module WB_module(
        .aluout                     (WB.aluout),
        .Memdata                    (WB.Memdata),
        .WritetoRFaddrin            (WB.WritetoRFaddrin),
        .MemtoRegW                  (WB.MemtoRegW),
        .RegWriteW                  (WB.RegWriteW),
        .Exception_Write_addr_sel   (WB.Exception_Write_addr_sel),
        .Exception_Write_data_sel   (WB.Exception_Write_data_sel),
        .Exception_RF_addr          (WB.Exception_RF_addr),
        .Exceptiondata              (WB.Exceptiondata),
        .HILO_data                  (WB.HILO_data),
        .WriteinRF_HI_LO_data       (WB.WriteinRF_HI_LO_data),
        .HI_LO_writeenablein        (WB.HI_LO_writeenablein),
        .WritetoRFaddrout           (WB.WritetoRFaddrout),
        .HI_LO_writeenableout       (WB.HI_LO_writeenableout),
        .WritetoRFdata              (WB.WritetoRFdata),
        .RegWrite                   (WB.RegWrite)
    );

    Hazard_module Hazard_module(
        .BranchD                    (Hazard.BranchD),
        .RsD                        (Hazard.RsD),
        .RtD                        (Hazard.RtD),
        .ID_exception               (Hazard.ID_exception),
		.isaBranchInstrution		(Hazard.isaBranchInstrution),
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
        .clk                        (clk),
        .Exception_code             (Exception.Exception_code),
        .Exception_Stall            (Exception.Exception_Stall),
        .Exception_Stall            (Exception.Exception_clean),
        .Exception_Write_addr_sel   (Exception.Exception_Write_addr_sel),
        .Exception_Write_data_sel   (Exception.Exception_Write_data_sel),
        .Exception_RF_addr          (Exception.Exception_RF_addr),
        .Exceptiondata              (Exception.Exceptiondata)
    );

endmodule
