

module errordetect(
input clk,
input address_error,
input memread,
input overflow_error,
input syscall,
input break,
input reversed,
input [5:0] hardware_abortion,
input [1:0] software_abortion,
input [31:0] curpc,
output [31:0] BadVAddr,
input [31:0] Count,
input [31:0] Status,
input [31:0] Cause,
input [31:0] pc,
output [31:0] EPC,
output [31:0] NewPC,
output new_Status_EXL,
output new_Cause_BD1,
output exception_occur,
output [6:0] Cause_IP,
output [6:0] Status_IM,
output [4:0] ExcCode
    );
reg [31:0] Abortion_access;
initial Abortion_access=32'HBFC00380;
assign NewPC=Abortion_access;

wire Status_EXL;
assign Status_EXL = Status[1];
wire Cause_BD;
assign Cause_BD=Cause[31];
wire Status_IE;
assign Status_IE=Status[0];
assign ExcCode=Cause[6:2];
assign EPC=Cause_BD==1 ? pc-4:pc;

assign exception_occur=(!Status_EXL)
                       &((|hardware_abortion)|(|software_abortion)|address_error|overflow_error|syscall|break|reversed);
//assign new_Cause_BD=(Status_EXL == 0 && C) 分支延迟槽是哪个？

//中断例外需要再讨论一下

assign Cause_IP={hardware_abortion,software_abortion};

assign BadVAddr=pc+8;
reg [4:0] ExcCodereg;
always@(*)
begin
    if ((|hardware_abortion)|(|software_abortion)) ExcCodereg<=5'h00;
    else if (address_error && memread) ExcCodereg<=5'h04;
    else if (reversed) ExcCodereg<=5'h0a;
    else if (overflow_error) ExcCodereg<=5'h0c;
    else if (syscall) ExcCodereg<=5'h08;
    else if (break) ExcCodereg<=5'h09;
    else if (address_error && !memread) ExcCodereg<=5'h05;
end
assign ExcCode=ExcCodereg;
endmodule
