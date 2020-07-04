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
    //output
    logic [31:0] Instruction;
    logic [31:0] PC_add_4;
    logic [31:0] PCout;
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
    logic Imm_sel_and_Branch_taken;
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
    logic [31:0] Jump_addr;
    logic [31:0] Branch_addr;
    logic CLR_EN;
    logic exception;
    logic isBranch;
    logic [31:0] PCout;
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
    logic [2:0] exception;
    logic stall;
    logic [31:0] PCout;
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
    logic [2:0] EX_exception;
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

typedef struct packed {
    //input
    logic Exception_code; //undefined
    logic clk;
    //output
    logic Exception_Stall;
    logic Exception_clean;
    logic Exception_Write_addr_sel;
    logic Exception_Write_data_sel;
    logic [6:0] Exception_RF_addr;
    logic [31:0] Exceptiondata;
} Exception_interface;
