module WB_module
	#(parameter WIDTH=32)
	(
		input [WIDTH-1:0] aluout,
		input [WIDTH-1:0] Memdata,
		input [6:0] WritetoRFaddrin,
		input MemtoRegW,
		input RegWriteW,
		input Exception_Write_addr_sel,
		input Exception_Write_data_sel,
		input [6:0] Exception_RF_addr,
		input [WIDTH-1:0] Exceptiondata,
		input [63:0] HILO_data,
		input [31:0] PCin,
		output [63:0] WriteinRF_HI_LO_data,
		input HI_LO_writeenablein,
		output [6:0] WritetoRFaddrout,
		output HI_LO_writeenableout,
		output [WIDTH-1:0] WritetoRFdata,
		output RegWrite,
		output [31:0] PCout
	);
	assign HI_LO_writeenableout=HI_LO_writeenablein;
	wire [WIDTH-1:0] WriteRFtemp;
	assign WritetoRFtemp = MemtoRegW?aluout:Memdata; 
	assign WritetoRFdata = Exception_Write_data_sel?Exceptiondata:WritetoRFtemp;
	assign WritetoRFaddrout = Exception_Write_addr_sel?Exception_RF_addr:WritetoRFaddrin;
	assign WriteinRF_HI_LO_data = HILO_data;
	assign RegWrite = RegWriteW;
	assign PCout = PCin;
endmodule