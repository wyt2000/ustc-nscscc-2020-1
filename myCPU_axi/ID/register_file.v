`timescale 1ns / 1ps

module register_file(
    input               clk,
    input               rst,
    input               regwrite,
    input               hl_write_enable_from_wb,
    input       [6:0]   read_addr_1,
    input       [6:0]   read_addr_2,
    input       [63:0]  hl_data,
    input       [6:0]   write_addr,
    input       [31:0]  write_data,
    output reg  [31:0]  read_data_1,
    output reg  [31:0]  read_data_2,
     //output      [31:0]  epc
    //for the change in Error_detect module
    output      [31:0]  Status_data,
    output      [31:0]  EPC_data,
    output      [31:0]  cause_data,
    input       [31:0]  we,
    input       [7:0]   interrupt_enable,
    input       [4:0]   Exception_code,
    input               EXL,
    input               IE,
    input       [5:0]   hardware_interruption,
    input       [1:0]   software_interruption,
    input       [31:0]  epc,
    input       [31:0]  BADADDR,
    input               Branch_delay,
    //以下接口暂时用不到
    output              timer_int_data,
    output              allow_interrupt,
    output              STATE,
    output      [31:0]  BADVADDR_data
    );

    reg     [31:0]  reg_file[0:31];
    reg     [31:0]  hi, lo;

    wire            reg_file_we, reg_cp0_we;
    wire    [31:0]  CP0_data;
    
    integer         i;

    //read port 1
    always@(*) begin
        if(write_addr == read_addr_1 && regwrite)                                       //forward 1, from normal reg or cp0
            read_data_1 = write_data;
        else if(/*write_addr == read_addr_1 &&*/ read_addr_1[6] && hl_write_enable_from_wb) //forward 2, from hi/lo
            read_data_1 = (read_addr_1 == 7'b1111111) ? hl_data[63:32] : hl_data[31:0];
        else begin
            if(read_addr_1[6])                                                          //if read hi/lo
                read_data_1 = (read_addr_1 == 7'b1111111) ? hi : lo;
            else if(read_addr_1[5])                                                     //if read cp0,output z
                read_data_1 = 7'bzzzzzzz;
            else if(read_addr_1 == 32'b0)
                read_data_1 = 32'b0;
            else
                read_data_1 = reg_file[read_addr_1[4:0]];
        end
    end 

    //read port 2
    always@(*) begin
        if(write_addr == read_addr_2 && regwrite)                                       //forward 1, from normal reg or cp0
            read_data_2 = write_data;
        else if(/*write_addr == read_addr_2 && */read_addr_2[6] && hl_write_enable_from_wb) //forward 2, from hi/lo
            read_data_2 = (read_addr_2 == 7'b1111111) ? hl_data[63:32] : hl_data[31:0];
        else begin
            if(read_addr_2[6])                                                          //if read hi/lo
                read_data_2 = (read_addr_2 == 7'b1111111) ? hi : lo;
            else if(read_addr_2[5])                                                     //if read cp0, output cp0
                read_data_2 = CP0_data;
            else if(read_addr_2 == 32'b0)
                read_data_2 = 32'b0;
            else
                read_data_2 = reg_file[read_addr_2[4:0]];
        end
    end 

    assign reg_file_we = regwrite & ~(write_addr[5] & write_addr[6]);
    always@(posedge clk) begin
        //normal regs ctrl
        if(rst) begin
            for(i = 0; i < 32; i = i + 1)
                reg_file[i] <= 0;
        end
        else begin
            if(reg_file_we && write_addr)
                reg_file[write_addr[4:0]] <= write_data;
        end
    end

    //hi/lo
    always@(posedge clk) begin
        if(rst) begin
            hi <= 0;
            lo <= 0;
        end
        if(regwrite && write_addr == 7'b1111111)
            hi <= write_data;
        if(regwrite && write_addr == 7'b1000000)
            lo <= write_data;
        if(hl_write_enable_from_wb) begin
            hi <= hl_data[63:32];
            lo <= hl_data[31:0];
        end
    end
    wire [31:0] count_data,compare_data,configure_data,prid_data,
    Random_data;
    //CP0
    assign reg_cp0_we = regwrite & ~write_addr[6] & write_addr[5];
    assign timer_int_data = 0;
    cp0_up #(32) reg_cp0(.clk(clk),
                      .rst(rst),
                      .waddr(write_addr[4:0]),
                      .writedata(write_data),
                      .raddr(read_addr_2[4:0]),
                      .hardware_interruption(hardware_interruption),
                      .software_interruption(software_interruption),
                      .we(we),
                      .general_write_in(reg_cp0_we),
                      .BADADDR(BADADDR),
                      .comparedata(32'h00000000),
                      .configuredata(32'h00000000),
                      .epc(epc),
                      .interrupt_enable(interrupt_enable),
                      .EXL(EXL),
                      .IE(IE),
                      .Branch_delay(Branch_delay),          
                      .Exception_code(Exception_code),
                      .readdata(CP0_data),
                      .count_data(count_data),
                      .compare_data(compare_data),
                      .Status_data(Status_data),//output
                      .cause_data(cause_data),//output
                      .EPC_data(EPC_data),//output
                      .configure_data(configure_data),
                      .pridin(32'b0),
                      .prid_data(prid_data),
                      .Random_data(Random_data),
                      .BADVADDR_data(BADVADDR_data),//output
                      .allow_interrupt(allow_interrupt),//output    
                      .state(STATE)//output
                    );
endmodule
