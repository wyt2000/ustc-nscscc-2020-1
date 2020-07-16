`timescale 1ns / 1ps

module data_sram
(
    input          clk,
    input          rst,

    //sram
    output  reg         data_req     ,
    output  reg         data_wr      ,
    output  reg [1 :0]  data_size    ,
    output  reg [31:0]  data_addr    ,
    output  reg [31:0]  data_wdata   ,
    input       [31:0]  data_rdata   ,
    input               data_addr_ok ,
    input               data_data_ok ,

    input          MemRead,
    input   [3:0]  MemWrite,
    input   [31:0] addr,
    input   [31:0] wdata,
    output  reg    CLR,
    output  reg    stall
);

    parameter IDLE  =   2'b00;
    parameter HDSK  =   2'b01;
    parameter WAIT  =   2'b10;
    parameter RECV  =   2'b11;

    reg     [1:0]   current_state, next_state;
    reg     [31:0]  reg_addr, reg_wdata;
    reg     [3:0]   reg_MemWrite;

    always@(posedge clk) begin
        if(rst) begin
            reg_addr <= 0;
            reg_wdata <= 0;
            reg_MemWrite <= 0;
        end
        else if(MemRead) begin
            reg_addr <= addr;
            reg_wdata <= 0;
            reg_MemWrite <= 0;
        end
        else if(|MemWrite) begin
            reg_addr <= addr;
            reg_wdata <= wdata;
            reg_MemWrite <= MemWrite;
        end
    end

    always@(posedge clk) begin
        if(rst)
            current_state   <=  IDLE;
        else
            current_state   <=  next_state;
    end

    always@(*) begin
        case(current_state)
            IDLE: begin
                if(((|MemWrite) || MemRead) && data_addr_ok)
                    next_state = WAIT;
                else if((|MemWrite) || MemRead)
                    next_state = HDSK;
                else
                    next_state = IDLE;
            end

            HDSK: begin
                if(data_addr_ok)
                    next_state = WAIT;
                else
                    next_state = HDSK;
            end

            WAIT: begin
                if(data_data_ok)
                    next_state = IDLE;
                else
                    next_state = WAIT;
            end

            // RECV: begin
            //     next_state = IDLE;
            // end

            default: next_state = IDLE;
        endcase
    end

    always@(*) begin
        data_req    = 0;
        CLR         = 0;
        stall       = 0;
        data_wr = 0;
        case (current_state)
            IDLE: begin
                if(MemRead || (|MemWrite)) begin
                    data_req = 1;
                    CLR = 1;
                    stall = 1;
                    if(MemRead) begin
                        data_size   =  2'b10;
                        data_addr[1:0]  =  2'b00;
                        data_addr[31:2] =  addr[31:2];
                        data_wr = 0;
                    end
                    case(MemWrite)
                        4'b0000:    ;

                        4'b0001: begin
                                data_size       =  2'b00;
                                data_addr[1:0]  =  2'b00;
                                data_addr[31:2] =  addr[31:2];
                                data_wdata      =  wdata;
                                data_wr         =  1;
                                end

                        4'b0010: begin
                                data_size       =  2'b00;
                                data_addr[1:0]  =  2'b01;
                                data_addr[31:2] =  addr[31:2];
                                data_wdata      =  wdata;
                                data_wr         =  1;
                        end

                        4'b0100: begin
                                data_size       =  2'b00;
                                data_addr[1:0]  =  2'b10;
                                data_addr[31:2] =  addr[31:2];
                                data_wdata      =  wdata;
                                data_wr         =  1;
                        end

                        4'b1000: begin
                                data_size       =  2'b00;
                                data_addr[1:0]  =  2'b11;
                                data_addr[31:2] =  addr[31:2];
                                data_wdata      =  wdata;
                                data_wr         =  1;
                        end

                        4'b0011: begin
                                data_size       =  2'b01;
                                data_addr[1:0]  =  2'b00;
                                data_addr[31:2] =  addr[31:2];
                                data_wdata      =  wdata;
                                data_wr         =  1;
                        end

                        4'b1100: begin
                                data_size       =  2'b01;
                                data_addr[1:0]  =  2'b10;
                                data_addr[31:2] =  addr[31:2];
                                data_wdata      =  wdata;
                                data_wr         =  1;
                        end

                        4'b1111: begin
                                data_size       =  2'b10;
                                data_addr[1:0]  =  2'b00;
                                data_addr[31:2] =  addr[31:2];
                                data_wdata      =  wdata;
                                data_wr         =  1;
                        end
                        default:    ;
                    endcase
                end
            end

            HDSK: begin
                data_req    = 1;
                CLR         = 1;
                stall       = 1;
                
                if(MemRead) begin
                    data_size   =  2'b10;
                    data_addr[1:0]  =  2'b00;
                    data_addr[31:2] =  reg_addr[31:2];
                    data_wr = 0;
                end
                case(reg_MemWrite)
                    4'b0000:    ;
                    4'b0001: begin
                            data_size       =  2'b00;
                            data_addr[1:0]  =  2'b00;
                            data_addr[31:2] =  reg_addr[31:2];
                            data_wdata      =  reg_wdata;
                            data_wr         =  1;
                            end
                     4'b0010: begin
                            data_size       =  2'b00;
                            data_addr[1:0]  =  2'b01;
                            data_addr[31:2] =  reg_addr[31:2];
                            data_wdata      =  reg_wdata;
                            data_wr         =  1;
                    end
                    4'b0100: begin
                            data_size       =  2'b00;
                            data_addr[1:0]  =  2'b10;
                            data_addr[31:2] =  reg_addr[31:2];
                            data_wdata      =  reg_wdata;
                            data_wr         =  1;
                    end
                    4'b1000: begin
                            data_size       =  2'b00;
                            data_addr[1:0]  =  2'b11;
                            data_addr[31:2] =  reg_addr[31:2];
                            data_wdata      =  reg_wdata;
                            data_wr         =  1;
                    end
                    4'b0011: begin
                            data_size       =  2'b01;
                            data_addr[1:0]  =  2'b00;
                            data_addr[31:2] =  reg_addr[31:2];
                            data_wdata      =  reg_wdata;
                            data_wr         =  1;
                    end
                    4'b1100: begin
                            data_size       =  2'b01;
                            data_addr[1:0]  =  2'b10;
                            data_addr[31:2] =  reg_addr[31:2];
                            data_wdata      =  reg_wdata;
                            data_wr         =  1;
                    end
                    4'b1111: begin
                            data_size       =  2'b10;
                            data_addr[1:0]  =  2'b00;
                            data_addr[31:2] =  reg_addr[31:2];
                            data_wdata      =  reg_wdata;
                            data_wr         =  1;
                    end
                    default:    ;
                endcase
            end

            WAIT: begin
                CLR         = 1;
                stall       = 1;
                if(data_data_ok) begin
                    CLR     = 0;
                    stall   = 0;
                end
            end

            // RECV: ;
            default: ;
        endcase

        data_addr[31:29] = 3'b000;
    end

endmodule