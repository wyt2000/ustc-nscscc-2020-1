`timescale 1ns / 1ps
`define div_cycle 34

module divider_control(
    input clk,    
    input rst,
    input div_begin,
    input div_sign,
    input div_dividend_sign,
    input [31:0] div_dividend,
    input [31:0] div_divisor,
    output logic [31:0] div_quotient,
    output logic [31:0] div_remainder,
    output logic div_done
    );
    logic [63:0] unsigned_div_res;
    logic [5:0] div_counter; 

    assign div_quotient = div_done ? 
    (div_sign ? ~ unsigned_div_res[63:32] + 1 : unsigned_div_res[63:32]) :
    32'b0;

    assign div_remainder = div_done ?
    (div_dividend_sign ? ~ unsigned_div_res[31:0] + 1 : unsigned_div_res[31:0]) :
    32'b0;

    Divider divider (
        .aclk                   (clk),
        .s_axis_divisor_tdata   (div_divisor),
        .s_axis_divisor_tvalid  (1),
        .s_axis_dividend_tdata  (div_dividend),
        .s_axis_dividend_tvalid (1),
        .m_axis_dout_tdata      (unsigned_div_res)
    );

    always_ff @(posedge clk) begin : state_transition
        if(rst) begin
            div_counter <= 0;
        end
        else begin
            if(div_counter != 0) begin
                div_counter <= div_counter - 1;
            end
            else if(div_begin) begin
                div_counter <= `div_cycle;                
            end
        end
    end

    always_ff @(posedge clk) begin : set_done
        if(rst) begin
            div_done <= 0;
        end
        else begin
            if(div_counter == 1) begin
                div_done <= 1;
            end
            else begin
                div_done <= 0;
            end
        end
    end

endmodule
