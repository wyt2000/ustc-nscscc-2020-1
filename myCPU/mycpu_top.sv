`timescale 1ns / 1ps

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
    logic [31:0] Instruction_in;
    logic Error_happend;
    //output
    logic [31:0] Instruction;
    logic [31:0] PC_add_4;
    logic [31:0] PCout;

    logic is_newPC;
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
    logic [31:0] RAMoutM;
    logic [1:0] ForwardAD;
    logic [1:0] ForwardBD;
    logic [31:0] PCin;
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
    //logic Imm_sel_and_Branch_taken;
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
    logic [31:0] EPC;
    logic IE;
    logic [31:0] Jump_addr;
    logic [31:0] Branch_addr;
    logic CLR_EN;
    logic exception;
    logic isBranch;
    logic [31:0] PCout;
    //added by Gaoustcer
    //logic Exception_EXL;
    logic [31:0]  Status;
    //logic [31:0]  EPC_data;
    logic [31:0]  cause;
    logic [7:0]    Exception_enable;
    logic [31:0]  we;
    logic [7:0]   interrupt_enable;
    logic [4:0]   Exception_code;
    logic Exception_EXL;
    logic [5:0]   hardware_interruption;
    logic [1:0]   software_interruption;
    logic [31:0]  epc;
    logic [31:0]  BADADDR;
    logic Branch_delay;
    logic syscall;
    logic _break;
    logic is_ds;
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
    logic BranchD;
    logic JumpD;
    logic EPC_selD;
    logic [31:0] Branch_addrD;
    logic [31:0] Jump_addrD;
    logic [31:0] PCSrc_regD;
    logic [31:0] EPCD;
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
    logic Branch;
    logic Jump;
    logic EPC_sel;
    logic [31:0] Branch_addr;
    logic [31:0] Jump_addr;
    logic [31:0] PCSrc_reg;
    logic [31:0] EPC;
    logic syscallin;
    logic syscallout;
    logic _breakin;
    logic _breakout;
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
    logic [31:0] RAMtmp;
    logic [31:0] PCin;
    //output
    logic MemtoRegW;
    logic RegWriteW;
    logic HI_LO_write_enableW;
    logic [63:0] HI_LO_dataW;
    logic [31:0] RAMout;
    logic [31:0] ALUoutW;
    logic [6:0] WriteRegisterW;
    logic [3:0] calWE;
    logic [31:0] PCout;
    logic [2:0] MemReadTypeW;
    logic [31:0] TrueRamData;
    logic syscallin;
    logic syscallout;
    logic _breakin;
    logic _breakout;
    logic [3:0] exception_in;
    logic [3:0] exception_out;
    logic MemWriteW;
    logic is_ds_in;
    logic is_ds_out;
} MEM_interface;

typedef struct packed {
    //input
    logic [31:0] aluout;
    logic [31:0] Memdata;
    logic MemtoRegW;
    logic RegWriteW;
    logic [6:0] WritetoRFaddrin;
    logic HI_LO_write_enablein;
    logic [63:0] HILO_data;
    logic Exception_Write_addr_sel;
    logic Exception_Write_data_sel;
    logic HI_LO_writeenablein;
    logic [6:0] Exception_RF_addr;
    logic [31:0] Exceptiondata;
    logic [31:0] PCin;
    logic [2:0] MemReadTypeW;
    //output
    logic [6:0] WritetoRFaddrout;
    logic [31:0] WritetoRFdata;
    logic HI_LO_writeenableout;
    logic [63:0] WriteinRF_HI_LO_data;
    logic RegWrite;
    logic [31:0] PCout;
    logic syscallin;
    logic syscall;
    logic _breakin;
    logic _break;
    logic [3:0] exception_in;
    logic [3:0] exception_out;
    logic MemWrite;
    logic MemWriteW;
    logic is_ds_in;
    logic is_ds_out;
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
    logic stall;
    logic done;
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
} Hazard_interface;

typedef struct packed{
    //input
    logic clk;
    logic address_error;
    logic MemWrite;
    logic overflow_error;
    logic syscall;
    logic _break;
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
    logic [31:0] NewPc;//PC跳转
    logic [31:0] we;//写使能字
    logic Branch_delay;//给cause寄存器赋新值
    logic Stall;//异常发生（Stall，Clear）
    logic clean;
    logic EXL;
    logic enable;
    logic [31:0] epc;
    //logic EXL;//给Status寄存器赋新值
    logic new_Status_IE;//给Status寄存器赋新值
    logic [7:0] Cause_IP;//给cause寄存器赋新值
    logic [7:0] Status_IM;//给Status寄存器赋新值
    logic [4:0] ExcCode;//异常编码
    logic [31:0] ErrorAddr;
    logic isERET;
    logic [7:0] new_Status_IM;
    logic is_ds;
} Exception_interface;


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
	assign data_sram_wdata 					= MEM.TrueRamData;
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
	assign ID.epc							= Exception.EPC;
	assign ID.IE   							= Exception.new_Status_IE;
	assign ID.hardware_interruption			= ext_int;
	assign ID.BADADDR						= Exception.BadVAddr;

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
	assign Hazard.Exception_Stall			= Exception.Stall;
	assign Hazard.Exception_clean			= Exception.Stall;

	assign Exception.Status					= ID.Status;
	assign Exception.Cause					= ID.cause;
	assign Exception.syscall				= WB.syscall;
	assign Exception._break					= WB._break;
    assign Exception.overflow_error         = (WB.exception_out == 1)   ? 1 : 0;
    assign Exception.address_error          = (WB.exception_out == 5)   ? 1 : 0;
	assign Exception.MemWrite 				= WB.MemWrite;
	assign Exception.ErrorAddr				= (WB.exception_out == 5)	? WB.aluout : 0;
	assign Exception.isERET 				= (WB.exception_out == 6)   ? 1 : 0;
	assign Exception.reserved				= (WB.exception_out == 8)	? 1 : 0;
	assign Exception.hardware_abortion		= ext_int;
    assign Exception.software_abortion      = {2{ID.Status[0]}} & ID.Status[9:8] & ID.cause[9:8];
	assign Exception.Status_IM              = ID.Status[15:8];
    assign Exception.is_ds                  = WB.is_ds_out;


	// IF/ID registers

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
	register #(1) ID_EX_syscall (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID.syscall),
		.q(EX.syscallin)
	);

	register #(1) ID_EX_break (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushE),
		.en(~Hazard.StallE),
		.d(ID._break),
		.q(EX._breakin)
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

	register #(1) EX_MEM_syscall (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
		.d(EX.syscallout),
		.q(MEM.syscallin)
	);

	register #(1) EX_MEM_break (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
		.d(EX._breakin),
		.q(MEM._breakout)
	);

    register #(4) EX_MEM_exception (
        .clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushM),
		.en(~Hazard.StallM),
        .d(EX.exception),
        .q(MEM.exception_in)
    );

    register #(4) EX_MEM_is_ds (
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

	register #(1) MEM_WB_syscall (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
		.d(MEM.syscallout),
		.q(WB.syscallin)
	);
	register #(1) MEM_WB_break (
		.clk(clk),
		.rst(rst),
        .Flush(Hazard.FlushW),
		.en(~Hazard.StallW),
		.d(MEM._breakout),
		.q(WB._breakin)
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
        .StallF                     (IF.StallF | IF.is_newPC),
		.PC_add_4                   (IF.PC_add_4),
		.PCout						(IF.PCout),
        .Error_happend				(IF.Error_happend),
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
		.IE							(ID.IE),
    	.EXL						(ID.Exception_EXL),
    	.epc						(ID.epc),
    	.BADADDR					(ID.BADADDR),
    	.Branch_delay				(ID.Branch_delay),
    	.hardware_interruption		(ID.hardware_interruption),
    	.software_interruption		(ID.software_interruption),
		.Status_data				(ID.Status),
    	.cause_data					(ID.cause),
		.isBranch					(ID.isBranch),
		.syscall					(ID.syscall),
		._break						(ID._break),
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
		.EPC						(EX.EPC),
		.syscallin					(EX.syscallin),
		.syscallout					(EX.syscallout),
		._breakin					(EX._breakin),
		._breakout					(EX._breakout),
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
		.syscallin					(MEM.syscallin),
		.syscallout					(MEM.syscallout),
		._breakin					(MEM._breakin),
		._breakout					(MEM._breakout),
        .exception_in               (MEM.exception_in),
        .exception_out              (MEM.exception_out),
		.MemWriteW					(MEM.MemWriteW),
        .is_ds_in                   (MEM.is_ds_in),
        .is_ds_out                  (MEM.is_ds_out)
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
		.MemReadTypeW				(WB.MemReadTypeW),
		.syscallin					(WB.syscallin),
		.syscall					(WB.syscall),
		._breakin					(WB._breakin),
		._break						(WB._break),
        .exception_in               (WB.exception_in),
        .exception_out              (WB.exception_out),
		.MemWriteW					(WB.MemWriteW),
		.MemWrite					(WB.MemWrite),
		.EPCD						(ID.EPC),
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
    	.ExcCode					(Exception.ExcCode),
		.ErrorAddr					(Exception.ErrorAddr),
		.EPCD						(ID.EPC),
		.isERET						(Exception.isERET),
        .new_Status_IM              (Exception.new_Status_IM),
        .is_ds                      (Exception.is_ds)
	);
endmodule