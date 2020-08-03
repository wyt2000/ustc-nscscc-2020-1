module WB_module
	#(parameter WIDTH=32)
	(
		input [WIDTH-1:0] aluout,
        input [WIDTH-1:0] Memdata,
		input [6:0] WritetoRFaddrin,
        input [31:0] WritetoRFdatain,
		input MemtoRegW,
		input RegWriteW,
		input [63:0] HILO_data,
		input [31:0] PCin,
		input [2:0] MemReadTypeW,
        input [31:0] EPCD,
        input HI_LO_writeenablein,
        input [3:0] exception_in,
        input MemWriteW,
        input is_ds_in,
		output [63:0] WriteinRF_HI_LO_data,
		output [6:0] WritetoRFaddrout,
		output HI_LO_writeenableout,
		output [WIDTH-1:0] WritetoRFdata,
		output RegWrite,
		output [31:0] PCout,
        output [3:0] exception_out,
        output MemWrite,
        //is_ds
        output is_ds_out
	);

	reg [31:0] TrueMemData;
	assign HI_LO_writeenableout=HI_LO_writeenablein;
	assign WritetoRFdata = WritetoRFdatain;
	assign WritetoRFaddrout = WritetoRFaddrin;
	assign WriteinRF_HI_LO_data = HILO_data;
	assign RegWrite = (exception_in == 0 || (exception_in == 6 && EPCD[1:0] == 2'b00) )? RegWriteW : 0;
	assign PCout = PCin;
    assign exception_out = exception_in;
    assign MemWrite = MemWriteW;
    assign is_ds_out = is_ds_in;
    
endmodule