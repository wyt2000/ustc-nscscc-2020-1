`timescale 1ns / 1ps
`include "aluop.vh"
module alu(
    input clk,
    input rst,
    input [31:0] a, b,
    input [5:0] op,
    input [31:0] hi_i,
    input [31:0] lo_i,						
    output logic [31:0] result,
    output logic [2:0]  exception,
    output logic [31:0] hi_o,
    output logic [31:0] lo_o,
    output logic stall			
    );

    logic [2:0] mul_counter;
    logic [63:0] mul_res, unsigned_mul_res;
    logic [31:0] mul_a, mul_b;
    logic mul_sign;
    logic mul_begin;

    logic [2:0] div_counter;
    logic [63:0] unsigned_div_res;
    logic [31:0] div_dividend, div_divisor, div_quotient, div_remainder;
    logic div_sign, div_dividend_sign;
    logic div_begin;

    Multiplier multiplier (
        .CLK        (clk), 
        .SCLR       (rst),
        .A          (mul_a),
        .B          (mul_b),
        .P          (unsigned_mul_res)
    );

    Divider divider (
        .aclk                   (clk),
        .s_axis_divisor_tdata   (div_divisor),
        .s_axis_divisor_tvalid  (1),
        .s_axis_dividend_tdata  (div_dividend),
        .s_axis_dividend_tvalid (1),
        .m_axis_dout_tdata      (unsigned_div_res)
    );

    assign stall = mul_begin | div_begin; 
    assign mul_res = mul_sign ? ~ unsigned_mul_res + 1 : unsigned_mul_res;
    assign div_quotient = div_sign ? ~ unsigned_div_res[63:32] + 1 : unsigned_div_res[63:32];
    assign div_remainder = div_dividend_sign ? ~ unsigned_div_res[31:0] + 1 : unsigned_div_res[31:0];

    always_ff @(posedge clk) begin : control_multiplier
        if(rst) begin
            mul_a <= 0;
            mul_b <= 0;
            mul_counter <= 0;
            mul_sign <= 0;
            mul_begin <= 0;
        end
        else begin
            if(mul_counter != 0) begin
                mul_counter <= mul_counter - 1;
            end
            else if(mul_begin == 1) begin
                hi_o <= mul_res[63:32];
                lo_o <= mul_res[31:0];
                mul_begin <= 0;
            end
        end
    end

    always_ff @(posedge clk) begin : control_divider
        if(rst) begin
            div_dividend <= 0;
            div_divisor <= 0;
            div_counter <= 0;
            div_sign <= 0;
            div_dividend_sign <= 0;
            div_begin <= 0;
        end
        else begin
            if(div_counter != 0) begin
                div_counter <= div_counter - 1;
            end
            else if(div_begin == 1) begin
                hi_o <= div_quotient;
                lo_o <= div_remainder;
                div_begin <= 0;
            end
        end
    end



    always_comb begin : calculate_result
        result = 0;
        mul_begin = 0;
        mul_sign = 0;
        mul_a = 0;
        mul_b = 0;
        mul_counter = 0;
        unique case (op)
            `ALU_ADD, `ALU_ADDI:
                result = a + b;
            `ALU_ADDIU:
                result = a + $signed(b[15:0]);
            `ALU_SUB, `ALU_SUBU:
                result = a - b;
            `ALU_SLT:
                result = $signed(a) < $signed(b) ? 1 : 0;
            `ALU_SLTI:
                result = $signed(a) < $signed(b[15:0]) ? 1 : 0;
            `ALU_SLTU:
                result = a < b ? 1 : 0;
            `ALU_SLTIU:
                result = a < $signed(b[15:0]) ? 1 : 0;

            `ALU_DIV: begin
                div_begin = 1;
                div_sign = a[31] ^ b[31];
                div_dividend_sign = a[31];
                div_dividend = a[31]? ~ a + 1 : a;
                div_divisor = b[31]? ~ b + 1 : b;
                div_counter = 34;
            end

            `ALU_DIVU: begin
                div_begin = 1;
                div_sign = 0;
                div_dividend_sign = 0;
                div_dividend = a;
                div_divisor = b;
                div_counter = 34;
            end

            `ALU_MULT: begin
                mul_begin = 1;
                mul_sign = a[31] ^ b[31];
                mul_a = a[31]? ~ a + 1 : a;
                mul_b = b[31]? ~ b + 1 : b;
                mul_counter = 5;
            end

            `ALU_MULTU: begin
                mul_begin = 1;
                mul_sign = 0;
                mul_a = a;
                mul_b = b;
                mul_counter = 5;
            end

            `ALU_AND, `ALU_ANDI:
                result = a & b;
            `ALU_LUI:
                result = {b[15:0], 16'b0};
            `ALU_NOR:
                result = ~ (a | b);
            `ALU_OR, `ALU_ORI:
                result = a | b;
            `ALU_XOR, `ALU_XORI:
                result = a ^ b;
            `ALU_SLLV, `ALU_SLL:
                result = b << a[4:0];
            `ALU_SRAV, `ALU_SRA:
                result = $signed(b) >>> a[4:0];
            `ALU_SRLV, `ALU_SRL:
                result = b >> a[4:0];
            `ALU_LB, `ALU_LBU, `ALU_SB,
            `ALU_LH, `ALU_LHU, `ALU_SH,
            `ALU_LW, `ALU_SW:
                result = a + $signed(b[15:0]);
            `ALU_MFHI:
                result = hi_i;
            `ALU_MFLO:
                result = lo_i;
            `ALU_MTHI:
                hi_o = a; 
            `ALU_MTLO:
                lo_o = a;
        endcase
    end
    
    always_comb begin : set_exception
        exception = 0;
        unique case (op)
            `ALU_ADD, `ALU_ADDI:
                if((a[31] ~^ b[31]) & (a[31] ^ result[31])) 
                    exception = `EXP_OVERFLOW;
            `ALU_SUB:
                if((a[31] ^ b[31]) & (a[31] ^ result[31]))
                    exception = `EXP_OVERFLOW; 
            `ALU_DIV, `ALU_DIVU:
                if(b == 32'b0)
                    exception = `EXP_DIVZERO;
            `ALU_BREAK:
                exception = `EXP_BREAK;
            `ALU_SYSCALL:
                exception = `EXP_SYSCALL;
            `ALU_LH, `ALU_LHU, `ALU_SH:
                if(result[0] != 1'b0)
                    exception = `EXP_ADDRERR;
            `ALU_LW, `ALU_SW:
                if(result[1:0] != 2'b00)
                    exception = `EXP_ADDRERR;
        endcase
    end

endmodule
