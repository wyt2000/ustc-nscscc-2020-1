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
    
    logic [31:0] instr;

    logic inst_req;
    logic inst_wr;
    logic [1:0] inst_size;
    logic [31:0] inst_addr;
    logic [31:0] inst_wdata;
    logic [31:0] inst_rdata;
    logic [31:0] inst_addr_ok;
    logic [31:0] inst_data_ok;

    logic CLR;
    logic stall;
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
    logic IE;
    logic [31:0] Jump_addr;
    logic [31:0] Branch_addr;
    logic CLR_EN;
    logic exception;
    logic isBranch;
    logic [31:0] PCout;
    logic [31:0]  Status;
    logic [31:0]  cause;
    logic [7:0]    Exception_enable;
    logic [31:0]  we;
    logic [7:0]   interrupt_enable;
    logic [4:0]   Exception_code;
    logic Exception_EXL;
    logic [5:0]   hardware_interruption;
    logic [1:0]   software_interruption;
    logic [31:0]  BADADDR;
    logic Branch_delay;
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
    logic clk;
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
    logic [31:0] NewPc;//PC跳转
    logic [31:0] we;//写使能字
    logic Branch_delay;//给cause寄存器赋新值
    logic Stall;//异常发生（Stall，Clear）
    logic EXL;
    logic [7:0] enable;
    logic [31:0] epc;
    logic new_Status_IE;//给Status寄存器赋新值
    logic [7:0] Cause_IP;//给cause寄存器赋新值
    logic [7:0] Status_IM;//给Status寄存器赋新值
    logic [4:0] ExcCode;//异常编码
    logic [31:0] ErrorAddr;
    logic isERET;
    logic [7:0] new_Status_IM;
    logic is_ds;
	logic [31:0] EPCD;
	logic syscall;
	logic _break;
    logic StallW;
    logic FlushW;
} Exception_interface;

typedef struct packed{
    logic         clk;
    logic         resetn; 

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
    logic [7 :0] arlen        ;
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
    logic [7 :0] awlen        ;
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