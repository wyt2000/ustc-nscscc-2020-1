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
    output      [31:0]  Status_data,
    output      [31:0]  EPC_data,
    output      [31:0]  cause_data,
    input       [31:0]  we,
    input       [4:0]   Exception_code,
    input               EXL,
    input               IE,
    input       [5:0]   hardware_interruption,
    input       [1:0]   software_interruption,
    input       [31:0]  epc,
    input       [31:0]  BADADDR,
    input               Branch_delay
    );

    wire                    timer_int_data;
    wire                    allow_interrupt;
    wire                    STATE;
    wire            [31:0]  BADVADDR_data;

    reg             [31:0]  reg_file[0:31];
    reg             [31:0]  hi, lo;

    wire                    reg_file_we, reg_cp0_we;
    wire            [31:0]  CP0_data;

    wire            [1:0]   forward_type_1, forward_type_2;

    assign      forward_type_1  =   {{write_addr == read_addr_1 && regwrite}, {read_addr_1[6] & hl_write_enable_from_wb}};
    assign      forward_type_2  =   {{write_addr == read_addr_2 && regwrite}, {read_addr_2[6] & hl_write_enable_from_wb}};

    //read port 1
    always@(*) begin
        case({forward_type_1, read_addr_1[6], read_addr_1[5]})
        4'b1000, 4'b1001,
        4'b1010, 4'b1011,
        4'b1100, 4'b1101,
        4'b1110, 4'b1111:   read_data_1     =   write_data;

        4'b0100, 4'b0101,
        4'b0110, 4'b0111:   read_data_1     =   (read_addr_1 == 7'b1111111) ? hl_data[63:32] : hl_data[31:0];

        4'b0010, 4'b0011:   read_data_1     =   (read_addr_1 == 7'b1111111) ? hi : lo;

        4'b0001:            read_data_1     =   7'bzzzzzzz;

        4'b0000:            read_data_1     =   reg_file[read_addr_1[4:0]];
        default:            read_data_1     =   reg_file[read_addr_1[4:0]];
        endcase
        if (read_addr_1 == 7'b0) read_data_1 = 32'b0;
    end

    //read port 2
    always@(*) begin
        case({forward_type_2, read_addr_2[6], read_addr_2[5]})
        4'b1000, 4'b1001,
        4'b1010, 4'b1011,
        4'b1100, 4'b1101,
        4'b1110, 4'b1111:   read_data_2     =   write_data;

        4'b0100, 4'b0101,
        4'b0110, 4'b0111:   read_data_2     =   (read_addr_2 == 7'b1111111) ? hl_data[63:32] : hl_data[31:0];

        4'b0010, 4'b0011:   read_data_2     =   (read_addr_2 == 7'b1111111) ? hi : lo;

        4'b0001:            read_data_2     =   CP0_data;

        4'b0000:            read_data_2     =   reg_file[read_addr_2[4:0]];
        default:            read_data_2     =   reg_file[read_addr_2[4:0]];
        endcase
        if (read_addr_2 == 7'b0) read_data_2 = 32'b0;
    end

    assign reg_file_we = regwrite & ~(write_addr[5] & write_addr[6]);
    always@(posedge clk) begin
        if(reg_file_we && (|write_addr))
                reg_file[write_addr[4:0]] <= write_data;
        reg_file[0] <=  0;
    end

    //hi/lo
    wire    [1:0]    hl_wr_en;
    assign  hl_wr_en    =   {2{hl_write_enable_from_wb}} | {{regwrite && write_addr == 7'b1111111}, {regwrite && write_addr == 7'b1000000}};
    always@(posedge clk) begin
            if(rst) begin
            hi <= 32'b0;
            lo <= 32'b0;
        end
        else case(hl_wr_en)
        2'b01:      begin
            lo  <=  write_data;
        end
        2'b10:      begin
            hi  <=  write_data;
        end
        2'b11:      begin
            hi  <=  hl_data[63:32];
            lo  <=  hl_data[31:0];
        end
        default:    ;
        endcase
    end

    wire [31:0] compare_data,configure_data,prid_data;
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
                      .EXL(EXL),
                      .IE(IE),
                      .Branch_delay(Branch_delay),          
                      .Exception_code(Exception_code),
                      .readdata(CP0_data),
                      .compare_data(compare_data),
                      .Status_data(Status_data),//output
                      .cause_data(cause_data),//output
                      .EPC_data(EPC_data),//output
                      .configure_data(configure_data),
                      .pridin(32'b0),
                      .prid_data(prid_data),
                      .BADVADDR_data(BADVADDR_data),//output
                      .allow_interrupt(allow_interrupt),//output    
                      .state(STATE)//output
                    );
endmodule
