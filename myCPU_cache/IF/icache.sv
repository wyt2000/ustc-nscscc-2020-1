`timescale 1ns / 1ps

module icache (
    input               clk,
    input               rst,

    //connect with CPU
    output              miss,
    input       [31:0]  addr,
    output reg  [31:0]  rd_data,
    input               rd_req,

    //=========instr axi bus=========
    //ar
    output      [3 :0]  instr_arid      ,
    output      [31:0]  instr_araddr    ,
    output      [3 :0]  instr_arlen     ,
    output      [2 :0]  instr_arsize    ,
    output      [1 :0]  instr_arburst   ,
    output      [1 :0]  instr_arlock    ,
    output      [3 :0]  instr_arcache   ,
    output      [2 :0]  instr_arprot    ,
    output reg          instr_arvalid   ,
    input               instr_arready   ,
    //r
    input       [3 :0]  instr_rid       ,
    input       [31:0]  instr_rdata     ,
    input       [1 :0]  instr_rresp     ,
    input               instr_rlast     ,
    input               instr_rvalid    ,
    output reg          instr_rready    ,
    //aw
    output      [3 :0]  instr_awid      ,
    output      [31:0]  instr_awaddr    ,
    output      [3 :0]  instr_awlen     ,
    output      [2 :0]  instr_awsize    ,
    output      [1 :0]  instr_awburst   ,
    output      [1 :0]  instr_awlock    ,
    output      [3 :0]  instr_awcache   ,
    output      [2 :0]  instr_awprot    ,
    output              instr_awvalid   ,
    input               instr_awready   ,
    //w
    output      [3 :0]  instr_wid       ,
    output      [31:0]  instr_wdata     ,
    output      [3 :0]  instr_wstrb     ,
    output              instr_wlast     ,
    output              instr_wvalid    ,
    input               instr_wready    ,
    //b
    input       [3 :0]  instr_bid       ,
    input       [1 :0]  instr_bresp     ,
    input               instr_bvalid    ,
    output              instr_bready    

    // //connect with axi module
    // input               icache_gnt,
    // input       [31:0]  icache_data[0:15],
    // output      [31:0]  icache_addr,
    // output reg          icache_rd_req,

    // //connect with pre-fetch
    // output      [19:0]  tag,
    // output reg          we_way[0:3],
    // output      [6 :0]  tagv_index,
    // output reg          valid
);
    int                     i;

    wire        [19: 0]     tag;
    wire        [6 : 0]     index;
    wire        [4 : 0]     offset;

    reg         [31: 0]     r_instr_araddr;
    wire        [6 : 0]     r_index;
    wire        [19: 0]     r_tag;
    reg         [1 : 0]     LRU_num;

    reg         [1 : 0]     LRU[0:127];

    wire        [3 : 0]     way_hit;

    reg                     r_valid;
    wire                    valid_way_bank[3:0][7:0];
    wire        [6 : 0]     v_index;

    wire        [19: 0]     tag_way[3:0];

    reg                     we_way[3:0];
    reg                     we_bank[7:0];

    wire        [31: 0]     data_way_bank[3:0][7:0];

    reg         [1 : 0]     current_state, next_state;

    reg         [2 : 0]     wrap_count;

    reg         [6 : 0]     reset_count;

    localparam      IDLE    =   1;
    localparam      REQ     =   2;
    localparam      WRIT    =   3;
    localparam      RSET    =   0;

    TAG_DISTRIBUTED_RAM     TAG_WAY0        (.a(r_index),  .d(r_tag),    .dpra(index),    .dpo(tag_way[0]),   .we(we_way[0]),     .clk(clk));
    TAG_DISTRIBUTED_RAM     TAG_WAY1        (.a(r_index),  .d(r_tag),    .dpra(index),    .dpo(tag_way[1]),   .we(we_way[1]),     .clk(clk));
    TAG_DISTRIBUTED_RAM     TAG_WAY2        (.a(r_index),  .d(r_tag),    .dpra(index),    .dpo(tag_way[2]),   .we(we_way[2]),     .clk(clk));
    TAG_DISTRIBUTED_RAM     TAG_WAY3        (.a(r_index),  .d(r_tag),    .dpra(index),    .dpo(tag_way[3]),   .we(we_way[3]),     .clk(clk));

    V_DISTRIBUTED_RAM       V_WAY0_BANK0    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[0][0]),     .we(we_way[0] & we_bank[0]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY0_BANK1    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[0][1]),     .we(we_way[0] & we_bank[1]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY0_BANK2    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[0][2]),     .we(we_way[0] & we_bank[2]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY0_BANK3    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[0][3]),     .we(we_way[0] & we_bank[3]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY0_BANK4    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[0][4]),     .we(we_way[0] & we_bank[4]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY0_BANK5    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[0][5]),     .we(we_way[0] & we_bank[5]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY0_BANK6    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[0][6]),     .we(we_way[0] & we_bank[6]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY0_BANK7    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[0][7]),     .we(we_way[0] & we_bank[7]),    .clk(clk));

    V_DISTRIBUTED_RAM       V_WAY1_BANK0    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[1][0]),     .we(we_way[1] & we_bank[0]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY1_BANK1    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[1][1]),     .we(we_way[1] & we_bank[1]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY1_BANK2    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[1][2]),     .we(we_way[1] & we_bank[2]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY1_BANK3    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[1][3]),     .we(we_way[1] & we_bank[3]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY1_BANK4    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[1][4]),     .we(we_way[1] & we_bank[4]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY1_BANK5    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[1][5]),     .we(we_way[1] & we_bank[5]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY1_BANK6    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[1][6]),     .we(we_way[1] & we_bank[6]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY1_BANK7    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[1][7]),     .we(we_way[1] & we_bank[7]),    .clk(clk));

    V_DISTRIBUTED_RAM       V_WAY2_BANK0    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[2][0]),     .we(we_way[2] & we_bank[0]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY2_BANK1    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[2][1]),     .we(we_way[2] & we_bank[1]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY2_BANK2    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[2][2]),     .we(we_way[2] & we_bank[2]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY2_BANK3    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[2][3]),     .we(we_way[2] & we_bank[3]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY2_BANK4    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[2][4]),     .we(we_way[2] & we_bank[4]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY2_BANK5    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[2][5]),     .we(we_way[2] & we_bank[5]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY2_BANK6    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[2][6]),     .we(we_way[2] & we_bank[6]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY2_BANK7    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[2][7]),     .we(we_way[2] & we_bank[7]),    .clk(clk));

    V_DISTRIBUTED_RAM       V_WAY3_BANK0    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[3][0]),     .we(we_way[3] & we_bank[0]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY3_BANK1    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[3][1]),     .we(we_way[3] & we_bank[1]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY3_BANK2    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[3][2]),     .we(we_way[3] & we_bank[2]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY3_BANK3    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[3][3]),     .we(we_way[3] & we_bank[3]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY3_BANK4    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[3][4]),     .we(we_way[3] & we_bank[4]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY3_BANK5    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[3][5]),     .we(we_way[3] & we_bank[5]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY3_BANK6    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[3][6]),     .we(we_way[3] & we_bank[6]),    .clk(clk));
    V_DISTRIBUTED_RAM       V_WAY3_BANK7    (.a(r_index),  .d(r_valid),     .dpra(index),    .dpo(valid_way_bank[3][7]),     .we(we_way[3] & we_bank[7]),    .clk(clk));

    BANK_DISTRIBUTED_RAM    BANK_WAY0_BANK0 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[0][0]),    .we(we_way[0] & we_bank[0]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY0_BANK1 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[0][1]),    .we(we_way[0] & we_bank[1]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY0_BANK2 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[0][2]),    .we(we_way[0] & we_bank[2]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY0_BANK3 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[0][3]),    .we(we_way[0] & we_bank[3]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY0_BANK4 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[0][4]),    .we(we_way[0] & we_bank[4]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY0_BANK5 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[0][5]),    .we(we_way[0] & we_bank[5]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY0_BANK6 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[0][6]),    .we(we_way[0] & we_bank[6]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY0_BANK7 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[0][7]),    .we(we_way[0] & we_bank[7]),  .clk(clk));

    BANK_DISTRIBUTED_RAM    BANK_WAY1_BANK0 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[1][0]),    .we(we_way[1] & we_bank[0]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY1_BANK1 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[1][1]),    .we(we_way[1] & we_bank[1]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY1_BANK2 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[1][2]),    .we(we_way[1] & we_bank[2]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY1_BANK3 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[1][3]),    .we(we_way[1] & we_bank[3]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY1_BANK4 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[1][4]),    .we(we_way[1] & we_bank[4]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY1_BANK5 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[1][5]),    .we(we_way[1] & we_bank[5]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY1_BANK6 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[1][6]),    .we(we_way[1] & we_bank[6]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY1_BANK7 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[1][7]),    .we(we_way[1] & we_bank[7]),  .clk(clk));

    BANK_DISTRIBUTED_RAM    BANK_WAY2_BANK0 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[2][0]),    .we(we_way[2] & we_bank[0]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY2_BANK1 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[2][1]),    .we(we_way[2] & we_bank[1]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY2_BANK2 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[2][2]),    .we(we_way[2] & we_bank[2]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY2_BANK3 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[2][3]),    .we(we_way[2] & we_bank[3]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY2_BANK4 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[2][4]),    .we(we_way[2] & we_bank[4]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY2_BANK5 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[2][5]),    .we(we_way[2] & we_bank[5]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY2_BANK6 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[2][6]),    .we(we_way[2] & we_bank[6]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY2_BANK7 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[2][7]),    .we(we_way[2] & we_bank[7]),  .clk(clk));

    BANK_DISTRIBUTED_RAM    BANK_WAY3_BANK0 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[3][0]),    .we(we_way[3] & we_bank[0]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY3_BANK1 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[3][1]),    .we(we_way[3] & we_bank[1]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY3_BANK2 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[3][2]),    .we(we_way[3] & we_bank[2]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY3_BANK3 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[3][3]),    .we(we_way[3] & we_bank[3]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY3_BANK4 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[3][4]),    .we(we_way[3] & we_bank[4]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY3_BANK5 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[3][5]),    .we(we_way[3] & we_bank[5]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY3_BANK6 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[3][6]),    .we(we_way[3] & we_bank[6]),  .clk(clk));
    BANK_DISTRIBUTED_RAM    BANK_WAY3_BANK7 (.a(r_index),    .d(instr_rdata),       .dpra(index),    .dpo(data_way_bank[3][7]),    .we(we_way[3] & we_bank[7]),  .clk(clk));

    assign  miss    =   ((!(|way_hit)) && rd_req) || (current_state == RSET) || rst;
    assign  {tag,   index,  offset} = addr;
    assign  way_hit = {(tag == tag_way[3] && valid_way_bank[3][offset[4:2]]),
                       (tag == tag_way[2] && valid_way_bank[2][offset[4:2]]),
                       (tag == tag_way[1] && valid_way_bank[1][offset[4:2]]),
                       (tag == tag_way[0] && valid_way_bank[0][offset[4:2]])};
    assign  v_index =   current_state == RSET ? reset_count : index;

    always@(*) begin
        case(way_hit)
        4'b0001:    rd_data =   data_way_bank[0][offset[4:2]];
        4'b0010:    rd_data =   data_way_bank[1][offset[4:2]];
        4'b0100:    rd_data =   data_way_bank[2][offset[4:2]];
        4'b1000:    rd_data =   data_way_bank[3][offset[4:2]];
        default:    rd_data =   0;
        endcase
    end

//==========stage machine begin==========
    assign  instr_araddr = {r_instr_araddr[31:2], 2'b00};
    assign  r_index      = r_instr_araddr[11:5];
    assign  r_tag        = r_instr_araddr[31:12];
    //stage change
    always@(posedge clk) begin
        current_state   <=  next_state;
    end

    //next state logic
    always@(*) begin
        case(current_state)
        IDLE:   begin
            if(rst)
                next_state      =   RSET;
            else begin
                if(| way_hit) begin
                    next_state  =   IDLE;
                end
                else if(~ rd_req) begin
                    next_state  =   IDLE;
                end
                else begin
                    next_state  =   REQ;
                end
            end
        end

        REQ:    begin
            if(rst)
                next_state  =   RSET;
            else if(instr_arvalid && instr_arready)
                next_state  =   WRIT;
            else
                next_state  =   REQ;
        end

        WRIT:   begin
            if(instr_rvalid && instr_rready && instr_rlast)
                next_state  =   IDLE;
            else
                next_state  =   WRIT;
        end

        RSET:   begin
            if(rst || reset_count < 7'b1111111)
                next_state      =   RSET;
            else
                next_state      =   IDLE;
        end
        default:    next_state  =   IDLE;
        endcase
    end

    //data control
    always@(*) begin
        r_valid           =   0;
        for(i = 0; i < 4; i++)
            we_way[i]   =   0;
        for(i = 0; i < 8; i++)
            we_bank[i]  =   0;
        
        instr_arvalid   =   0;
        instr_rready    =   0;

        case(current_state)
        REQ:    begin
            instr_arvalid       =   1;
            for(i = 0; i < 8; i++)
                we_bank[i]      =   1;
            we_way[LRU_num]  =   1;
        end

        WRIT:   begin
            instr_rready            =   1;
            r_valid                 =   1;
            if(instr_rready && instr_rvalid)
                we_bank[wrap_count] =   1;
            we_way[LRU_num]         =   1;
        end

        RSET:   begin
            for(i = 0; i < 4; i++)
                we_way[i]       =   1;
            for(i = 0; i < 8; i++)
                we_bank[i]      =   1;
        end
        default:    ;
        endcase
    end
//==========stage machine   end==========
    //save req info
    always@(posedge clk) begin
        if(current_state == IDLE && !(|way_hit) && rd_req) begin
            r_instr_araddr      <=  {addr[31:2], 2'b00};
            LRU_num             <=  LRU[index];
        end
    end

    //wrap count
    always@(posedge clk) begin
        case(current_state)
        IDLE:   begin
            if(!(|way_hit) && rd_req)
                    wrap_count  <=  addr[4:2];  
        end

        REQ:        wrap_count  <=  wrap_count;

        WRIT:   begin
            if(instr_rready && instr_rvalid)
                    wrap_count  <=  wrap_count + 1;
            else
                    wrap_count  <=  wrap_count;
        end
        default:    wrap_count  <=  0;
        endcase
    end

    //fake LRU replace
    always@(posedge clk) begin
        if(current_state == RSET || rst) begin
            LRU[reset_count]    <=  0;
        end
        else if(|way_hit) begin
            if(LRU[index] == (way_hit == 4'b1000 ? 2'b11 : way_hit >> 1))
                LRU[index]    <=  LRU[index] + 1;
            else 
                LRU[index]    <=  LRU[index];
        end
    end

    //reset count control
    always@(posedge clk) begin
        if(rst)
            reset_count <=  7'b0;
        else
            reset_count <=  reset_count + 1;
    end

    //constants
    assign instr_arid     =   0;
    assign instr_arlen    =   7;
    assign instr_arsize   =   2;
    assign instr_arburst  =   2'b10;
    assign instr_arlock   =   0;
    assign instr_arcache  =   0;
    assign instr_arprot   =   0;

    assign instr_awid     =   0;
    assign instr_awaddr   =   0;
    assign instr_awlen    =   0;
    assign instr_awsize   =   0;
    assign instr_awburst  =   0;
    assign instr_awlock   =   0;
    assign instr_awcache  =   0;
    assign instr_awprot   =   0;
    assign instr_awvalid  =   0;

    assign instr_wid      =   0;
    assign instr_wdata    =   0;
    assign instr_wstrb    =   0;
    assign instr_wlast    =   0;
    assign instr_wvalid   =   0;
    assign instr_bready   =   1;

endmodule
