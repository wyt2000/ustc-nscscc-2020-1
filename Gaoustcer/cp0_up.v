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
        //input [1:0] cause,
        input EXL,
        input IE,//扩展接口，没用，置为1
        input Branch_delay,
        input [4:0] Exception_code,
		output [WIDTH-1:0] readdata,//无条件读
        output [WIDTH-1:0] count_data,
        output [WIDTH-1:0] compare_data,
        output [WIDTH-1:0] Status_data,
        output [WIDTH-1:0] cause_data,
        output [WIDTH-1:0] EPC_data,
        output [WIDTH-1:0] configure_data,
        output [WIDTH-1:0] prid_data,
        output [WIDTH-1:0] BADVADDR_data,
        output [WIDTH-1:0] Ramdom_data,
        output timer_int_data,//when compare==count, create a break
        output allow_interrupt,
        output state//user mode:0 kernel mode:1


	);
    //reg [1:0] r_cause;
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
    
	cp0 cp0_pipeline(
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
        .interrupt_enable(r_interrupt_enable),
        .EXL(r_EXL),
        .IE(r_IE),
        .Branch_delay(r_Branch_delay),
        .Exception_code(r_Exception_code),
        .count_data(count_data),
        .compare_data(compare_data),
        .Status_data(Status_data),
        .cause_data(cause_data),
        .EPC_data(EPC_data),
        .configure_data(configure_data),
        .prid_data(prid_data),
        .BADVADDR_data(BADVADDR_data),
        .Ramdom_data(Ramdom_data),
        .timer_int_data(timer_int_data),//when compare==count, create a break
        .allow_interrupt(allow_interrupt),
        .state(state)//user mode:0 kernel mode:1
);  
        always@(waddr or we)
        if(we==0) begin
            case(waddr)
            5'b01000:r_BADADDR=writedata;
            5'b01110:r_epc=writedata;
            5'b01111:r_pridin=writedata;
            5'b10000:r_configuredata=writedata;
            5'b01011:r_comparedata=writedata;
            5'b01100:begin
                r_interrupt_enable=writedata[15:8];
                r_EXL=writedata[1];
                r_IE=writedata[0];
            end
            5'b01101:begin
                r_hardware_interruption=writedata[15:10];
                r_software_interruption=writedata[9:8];
                //r_cause=writedata[9:8];
                r_Exception_code=writedata[6:2];
            end
            default :;
            endcase
        end
        else begin
            //r_cause=we[13]?cause:0;
            r_hardware_interruption=we[13]?hardware_interruption:0;
            r_software_interruption=we[13]?software_interruption:0;
            r_BADADDR=we[8]?BADADDR:0;
            r_comparedata=we[11]?comparedata:0;
            r_configuredata=we[16]?configuredata:0;
            r_epc=we[14]?epc:0;
            r_pridin=we[15]?pridin:0;
            r_interrupt_enable=we[12]?interrupt_enable:0;
            r_EXL=we[12]?EXL:0;
            r_IE=we[12]?IE:0;
            r_Branch_delay=we[13]?Branch_delay:0;
            r_Exception_code=we[13]?Exception_code:0;
        end


endmodule