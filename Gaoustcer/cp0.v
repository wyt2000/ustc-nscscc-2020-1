module CP0
    #(parameter WIDTH=32)
(
        input clk,rst,
        input [5:0] hardware_interruption,//6 hardware break
        input [1:0] software_interruption,//2 software interruption
        input we,//write enable signal
        input [4:0] raddr,
        output [WIDTH-1:0] CP0_data,
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
    reg [WIDTH-1:0] Readdata;
    reg [WIDTH-1:0] Index;//0
    reg [WIDTH-1:0] Ramdom;//1
    reg [WIDTH-1:0] EntryLO0;//2
    reg [WIDTH-1:0] EntryLO1;//3
    reg [WIDTH-1:0] Context;//4
    reg [WIDTH-1:0] Pagemask;//5
    reg [WIDTH-1:0] Wired;//6
    reg [WIDTH-1:0] Reserved1;//7
    reg [WIDTH-1:0] BADVADDR;//8 deal with the exception such as TLB miss and address error
    reg [WIDTH-1:0] count;//9 +1 every two clock cycles
    reg [WIDTH-1:0] EntryHi;//10
    reg [WIDTH-1:0] compare;//11
    reg [WIDTH-1:0] Status;//12
    reg [WIDTH-1:0] cause;//13
    reg [WIDTH-1:0] EPC;//14 exception address 
    reg [WIDTH-1:0] prid;//15
    reg [WIDTH-1:0] configure;//16    
    reg [WIDTH-1:0] LLAddr;//17
    reg [WIDTH-1:0] WatchLo;//18
    reg [WIDTH-1:0] WatchHi;//19
    reg [WIDTH-1:0] Reserved2;//20
    reg [WIDTH-1:0] Reserved3;//21
    reg [WIDTH-1:0] Reserved4;//22
    reg [WIDTH-1:0] Debug;//23
    reg [WIDTH-1:0] DEPC;//24
    reg [WIDTH-1:0] Reserved5;//25
    reg [WIDTH-1:0] Errctrl;//26
    reg [WIDTH-1:0] Reserved6;//27
    reg [WIDTH-1:0] Taglo;//28
    reg [WIDTH-1:0] Reserved7;//29
    reg [WIDTH-1:0] ErrorEPC://30
    reg [WIDTH-1:0] DESAVE;//31


    assign EPC_data=EPC;
    assign BADVADDR_data=BADVADDR;
    
    assign count_data=count;
    
    assign Status_data=Status;

    assign cause_data=cause;

    assign configure_data=configure;

    assign prid_data=prid;

    assign compare_data=compare;
    assign Ramdom_data=Ramdom;
    reg temp;
    assign state=Status[1]?1'b0:1;
    reg reg_time_int;
    assign timer_int_data=reg_time_int;
    assign allow_interrupt=Status[0];
    always@(posedge clk or posedge rst)begin
        if(rst)
            EPC<=0;
        else if(waddr==14&&we)
            EPC<=epc;
        else ;

    end
    always@(posedge clk or posedge rst) begin
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
    always@(posedge clk or posedge rst) begin
        if(rst)
            BADVADDR<=0;
        else if(we&&waddr==8)
            BADVADDR<=BADADDR; 
    end
    always@(posedge clk or posedge rst) begin
        if(rst)
            prid<=0;
        else if(waddr==5'd15&&we) 
            prid<=pridin;
        else prid<=prid;
    end
    always@(posedge clk or posedge rst) begin
        if(rst)
            compare<=0;
        else if(waddr==5'd11&&we) begin
            compare<=comparedata;
            reg_time_int<=(compare==count)?((compare!=1'b0)?1:0):0;
        end
            
    end
    always@(posedge clk or posedge rst) begin
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
    always@(posedge clk or posedge rst) begin
        if(rst)
            Ramdom<=32'h00000000;
        else 
            Ramdom<=count; 
    end
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            configure[15]<=1'b1;
            configure[31:16]<=0;
            configure[14:0]<=0;
        end
        else if(waddr==16&&we)begin
            configure<=configuredata;

        end
    end
    always@(posedge clk or posedge rst)begin
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

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            Readdata<=32'h00000000;
        end
        else begin
            case(raddr)
            5'b00000:Readdata<=Index;
            5'b00001:Readdata<=Ramdom;
            5'b00010:Readdata<=EntryLO0;
            5'b00011:Readdata<=EntryLO1;
            5'b00100:Readdata<=Contex;
            5'b00101:Readdata<=Pagemask;
            5'b00101:Readdata<=Wired;
            5'b00111:Readdata<=Reserved1;
            5'b01000:Readdata<=BADVADDR;
            5'b01001:Readdata<=count;
            5'b01010:Readdata<=EntryHi;
            5'b01011:Readdata<=compare;
            5'b01100:Readdata<=Status;
            5'b01101:Readdata<=cause;
            5'b01110:Readdata<=EPC;
            5'b01111:Readdata<=prid;
            5'b10000:Readdata<=configure;
            5'b10001:Readdata<=LLAddr;
            5'b10010:Readdata<=WatchLo;
            5'b10011:Readdata<=WatchHi;
            5'b10100:Readdata<=Reserved2;
            5'b10101:Readdata<=Reserved3;
            5'b10101:Readdata<=Reserved4;
            5'b10111:Readdata<=Debug;
            5'b11000:Readdata<=DEPC;
            5'b11001:Readdata<=Reserved5;
            5'b11010:Readdata<=Errctrl;
            5'b11011:Readdata<=Reserved6;
            5'b11100:Readdata<=Taglo;
            5'b11101:Readdata<=Reserved7;
            5'b11110:Readdata<=ErrorEPC;
            5'b11111:Readdata<=DESAVE;
            default:Readdata<=32'hFFFFFFFF;
            endcase
        end
    end


endmodule