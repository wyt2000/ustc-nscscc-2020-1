module TLB(
	input clk,
	input rst,
	
	
	input [31:0] logic_addr,
	input [1:0] reftype,
	output [31:0] phy_addr,
	//TLB exceptions
	output Refill,
	output Invalid,
	output Modified,
	//TLB write
	input we,
	input [31:0] EntryHi,
	input [31:0] PageaMask,
	input [31:0] EntryLo0,
	input [31:0] EntryLo1
);
localparam fetch = 2'b00;
localparam load  = 2'b01;
localparam store = 2'b10;

//TLB registers
reg [18:0] VPN2 	[0:31];
reg [7:0]  ASID 	[0:31];
reg [11:0] Pagemask [0:31];
reg        G        [0:31];
reg [19:0] PFN0     [0:31];
reg [4:0]  CDV0     [0:31];
reg [19:0] PFN1     [0:31];
reg [4:0]  CDV1     [0:31];

//wires from logic_addr
wire [18:0] vahigh;
wire va12;
wire [11:0] valow;
wire [7:0] addr_ASID;
assign vahigh=logic_addr[31:13];
assign addr_ASID=logic_addr[7:0];
assign va12=logic_addr[12];
assign valow=logic_addr[11:0];
//regs for comparing TLB
reg found [0:31];
reg PFN [0:19];
reg [2:0] c;
reg d,v;
assign Refill=(!(|found));
assign Invalid=!v;
assign Modified=(d==0 & reftype==store);
always@(*) begin
	for (integer i=0;i<31;i++) begin
		if ((VPN2[i] & Pagemask[i])==(vahigh & Pagemask[i]) & (G[i] | (ASID[i]==addr_ASID))) begin
			found[i]<=1;
			if (va12) begin
				PFN<=TLB[i].PFN1;
				{c,d,v}<=CDV1;
			end
			else begin
				PFN<=TLB[i].PFN0;
				{c,d,v}<=CDV0;
			end
		end
		else begin
			found[i]<=0;
		end
	end
end

assign phy_addr={PFN,valow};

reg [7:0] LRU [0:31];
reg [4:0] writereg;
reg [4:0] count;
reg [4:0] nextwritereg;
getnextreg(LRU,nextwritereg);

always@(posedge clk) begin
	if (rst) begin
		for (integer i=0;i<31;i++) LRU[i]<=0;
	end
	else begin
		if ((|found) && we) begin
			for (integer i=0;i<31;i++) begin
				if (found[i]) LRU[i]<=0;
				else LRU[i]<=LRU[i]+1;
			end
		end
	end
end
always@(posedge clk) begin
	nextwritereg <= LRU[count] > LRU[nextwritereg]? count:nextwritereg;
	count <= count+1;
end
always@(posedge clk) begin
	if (we) begin
		VPN2 	 [writereg] <= EntryHi[31:13];
		ASID 	 [writereg] <= EntryHi[7:0];
		Pagemask [writereg] <= PageMask[24:13];
		G     	 [writereg] <= EntryLo0[0];
		PFN0     [writereg] <= EntryLo0[25:6];
		CDV0     [writereg] <= EntryLo0[5:1];
		PFN1     [writereg] <= EntryLo1[25:6];
		CDV1     [writereg] <= EntryLo1[5:1];
		writereg<=nextwritereg;
	end
end
endmodule


