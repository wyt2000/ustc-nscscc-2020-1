module CP0
    #(parameter WIDTH=32)
(
        input clk,rst,
        input [5:0] hardware_interruption,//6 hardware break
        input [1:0] software_interruption,//2 software interruption
        input [WIDTH-1:0] we,//write enable signal
        input general_write_in,
        input [4:0] raddr,
        output [WIDTH-1:0] CP0_data,
        input [4:0] waddr,//write address of CP0
        input [WIDTH-1:0] BADADDR,//the virtual address that has mistakes
        input [WIDTH-1:0] comparedata,//the data write to the compare
        input [WIDTH-1:0] configuredata,
        input [WIDTH-1:0] epc,
        input [WIDTH-1:0] pridin,
        input [7:0] interrupt_enable,
        input EXL,
        input IE,
        input Branch_delay,
        input [4:0] Exception_code,
        output [WIDTH-1:0] compare_data,
        output [WIDTH-1:0] Status_data,
        output [WIDTH-1:0] cause_data,
        output [WIDTH-1:0] EPC_data,
        output [WIDTH-1:0] configure_data,
        output [WIDTH-1:0] prid_data,
        output [WIDTH-1:0] BADVADDR_data,
        output allow_interrupt,
        output state,//user mode:0 kernel mode:1

        input [31:0] Index_in,
        input [31:0] EntryLo0_in,
        input [31:0] EntryLo1_in,
        input [31:0] PageMask_in,
        input [31:0] EntryHi_in,

        output [31:0] Index_data,
        output [31:0] EntryLo0_data,
        output [31:0] EntryLo1_data,
        output [31:0] PageMask_data,
        output [31:0] EntryHi_data
);  

    reg [31:0]      Index;  //0
    reg [31:0]      EntryLo0;//2
    reg [31:0]      EntryLo1;//3
    reg [31:0]      PageMask;//5
    reg [31:0]      EntryHi;//10

    reg [WIDTH-1:0] Readdata;
    reg [WIDTH-1:0] BADVADDR;//8 deal with the exception such as TLB miss and address error
    reg [WIDTH-1:0] count;//9 +1 every two clock cycles
    reg [WIDTH-1:0] Status;//12 The Status of the processor
    reg [WIDTH-1:0] cause;//13 The cause of the last Interrupt
    reg [WIDTH-1:0] EPC;//14 exception address 
    reg [WIDTH-1:0] prid;//15 The information of the processor
    reg [WIDTH-1:0] configure;//16  config some information of the processor 
    assign CP0_data = Readdata;
    assign EPC_data=EPC;
    assign BADVADDR_data=BADVADDR;
    assign Status_data=Status;
    assign cause_data=cause;
    assign configure_data=configure;
    assign prid_data=prid;
    assign compare_data=0;
    assign Index_data   =   Index;
    assign EntryLo0_data=   EntryLo0;
    assign EntryLo1_data=   EntryLo1;
    assign PageMask_data=   PageMask;
    assign EntryHi_data =   EntryHi;

    reg temp;
    assign state = Status[1]?1'b0:1;
    assign allow_interrupt = Status[0];
    
    always@(posedge clk) begin
        if(rst)
            Index   <=  32'b0;
        else if(we[0]) begin
            Index[31]   <=  Index_in[31];
            Index[2:0]  <=  Index_in[2:0];
        end
        else if(waddr == 0 && general_write_in)
            Index[2:0]  <=  Index_in[2:0];
    end

    always@(posedge clk) begin
        if(rst)
            EntryLo0    <=  32'b0;
        else if(we[2] || (waddr == 2 && general_write_in)) begin
            EntryLo0[25:0]  <=  EntryLo0_in[25:0];
        end
    end

    always@(posedge clk) begin
        if(rst)
            EntryLo1    <=  32'b0;
        else if(we[3] || (waddr == 3 && general_write_in)) begin
            EntryLo1[25:0]  <=  EntryLo1_in[25:0];
        end
    end

    always@(posedge clk) begin
        if(rst)
            PageMask    <=  32'd0;
        else if(we[5] || (waddr == 5 && general_write_in)) begin
            PageMask[24:13] <=  PageMask_in[24:13];
        end
    end

    always@(posedge clk) begin
        if(rst)
            EntryHi     <=  32'b0;
        else if(we[10] || (waddr == 10 && general_write_in)) begin
            EntryHi[31:13]  <=  EntryHi_in[31:13];
            EntryHi[7:0]    <=  EntryHi_in[7:0];
        end
    end

    always@(posedge clk)begin
        if(rst)
            EPC<=0;
        else if(we[14] || (waddr == 14 && general_write_in) )
            EPC<=epc;
    end

    always@(posedge clk) begin
        if(rst)
            temp<=0;
        else 
            temp<=~temp;
    end

    always@(posedge clk) begin
        if(rst) 
            count<=0;
        else count<=count+temp;
    end

    always@(posedge clk) begin
        if(rst)
            BADVADDR<=0;
        else if(we[8] || (waddr == 8 && general_write_in) )
            BADVADDR<=BADADDR; 
    end

    always@(posedge clk) begin
        if(rst)
            prid<=0;
        else if(we[15] || (waddr == 15 && general_write_in) ) 
            prid<=pridin;
    end

    always@(posedge clk) begin
        if(rst) begin
            Status[31:23]<=9'b000000000;//read only can't be modified 
            Status[22]<=1'b1;//read only can't be modified
            Status[21:16]<=6'b000000;//read only can't be modified
            Status[15:8]<=8'b00000000;//0:Break can take 1:Break can't take
            Status[7:2]<=6'b000000;//read only and always 0
            Status[1]<=1'b0;//EXL 0:normal state 1:Kernel state
            Status[0]<=1'b0;//IE  1:all breaks enable 0:all not enable
        end
        else if(we[12]) begin
            Status[1]<=EXL;
        end
        else if(waddr==12&&general_write_in)begin
            Status[15:8]<=interrupt_enable;
            Status[1]<=EXL;
            Status[0]<=IE;
        end
    end

    always@(posedge clk)begin
        if(rst)begin
            configure[15]<=1'b1;
            configure[31:16]<=0;
            configure[14:0]<=0;
        end
        else if(we[16] || (waddr == 16 && general_write_in) )begin
            configure<=configuredata;
        end
    end

    always@(posedge clk)begin
        if(rst)
            cause<=0;
        else if(we[13])begin
            cause[31]<=Branch_delay;
            cause[15]<=(Status[0]&&Status[15]&&(Status[1]==0))?hardware_interruption[5]:1'b0;
            cause[14]<=(Status[0]&&Status[14]&&(Status[1]==0))?hardware_interruption[4]:1'b0;
            cause[13]<=(Status[0]&&Status[13]&&(Status[1]==0))?hardware_interruption[3]:1'b0;
            cause[12]<=(Status[0]&&Status[12]&&(Status[1]==0))?hardware_interruption[2]:1'b0;
            cause[11]<=(Status[0]&&Status[11]&&(Status[1]==0))?hardware_interruption[1]:1'b0;
            cause[10]<=(Status[0]&&Status[10]&&(Status[1]==0))?hardware_interruption[0]:1'b0;
            cause[6:2]<=Exception_code;
        end 
        else if(waddr==13&&general_write_in)begin
            cause[9]<=software_interruption[1];
            cause[8]<=software_interruption[0];
        end
    end

    always@(*) begin
        if(rst) begin
            Readdata=32'h00000000;
        end
        else begin
            case(raddr)
            5'b01000:Readdata=BADVADDR;
            5'b01001:Readdata=count;
            5'b01100:Readdata=Status;
            5'b01101:Readdata=cause;
            5'b01110:Readdata=EPC;
            5'b01111:Readdata=prid;
            5'b10000:Readdata=configure;
            5'd0    :Readdata=Index;
            5'd2    :Readdata=EntryLo0;
            5'd3    :Readdata=EntryLo1;
            5'd5    :Readdata=PageMask;
            5'd10   :Readdata=EntryHi;
            default:Readdata=32'hFFFFFFFF;
            endcase
        end
    end


endmodule

module cp0_up
	#(parameter WIDTH=32)
	(
		input [4:0] waddr,
        input clk,rst,
		input [WIDTH-1:0] writedata,
		input [4:0] raddr,
        input [5:0] hardware_interruption,//6 hardware break
        input [1:0] software_interruption,//2 software interruption
        input [WIDTH-1:0] we,//write enable signal
        input general_write_in,
        input [WIDTH-1:0] BADADDR,//the virtual address that has mistakes
        input [WIDTH-1:0] comparedata,//the data write to the compare，没用
        input [WIDTH-1:0] configuredata,//没用
        input [WIDTH-1:0] epc,
        input [WIDTH-1:0] pridin,//没用
        input [7:0] interrupt_enable,
        input EXL,
        input IE,
        input Branch_delay,
        input [4:0] Exception_code,
		output [WIDTH-1:0] readdata,//无条件读
        output [WIDTH-1:0] compare_data,
        output [WIDTH-1:0] Status_data,
        output [WIDTH-1:0] cause_data,
        output [WIDTH-1:0] EPC_data,
        output [WIDTH-1:0] configure_data,
        output [WIDTH-1:0] prid_data,
        output [WIDTH-1:0] BADVADDR_data,
        output allow_interrupt,
        output state,//user mode:0 kernel mode:1

        input [31:0] Index_in,
        input [31:0] EntryLo0_in,
        input [31:0] EntryLo1_in,
        input [31:0] PageMask_in,
        input [31:0] EntryHi_in,

        output [31:0] Index_data,
        output [31:0] EntryLo0_data,
        output [31:0] EntryLo1_data,
        output [31:0] PageMask_data,
        output [31:0] EntryHi_data
	);
    reg [5:0] r_hardware_interruption;//6 hardware break
    reg [1:0] r_software_interruption;//2 software interruption
    reg [WIDTH-1:0] r_BADADDR;//the virtual address that has mistakes
    reg [WIDTH-1:0] r_comparedata;//the data write to the compare
    reg [WIDTH-1:0] r_configuredata;
    reg [WIDTH-1:0] r_epc;
    reg [WIDTH-1:0] r_pridin;
    reg [7:0] r_interrupt_enable;
    reg r_EXL;
    reg r_IE;
    reg r_Branch_delay;
    reg [4:0] r_Exception_code; 
    reg [31:0] r_Index;
    reg [31:0] r_EntryLo0;
    reg [31:0] r_EntryLo1;
    reg [31:0] r_PageMask;
    reg [31:0] r_EntryHi;
         
    always@(*) begin
        r_hardware_interruption              = we[13] ? hardware_interruption : 0;
        r_software_interruption              = we[13] ? software_interruption : 0;
        r_BADADDR                            = we[8] ? BADADDR : 0;
        r_comparedata                        = we[11] ? comparedata : 0;
        r_configuredata                      = we[16] ? configuredata : 0;
        r_epc                                = we[14] ? epc : 0;
        r_pridin                             = we[15] ? pridin : 0;
        r_interrupt_enable                   = 0;
        r_EXL                                = we[12] ? EXL : 0;
        r_IE                                 = we[12] ? IE : 0;
        r_Branch_delay                       = we[13] ? Branch_delay : 0;
        r_Exception_code                     = we[13] ? Exception_code : 0;
        r_Index                              = we[0]  ? Index_in : 0;
        r_EntryLo0                           = we[2]  ? EntryLo0_in : 0;
        r_EntryLo1                           = we[3]  ? EntryLo1_in : 0;
        r_PageMask                           = we[5]  ? PageMask_in : 0;
        r_EntryHi                            = we[10] ? EntryHi_in : 0;
        if(we == 0) begin
            case(waddr)
                5'b01000: r_BADADDR                      = writedata;
                5'b01110: r_epc                          = writedata;
                5'b01111: r_pridin                       = writedata;
                5'b10000: r_configuredata                = writedata;
                5'b01011: r_comparedata                  = writedata;
                5'b01100:begin
                    r_interrupt_enable                   = writedata[15:8];
                    r_EXL                                = writedata[1];
                    r_IE                                 = writedata[0];
                end
                5'b01101:begin
                    r_software_interruption              = writedata[9:8];
                    r_Exception_code                     = writedata[6:2];
                end
                5'b00000: r_Index                        = writedata;
                5'b00010: r_EntryLo0                     = writedata;
                5'b00011: r_EntryLo1                     = writedata;
                5'b00101: r_PageMask                     = writedata;
                5'b01010: r_EntryHi                      = writedata;
            endcase
        end
    end
	
    CP0 cp0_pipeline(
        .clk(clk),.rst(rst),
        .hardware_interruption(r_hardware_interruption),//6 hardware break
        .software_interruption(r_software_interruption),//2 software interruption
        .general_write_in(general_write_in),
        .raddr(raddr),
        .we(we),
        .CP0_data(readdata),
        .waddr(waddr),//write address of CP0
        .BADADDR(r_BADADDR),//the virtual address that has mistakes
        .comparedata(r_comparedata),//the data write to the compare
        .configuredata(r_configuredata),
        .epc(r_epc),
        .pridin(r_pridin),
        .EXL(r_EXL),
        .IE(r_IE),
        .Branch_delay(r_Branch_delay),
        .Exception_code(r_Exception_code),
        .interrupt_enable(r_interrupt_enable),
        .compare_data(compare_data),
        .Status_data(Status_data),
        .cause_data(cause_data),
        .EPC_data(EPC_data),
        .configure_data(configure_data),
        .prid_data(prid_data),
        .BADVADDR_data(BADVADDR_data),
        .allow_interrupt(allow_interrupt),
        .state(state),//user mode:0 kernel mode:1

        .Index_in(r_Index),
        .EntryLo0_in(r_EntryLo0),
        .EntryLo1_in(r_EntryLo1),
        .PageMask_in(r_PageMask),
        .EntryHi_in(r_EntryHi),

        .Index_data(Index_data),
        .EntryLo0_data(EntryLo0_data),
        .EntryLo1_data(EntryLo1_data),
        .PageMask_data(PageMask_data),
        .EntryHi_data(EntryHi_data)
    );  

endmodule