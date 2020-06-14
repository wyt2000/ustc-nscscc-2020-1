module CP0
    #(parameter WIDTH=32)
(
        input clk,rst,
        input [5:0] hardware_interruption,//6 hardware break
        input [1:0] software_interruption,//2 software interruption
        input we,//write enable signal
        input [4:0] waddr,//write address of CP0
        input [WIDTH-1:0] BADADDR,//the virtual address that has mistakes
        input [WIDTH-1:0] comparedata,//the data write to the compare
        input [WIDTH-1:0] configuredata,
        input [WIDTH-1:0] epc,
        input [WIDTH-1:0] pridin,
        input [7:0] interrupt_enable;
        input EXL,
        input IE,
        input Branch_delay,
        input [4:0] Exception_code,
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
    reg [WIDTH-1:0] EPC;//exception address 
    assign EPC_data=EPC;
    reg [WIDTH-1:0] BADVADDR;//deal with the exception such as TLB miss and address error
    assign BADVADDR_data=BADVADDR;
    reg [WIDTH-1:0] count;//+1 every two clock cycles
    assign count_data=count;
    reg [WIDTH-1:0] Status;//
    assign Status_data=Status;
    reg [WIDTH-1:0] cause;
    assign cause_data=cause;
    reg [WIDTH-1:0] configure;
    assign configure_data=configure;
    reg [WIDTH-1:0] prid;
    assign prid_data=prid;
    reg [WIDTH-1:0] compare;
    assign compare_data=compare;
    reg [WIDTH-1:0] Ramdom;
    assign Ramdom_data=Ramdom;
    reg temp;
    assign state=Status[1]?1'b0:1;
    reg reg_time_int;
    assign timer_int_data=reg_time_int;
    assign allow_interrupt=Status[0];
    always@(posedge clk)begin
        if(rst)
            EPC<=0;
        else if(waddr==14&&we)
            EPC<=epc;
        else ;

    end
    always@(posedge clk) begin
        if(rst)
            temp<=0;
        else 
            temp<=~temp;
    end
    always@(temp) begin
        if(rst) 
            count=0;
        else count=count+temp;
    end
    always@(posedge clk) begin
        if(rst)
            BADVADDR<=0;
        else if(we&&waddr==8)
            BADVADDR<=BADADDR; 
    end
    always@(posedge clk) begin
        if(rst)
            prid<=0;
        else if(waddr==5'd15&&we) 
            prid<=pridin;
        else prid<=prid;
    end
    always@(posedge clk) begin
        if(rst)
            compare<=0;
        else if(waddr==5'd11&&we) begin
            compare<=comparedata;
            reg_time_int<=(compare==count)?((compare!=1'b0)?1:0):0;
        end
            
    end
    always@(posedge clk) begin
        if(rst) begin
            Status[31:23]<=9'b000000000;//read only can't be modified 
            Status[22]<=1'b1;//read only can't be modified
            Status[21:16]<=6'b000000;//read only can't be modified
            Status[15:8]<=8'b11111111;//0:Break can take 1:Break can't take
            Status[7:2]<=6'b000000;//read only and always 0
            Status[1]<=1'b0;//EXL 0:normal state 1:Kernel state
            Status[0]<=1'b1;//IE  1:all breaks enable 0:all not enable
        end
        else if(waddr==12&&we) begin
            Status[15:8]<=interrupt_enable;
            Status[1]<=EXL;
            Status[0]<=IE;
        end
    end
    always@(posedge clk) begin
        if(rst)
            Ramdom<=32'h00000000;
        else 
            Ramdom<=count; 
    end
    always@(posedge clk)begin
        if(rst)begin
            configure[15]<=1'b1;
            configure[31:16]<=0;
            configure[14:0]<=0;
        end
        else if(waddr==16&&we)begin
            configure<=configuredata;

        end
    end
    always@(posedge clk)begin
        if(rst)
            cause<=0;
        else if(waddr==14&&we)begin
            cause[31]<=Branch_delay;
            cause[15]<=(Status[0]&&Status[15]&&(Status[1]==0))?hardware_interruption[5]:1'b0;
            cause[14]<=(Status[0]&&Status[14]&&(Status[1]==0))?hardware_interruption[4]:1'b0;
            cause[13]<=(Status[0]&&Status[13]&&(Status[1]==0))?hardware_interruption[3]:1'b0;
            cause[12]<=(Status[0]&&Status[12]&&(Status[1]==0))?hardware_interruption[2]:1'b0;
            cause[11]<=(Status[0]&&Status[11]&&(Status[1]==0))?hardware_interruption[1]:1'b0;
            cause[10]<=(Status[0]&&Status[10]&&(Status[1]==0))?hardware_interruption[0]:1'b0;
            cause[9]<=(Status[0]&&Status[9]&&(Status[1]==0))?software_interruption[1]:1'b0;
            cause[8]<=(Status[0]&&Status[8]&&(Status[1]==0))?software_interruption[0]:1'b0;
            cause[6:2]<=Exception_code;
        end 
    end


endmodule