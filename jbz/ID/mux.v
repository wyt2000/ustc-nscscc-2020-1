`timescale 1ns / 1ps

module mux
    #(parameter WIDTH = 4)
    (input m,
    input [WIDTH - 1 : 0] in_0,
    input [WIDTH - 1 : 0] in_1,
    output [WIDTH - 1 : 0] out
    );
    
    assign out = m ? in_1 : in_0;
    
endmodule