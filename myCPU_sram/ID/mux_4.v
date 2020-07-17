`timescale 1ns / 1ps

module mux_4
    #(parameter WIDTH = 32)
    (input [1:0] m,
    input [WIDTH - 1:0] in_0,
    input [WIDTH - 1:0] in_1,
    input [WIDTH - 1:0] in_2,
    input [WIDTH - 1:0] in_3,
    output reg [WIDTH - 1:0] out
    );
    
    always@(*) begin
        case(m)
            2'b00:  out = in_0;
            2'b01:  out = in_1;
            2'b10:  out = in_2;
            2'b11:  out = in_3;
            default:    ;
        endcase
    end
    
endmodule
