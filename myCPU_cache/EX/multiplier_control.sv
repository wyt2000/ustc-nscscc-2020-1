`timescale 1ns / 1ps
`define mul_cycle 5

module multiplier_control(
    input clk,    
    input rst,
    input mul_begin,
    input mul_sign,
    input [31:0] mul_a,
    input [31:0] mul_b,
    output logic [63:0] mul_res,
    output logic mul_done
    );
    logic [63:0] unsigned_mul_res;
    logic [2:0] mul_counter; 

    assign mul_res = mul_done ? 
    (mul_sign ? ~ unsigned_mul_res + 1 : unsigned_mul_res) :
    32'b0;

    Multiplier multiplier (
        .CLK        (clk), 
        .SCLR       (rst),
        .A          (mul_a),
        .B          (mul_b),
        .P          (unsigned_mul_res)
    );

    always_ff @(posedge clk) begin : state_transition
        if(rst) begin
            mul_counter <= 0;
        end
        else begin
            if(mul_counter != 0) begin
                mul_counter <= mul_counter - 1;
            end
            else if(mul_begin && !mul_done) begin
                mul_counter <= `mul_cycle;                
            end
        end
    end

    always_ff @(posedge clk) begin : set_done
        if(rst) begin
            mul_done <= 0;
        end
        else begin
            if(mul_counter == 1) begin
                mul_done <= 1;
            end
            else begin
                mul_done <= 0;
            end
        end
    end

endmodule
