module WB
	#(parameter WIDTH=32)
	(
		input [WIDTH-1:0] aluout,
		input [WIDTH-1:0] Memdata,

		input MemtoRegW,
		output [WIDTH-1:0] WritetoRFdata
	);

	assign WritetoRFdata = MemtoRegW?aluout:Memdata; 
endmodule