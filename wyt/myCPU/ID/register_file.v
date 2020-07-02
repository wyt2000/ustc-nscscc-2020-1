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
    output      [31:0]  epc
    );

    reg     [31:0]  reg_file[0:31];
    reg             hi, lo;

    wire            reg_file_we, reg_cp0_we;
    wire    [31:0]  CP0_data;
    
    integer         i;

    //read port 1
    always@(*) begin
        if(write_addr == read_addr_1 && regwrite)                                       //forward 1, from normal reg or cp0
            read_data_1 = write_data;
        else if(write_addr == read_addr_1 && read_addr_1[6] && hl_write_enable_from_wb) //forward 2, from hi/lo
            read_data_1 = (read_addr_1 == 7'b1111111) ? hl_data[63:32] : hl_data[31:0];
        else begin
            if(read_addr_1[6])                                                          //if read hi/lo
                read_data_1 = (read_addr_1 == 7'b1111111) ? hi : lo;
            else if(read_addr_1[5])                                                     //if read cp0,output z
                read_data_1 = 7'bzzzzzzz;
            else
                read_data_1 = reg_file[read_addr_1[4:0]];
        end
    end 

    //read port 2
    always@(*) begin
        if(write_addr == read_addr_2 && regwrite)                                       //forward 1, from normal reg or cp0
            read_data_2 = write_data;
        else if(write_addr == read_addr_2 && read_addr_2[6] && hl_write_enable_from_wb) //forward 2, from hi/lo
            read_data_2 = (read_addr_2 == 7'b1111111) ? hl_data[63:32] : hl_data[31:0];
        else begin
            if(read_addr_2[6])                                                          //if read hi/lo
                read_data_2 = (read_addr_2 == 7'b1111111) ? hi : lo;
            else if(read_addr_2[5])                                                     //if read cp0, output cp0
                read_data_2 = CP0_data;
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
            if(reg_file_we)
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

    //CP0
    assign reg_cp0_we = regwrite & ~write_addr[6] & write_addr[5];
    cp0_up #(32) reg_cp0(.clk(clk),
                      .rst(rst),
                      .waddr(write_addr[4:0]),
                      .writedata(write_data),
                      .raddr(read_addr_2[4:0]),
                      .general_write_in(reg_cp0_we),
                      .readdata(CP0_data),
                      .count_data(count_data),
                      .compare_data(compare_data),
                      .Status_data(Status_data),
                      .cause_data(cause_data),
                      .EPC_data(epc),
                      .configure_data(configure_data),
                      .prid_data(prid_data),
                      .BADVADDR_data(BADVADDR_data),
                      .Random_data(Random_data));

endmodule
