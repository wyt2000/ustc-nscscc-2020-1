`timescale 1ns / 1ps

module tlb_module (
    input               clk,
    input               rst,

    //tlb write,    *TLBWI
    input               we,
    input       [4 :0]  Index_in,
    input       [31:0]  EntryHi_in,
    input       [31:0]  PageMask_in,
    input       [31:0]  EntryLo0_in,
    input       [31:0]  EntryLo1_in,

    //tlb read, to CP0  *TLBR
    input       [4 :0]  rd_Index,
    output      [31:0]  rd_EntryHi,
    output      [31:0]  rd_PageMask,
    output      [31:0]  rd_EntryLo0,
    output      [31:0]  rd_EntryLo1,

    //tlb search        *TLBP
    // input       [31:0]  EntryHi_in,  //already declared
    output      [31:0]  result_Index,

    //instr addr trans
    input       [31:0]  instr_vaddr,
    output      [31:0]  instr_paddr,
    output              instr_avalid,
    output              instr_amiss,
    output      [2 :0]  instr_acache,

    //data addr trans
    input       [31:0]  data_vaddr,
    output      [31:0]  data_paddr,
    output              data_avalid,
    output              data_amiss,
    output              data_adirty,
    output      [2 :0]  data_acache
);

    genvar         i;
    int            j;

    reg [18:0]  VPN2        [31:0];
    reg [7 :0]  ASID        [31:0];
    reg [11:0]  PageMask    [31:0];
    reg         G           [31:0];
    reg [19:0]  PFN0        [31:0];
    reg [4 :0]  CDV0        [31:0];
    reg [19:0]  PFN1        [31:0];
    reg [4 :0]  CDV1        [31:0];

    wire [31:0] way_hit;
    reg  [4 :0] hit_num;

    wire [31:0] instr_hit;
    reg  [4 :0] instr_hit_num;

    wire [31:0] data_hit;
    reg  [4 :0] data_hit_num;

    //TLB control
    always@(posedge clk) begin
        if(rst) begin
            for(j = 0; j < 32; j++) begin
                VPN2    [j] <=  0;
                ASID    [j] <=  0;
                PageMask[j] <=  0;
                G       [j] <=  0;
                PFN0    [j] <=  0;
                CDV0    [j] <=  0;
                PFN1    [j] <=  0;
                CDV1    [j] <=  0;
            end
        end
        else if(we) begin
            VPN2    [Index_in]  <=  EntryHi_in[31:13];
            ASID    [Index_in]  <=  EntryHi_in[7 : 0];
            PageMask[Index_in]  <=  PageMask_in[24:13];
            G       [Index_in]  <=  EntryLo0_in[0] & EntryLo1_in[0];
            PFN0    [Index_in]  <=  EntryLo0_in[25: 6];
            CDV0    [Index_in]  <=  EntryLo0_in[5 : 1];
            PFN1    [Index_in]  <=  EntryLo1_in[25: 6];
            CDV1    [Index_in]  <=  EntryLo1_in[5 : 1];
        end
    end

    //TLB read
    assign  rd_EntryHi  =   {VPN2[rd_Index], 5'd0, ASID[rd_Index]};
    assign  rd_PageMask =   {7'd0, PageMask[rd_Index], 13'd0};
    assign  rd_EntryLo0 =   {6'd0, PFN0[rd_Index], CDV0[rd_Index], G[rd_Index]};
    assign  rd_EntryLo1 =   {6'd0, PFN1[rd_Index], CDV1[rd_Index], G[rd_Index]};

    //TLB search
    generate
        for(i = 0; i < 32; i++) begin
            // assign  way_hit[i] = (EntryHi_in[31:13] == VPN2[i] && EntryHi_in[7:0] == ASID[i]);
            assign  way_hit[i] = ((VPN2[i] & ~PageMask[i]) == (EntryHi_in[31:13] & ~PageMask[i]) && (G[i] || ASID[i] == EntryHi_in[7:0]));
        end
    endgenerate
    assign  result_Index = (|way_hit) ? {27'd0, hit_num} : 32'h8000_0000;
    always@(*) begin
        case(way_hit)
        32'b0000_0000_0000_0000_0000_0000_0000_0001:    hit_num = 5'd0;
        32'b0000_0000_0000_0000_0000_0000_0000_0010:    hit_num = 5'd1;
        32'b0000_0000_0000_0000_0000_0000_0000_0100:    hit_num = 5'd2;
        32'b0000_0000_0000_0000_0000_0000_0000_1000:    hit_num = 5'd3;
        32'b0000_0000_0000_0000_0000_0000_0001_0000:    hit_num = 5'd4;
        32'b0000_0000_0000_0000_0000_0000_0010_0000:    hit_num = 5'd5;
        32'b0000_0000_0000_0000_0000_0000_0100_0000:    hit_num = 5'd6;
        32'b0000_0000_0000_0000_0000_0000_1000_0000:    hit_num = 5'd7;
        32'b0000_0000_0000_0000_0000_0001_0000_0000:    hit_num = 5'd8;
        32'b0000_0000_0000_0000_0000_0010_0000_0000:    hit_num = 5'd9;
        32'b0000_0000_0000_0000_0000_0100_0000_0000:    hit_num = 5'd10;
        32'b0000_0000_0000_0000_0000_1000_0000_0000:    hit_num = 5'd11;
        32'b0000_0000_0000_0000_0001_0000_0000_0000:    hit_num = 5'd12;
        32'b0000_0000_0000_0000_0010_0000_0000_0000:    hit_num = 5'd13;
        32'b0000_0000_0000_0000_0100_0000_0000_0000:    hit_num = 5'd14;
        32'b0000_0000_0000_0000_1000_0000_0000_0000:    hit_num = 5'd15;
        32'b0000_0000_0000_0001_0000_0000_0000_0000:    hit_num = 5'd16;
        32'b0000_0000_0000_0010_0000_0000_0000_0000:    hit_num = 5'd17;
        32'b0000_0000_0000_0100_0000_0000_0000_0000:    hit_num = 5'd18;
        32'b0000_0000_0000_1000_0000_0000_0000_0000:    hit_num = 5'd19;
        32'b0000_0000_0001_0000_0000_0000_0000_0000:    hit_num = 5'd20;
        32'b0000_0000_0010_0000_0000_0000_0000_0000:    hit_num = 5'd21;
        32'b0000_0000_0100_0000_0000_0000_0000_0000:    hit_num = 5'd22;
        32'b0000_0000_1000_0000_0000_0000_0000_0000:    hit_num = 5'd23;
        32'b0000_0001_0000_0000_0000_0000_0000_0000:    hit_num = 5'd24;
        32'b0000_0010_0000_0000_0000_0000_0000_0000:    hit_num = 5'd25;
        32'b0000_0100_0000_0000_0000_0000_0000_0000:    hit_num = 5'd26;
        32'b0000_1000_0000_0000_0000_0000_0000_0000:    hit_num = 5'd27;
        32'b0001_0000_0000_0000_0000_0000_0000_0000:    hit_num = 5'd28;
        32'b0010_0000_0000_0000_0000_0000_0000_0000:    hit_num = 5'd29;
        32'b0100_0000_0000_0000_0000_0000_0000_0000:    hit_num = 5'd30;
        32'b1000_0000_0000_0000_0000_0000_0000_0000:    hit_num = 5'd31;
        default:                                        hit_num = 5'bzzzzz;
        endcase
    end
    
    //instr addr trans
    generate
        for(i = 0; i < 32; i++) begin
            assign  instr_hit[i] = ((VPN2[i] & ~PageMask[i]) == (instr_vaddr[31:13] & ~PageMask[i]) && (G[i] || ASID[i] == EntryHi_in[7:0]));
        end
    endgenerate
    assign  instr_paddr = instr_vaddr[12] ? {PFN1[instr_hit_num], instr_vaddr[11:0]} : {PFN0[instr_hit_num], instr_vaddr[11:0]};
    assign  instr_avalid= instr_vaddr[12] ? CDV1[instr_hit_num][1] : CDV0[instr_hit_num][1];
    assign  instr_amiss = (|instr_hit);
    assign  instr_acache= instr_vaddr[12] ? CDV1[instr_hit_num][5:3] : CDV0[instr_hit_num][5:3];
    always@(*) begin
        case(instr_hit)
        32'b0000_0000_0000_0000_0000_0000_0000_0001:    instr_hit_num = 5'd0;
        32'b0000_0000_0000_0000_0000_0000_0000_0010:    instr_hit_num = 5'd1;
        32'b0000_0000_0000_0000_0000_0000_0000_0100:    instr_hit_num = 5'd2;
        32'b0000_0000_0000_0000_0000_0000_0000_1000:    instr_hit_num = 5'd3;
        32'b0000_0000_0000_0000_0000_0000_0001_0000:    instr_hit_num = 5'd4;
        32'b0000_0000_0000_0000_0000_0000_0010_0000:    instr_hit_num = 5'd5;
        32'b0000_0000_0000_0000_0000_0000_0100_0000:    instr_hit_num = 5'd6;
        32'b0000_0000_0000_0000_0000_0000_1000_0000:    instr_hit_num = 5'd7;
        32'b0000_0000_0000_0000_0000_0001_0000_0000:    instr_hit_num = 5'd8;
        32'b0000_0000_0000_0000_0000_0010_0000_0000:    instr_hit_num = 5'd9;
        32'b0000_0000_0000_0000_0000_0100_0000_0000:    instr_hit_num = 5'd10;
        32'b0000_0000_0000_0000_0000_1000_0000_0000:    instr_hit_num = 5'd11;
        32'b0000_0000_0000_0000_0001_0000_0000_0000:    instr_hit_num = 5'd12;
        32'b0000_0000_0000_0000_0010_0000_0000_0000:    instr_hit_num = 5'd13;
        32'b0000_0000_0000_0000_0100_0000_0000_0000:    instr_hit_num = 5'd14;
        32'b0000_0000_0000_0000_1000_0000_0000_0000:    instr_hit_num = 5'd15;
        32'b0000_0000_0000_0001_0000_0000_0000_0000:    instr_hit_num = 5'd16;
        32'b0000_0000_0000_0010_0000_0000_0000_0000:    instr_hit_num = 5'd17;
        32'b0000_0000_0000_0100_0000_0000_0000_0000:    instr_hit_num = 5'd18;
        32'b0000_0000_0000_1000_0000_0000_0000_0000:    instr_hit_num = 5'd19;
        32'b0000_0000_0001_0000_0000_0000_0000_0000:    instr_hit_num = 5'd20;
        32'b0000_0000_0010_0000_0000_0000_0000_0000:    instr_hit_num = 5'd21;
        32'b0000_0000_0100_0000_0000_0000_0000_0000:    instr_hit_num = 5'd22;
        32'b0000_0000_1000_0000_0000_0000_0000_0000:    instr_hit_num = 5'd23;
        32'b0000_0001_0000_0000_0000_0000_0000_0000:    instr_hit_num = 5'd24;
        32'b0000_0010_0000_0000_0000_0000_0000_0000:    instr_hit_num = 5'd25;
        32'b0000_0100_0000_0000_0000_0000_0000_0000:    instr_hit_num = 5'd26;
        32'b0000_1000_0000_0000_0000_0000_0000_0000:    instr_hit_num = 5'd27;
        32'b0001_0000_0000_0000_0000_0000_0000_0000:    instr_hit_num = 5'd28;
        32'b0010_0000_0000_0000_0000_0000_0000_0000:    instr_hit_num = 5'd29;
        32'b0100_0000_0000_0000_0000_0000_0000_0000:    instr_hit_num = 5'd30;
        32'b1000_0000_0000_0000_0000_0000_0000_0000:    instr_hit_num = 5'd31;
        default:                                        instr_hit_num = 5'bzzzzz;
        endcase
    end

    //data addr trans
    generate
        for(i = 0; i < 32; i++) begin
            assign  data_hit[i] = ((VPN2[i] & ~PageMask[i]) == (data_vaddr[31:13] & ~PageMask[i]) && (G[i] || ASID[i] == EntryHi_in[7:0]));
        end
    endgenerate
    assign  data_paddr = data_vaddr[12] ? {PFN1[data_hit_num], data_vaddr[11:0]} : {PFN0[data_hit_num], data_vaddr[11:0]};
    assign  data_avalid= data_vaddr[12] ? CDV1[data_hit_num][1] : CDV0[data_hit_num][1];
    assign  data_amiss = (|data_hit);
    assign  data_adirty= data_vaddr[12] ? CDV1[data_hit_num][2] : CDV0[data_hit_num][2];
    assign  data_acache= data_vaddr[12] ? CDV1[data_hit_num][5:3] : CDV0[data_hit_num][5:3];
    always@(*) begin
        case(instr_hit)
        32'b0000_0000_0000_0000_0000_0000_0000_0001:    data_hit_num = 5'd0;
        32'b0000_0000_0000_0000_0000_0000_0000_0010:    data_hit_num = 5'd1;
        32'b0000_0000_0000_0000_0000_0000_0000_0100:    data_hit_num = 5'd2;
        32'b0000_0000_0000_0000_0000_0000_0000_1000:    data_hit_num = 5'd3;
        32'b0000_0000_0000_0000_0000_0000_0001_0000:    data_hit_num = 5'd4;
        32'b0000_0000_0000_0000_0000_0000_0010_0000:    data_hit_num = 5'd5;
        32'b0000_0000_0000_0000_0000_0000_0100_0000:    data_hit_num = 5'd6;
        32'b0000_0000_0000_0000_0000_0000_1000_0000:    data_hit_num = 5'd7;
        32'b0000_0000_0000_0000_0000_0001_0000_0000:    data_hit_num = 5'd8;
        32'b0000_0000_0000_0000_0000_0010_0000_0000:    data_hit_num = 5'd9;
        32'b0000_0000_0000_0000_0000_0100_0000_0000:    data_hit_num = 5'd10;
        32'b0000_0000_0000_0000_0000_1000_0000_0000:    data_hit_num = 5'd11;
        32'b0000_0000_0000_0000_0001_0000_0000_0000:    data_hit_num = 5'd12;
        32'b0000_0000_0000_0000_0010_0000_0000_0000:    data_hit_num = 5'd13;
        32'b0000_0000_0000_0000_0100_0000_0000_0000:    data_hit_num = 5'd14;
        32'b0000_0000_0000_0000_1000_0000_0000_0000:    data_hit_num = 5'd15;
        32'b0000_0000_0000_0001_0000_0000_0000_0000:    data_hit_num = 5'd16;
        32'b0000_0000_0000_0010_0000_0000_0000_0000:    data_hit_num = 5'd17;
        32'b0000_0000_0000_0100_0000_0000_0000_0000:    data_hit_num = 5'd18;
        32'b0000_0000_0000_1000_0000_0000_0000_0000:    data_hit_num = 5'd19;
        32'b0000_0000_0001_0000_0000_0000_0000_0000:    data_hit_num = 5'd20;
        32'b0000_0000_0010_0000_0000_0000_0000_0000:    data_hit_num = 5'd21;
        32'b0000_0000_0100_0000_0000_0000_0000_0000:    data_hit_num = 5'd22;
        32'b0000_0000_1000_0000_0000_0000_0000_0000:    data_hit_num = 5'd23;
        32'b0000_0001_0000_0000_0000_0000_0000_0000:    data_hit_num = 5'd24;
        32'b0000_0010_0000_0000_0000_0000_0000_0000:    data_hit_num = 5'd25;
        32'b0000_0100_0000_0000_0000_0000_0000_0000:    data_hit_num = 5'd26;
        32'b0000_1000_0000_0000_0000_0000_0000_0000:    data_hit_num = 5'd27;
        32'b0001_0000_0000_0000_0000_0000_0000_0000:    data_hit_num = 5'd28;
        32'b0010_0000_0000_0000_0000_0000_0000_0000:    data_hit_num = 5'd29;
        32'b0100_0000_0000_0000_0000_0000_0000_0000:    data_hit_num = 5'd30;
        32'b1000_0000_0000_0000_0000_0000_0000_0000:    data_hit_num = 5'd31;
        default:                                        data_hit_num = 5'bzzzzz;
        endcase
    end

endmodule