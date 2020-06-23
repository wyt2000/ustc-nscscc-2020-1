`timescale 1ns / 1ps

module Branch_judge(
    input [5:0] Op,
    input [4:0] rt,
    input [31:0] RsValue,
    input [31:0] RtValue,
    output reg RegWriteBD,
    output reg BranchD,
    output reg branch_taken
);

    always@(*) begin
        BranchD = 0;
        branch_taken = 0;
        RegWriteBD = 0;
        case(Op)
        6'b000100: begin
            //beq
            if(RsValue == RtValue)begin
                BranchD = 1;
                branch_taken = 1;
            end
        end
        6'b000101: begin
            //bne
            if(RsValue != RtValue)begin
                BranchD = 1;
                branch_taken = 1;
            end
        end
        6'b000001: begin
            case(rt)
            5'b00001: begin
                //bgez
                if(RsValue >= 0) begin
                    BranchD = 1;
                    branch_taken = 1;
                end             
            end
            5'b00000: begin
                //bltz
                if(RsValue < 0) begin
                    BranchD = 1;
                    branch_taken = 1;
                end
            end
            5'b10001: begin
                //bgezal
                if(RsValue >= 0) begin
                    BranchD = 1;
                    branch_taken = 1;
                    RegWriteBD = 1;
                end
            end
            5'b10000: begin
                //bltzal
                if(RsValue < 0) begin
                    BranchD = 1;
                    branch_taken = 1;
                    RegWriteBD = 1;
                end
            end
            default: ;
            endcase
        end
        6'b000111: begin
            if(rt == 5'b00000 && RsValue > 0) begin
                //bgtz
                BranchD = 1;
                branch_taken = 1;
            end
        end
        6'b000110: begin
            if(rt == 5'b00000 && RsValue <= 0) begin
                //blez
                BranchD = 1;
                branch_taken = 1;
            end
        end
        6'b000010: begin
            BranchD = 1;
        end
        6'b000011: begin
            BranchD = 1;
            RegWriteBD = 1;
        end
        6'b000000: begin
            //*********************************************
        end
        default: ;
        endcase
    end

endmodule