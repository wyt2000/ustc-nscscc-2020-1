`timescale 1ns / 1ps

module dcache(
    input               clk,
    input               rst,

    //connect with CPU
    output              miss,
    input       [31:0]  addr,
    input               rd_req,
    output reg  [31:0]  rd_data,
    input               wr_req,
    input       [31:0]  wr_data,
    input       [3 :0]  valid_lane

    // //connect with axi module
    // input               axi_gnt,
    // output reg  [31:0]  axi_addr,
    // output reg          axi_rd_req,
    // input       [31:0]  axi_rd_data[0:15],
    // output reg          axi_wr_req,
    // output reg  [31:0]  axi_wr_data[0:15]
);

    int             i;

    reg     [6 :0]  index_old;
    wire            ram_ready;

    wire    [19:0]  tag;
    wire    [6 :0]  index;
    wire    [4 :0]  offset;

    reg     [1 :0]  LRU_index[0:127];
    reg             valid,  dirty;
    reg             we_way[0:3];
    reg             we_bank[0:7];

    wire    [3 :0]  way_hit;
    wire    [1 :0]  way_num;

    reg     [2 :0]  current_state, next_state;
    
    reg     [6 :0]  reset_count;

    localparam      IDLE    =   1;
    localparam      SWPO    =   2;
    localparam      SWPI    =   3;
    localparam      WRIT    =   4;
    localparam      RSET    =   0;

    TAG_BLOCK_RAM       TAG_WAY0        (.addra(index),     .dina(tag),     .douta(tag_way[0]),     .wea(wea_way[0]),    .addrb(r_index),   .dinb(r_tag),   .web(web_way[0]),    .doutb(r_tag_way[0]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    TAG_BLOCK_RAM       TAG_WAY1        (.addra(index),     .dina(tag),     .douta(tag_way[1]),     .wea(wea_way[1]),    .addrb(r_index),   .dinb(r_tag),   .web(web_way[1]),    .doutb(r_tag_way[1]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    TAG_BLOCK_RAM       TAG_WAY2        (.addra(index),     .dina(tag),     .douta(tag_way[2]),     .wea(wea_way[2]),    .addrb(r_index),   .dinb(r_tag),   .web(web_way[2]),    .doutb(r_tag_way[2]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    TAG_BLOCK_RAM       TAG_WAY3        (.addra(index),     .dina(tag),     .douta(tag_way[3]),     .wea(wea_way[3]),    .addrb(r_index),   .dinb(r_tag),   .web(web_way[3]),    .doutb(r_tag_way[3]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));

    D_BLOCK_RAM         D_WAY0          (.addra(index),     .dina(1'b1),    .douta(d_way[0]),       .wea(wea_way[0]),    .addrb(r_index),   .dinb(r_d),     .web(web_way[0]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    D_BLOCK_RAM         D_WAY1          (.addra(index),     .dina(1'b1),    .douta(d_way[1]),       .wea(wea_way[1]),    .addrb(r_index),   .dinb(r_d),     .web(web_way[1]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    D_BLOCK_RAM         D_WAY2          (.addra(index),     .dina(1'b1),    .douta(d_way[2]),       .wea(wea_way[2]),    .addrb(r_index),   .dinb(r_d),     .web(web_way[2]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    D_BLOCK_RAM         D_WAY3          (.addra(index),     .dina(1'b1),    .douta(d_way[3]),       .wea(wea_way[3]),    .addrb(r_index),   .dinb(r_d),     .web(web_way[3]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));

    V_BLOCK_RAM         V_WAY0_BANK0    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[0][0]),  .wea(wea_way[0] & wea_bank[0]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[0] & web_bank[0]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY0_BANK1    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[0][1]),  .wea(wea_way[0] & wea_bank[1]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[0] & web_bank[1]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY0_BANK2    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[0][2]),  .wea(wea_way[0] & wea_bank[2]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[0] & web_bank[2]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY0_BANK3    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[0][3]),  .wea(wea_way[0] & wea_bank[3]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[0] & web_bank[3]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY0_BANK4    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[0][4]),  .wea(wea_way[0] & wea_bank[4]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[0] & web_bank[4]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY0_BANK5    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[0][5]),  .wea(wea_way[0] & wea_bank[5]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[0] & web_bank[5]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY0_BANK6    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[0][6]),  .wea(wea_way[0] & wea_bank[6]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[0] & web_bank[6]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY0_BANK7    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[0][7]),  .wea(wea_way[0] & wea_bank[7]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[0] & web_bank[7]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));

    V_BLOCK_RAM         V_WAY1_BANK0    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[1][0]),  .wea(wea_way[1] & wea_bank[0]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[1] & web_bank[0]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY1_BANK1    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[1][1]),  .wea(wea_way[1] & wea_bank[1]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[1] & web_bank[1]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY1_BANK2    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[1][2]),  .wea(wea_way[1] & wea_bank[2]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[1] & web_bank[2]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY1_BANK3    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[1][3]),  .wea(wea_way[1] & wea_bank[3]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[1] & web_bank[3]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY1_BANK4    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[1][4]),  .wea(wea_way[1] & wea_bank[4]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[1] & web_bank[4]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY1_BANK5    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[1][5]),  .wea(wea_way[1] & wea_bank[5]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[1] & web_bank[5]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY1_BANK6    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[1][6]),  .wea(wea_way[1] & wea_bank[6]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[1] & web_bank[6]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY1_BANK7    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[1][7]),  .wea(wea_way[1] & wea_bank[7]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[1] & web_bank[7]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));

    V_BLOCK_RAM         V_WAY2_BANK0    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[2][0]),  .wea(wea_way[2] & wea_bank[0]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[2] & web_bank[0]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY2_BANK1    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[2][1]),  .wea(wea_way[2] & wea_bank[1]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[2] & web_bank[1]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY2_BANK2    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[2][2]),  .wea(wea_way[2] & wea_bank[2]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[2] & web_bank[2]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY2_BANK3    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[2][3]),  .wea(wea_way[2] & wea_bank[3]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[2] & web_bank[3]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY2_BANK4    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[2][4]),  .wea(wea_way[2] & wea_bank[4]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[2] & web_bank[4]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY2_BANK5    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[2][5]),  .wea(wea_way[2] & wea_bank[5]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[2] & web_bank[5]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY2_BANK6    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[2][6]),  .wea(wea_way[2] & wea_bank[6]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[2] & web_bank[6]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY2_BANK7    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[2][7]),  .wea(wea_way[2] & wea_bank[7]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[2] & web_bank[7]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));

    V_BLOCK_RAM         V_WAY3_BANK0    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[3][0]),  .wea(wea_way[3] & wea_bank[0]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[3] & web_bank[0]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY3_BANK1    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[3][1]),  .wea(wea_way[3] & wea_bank[1]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[3] & web_bank[1]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY3_BANK2    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[3][2]),  .wea(wea_way[3] & wea_bank[2]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[3] & web_bank[2]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY3_BANK3    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[3][3]),  .wea(wea_way[3] & wea_bank[3]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[3] & web_bank[3]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY3_BANK4    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[3][4]),  .wea(wea_way[3] & wea_bank[4]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[3] & web_bank[4]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY3_BANK5    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[3][5]),  .wea(wea_way[3] & wea_bank[5]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[3] & web_bank[5]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY3_BANK6    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[3][6]),  .wea(wea_way[3] & wea_bank[6]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[3] & web_bank[6]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));
    V_BLOCK_RAM         V_WAY3_BANK7    (.addra(index),     .dina(1'b1),    .douta(v_way_bank[3][7]),  .wea(wea_way[3] & wea_bank[7]),   .addrb(r_index),    .dinb(r_v),    .web(web_way[3] & web_bank[7]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));

    BANK_BLOCK_RAM      BANK_WAY0_BANK0 (.addra(index),     .dina(wr_data), .douta(data_way_bank[0][0]),    .wea({{4{wea_way[0] & wea_bank[0]}} | valid_lane}), .addrb(r_index),    .dinb(data_rdata),  .web(4'b1111),  .doutb(r_data_way_bank[0][0]),   .ena(1),    .enb(1),    .clka(clk),     .clkb(clk));

    assign  miss    = (((!(|way_hit)) || (!ram_ready)) && (rd_req || wr_req)) || (current_state == RSET) || (rst);
    assign  {tag,   index,  offset} = addr;
    assign  way_num = (way_hit == 4'b1000 ? 2'b11 : way_hit >> 1);

//==========stage machine begin==========
    //stage change
    always@(posedge clk)
            current_state   <=  next_state;

    //next state logic
    always@(*) begin
        case(current_state)
        IDLE:   begin
            if(rst) begin
                next_state  =   RSET;
            end
            else begin
                if(| way_hit) begin
                    next_state  =   IDLE;
                end
                else if(~ ram_ready) begin
                    next_state  =   IDLE;
                end
                else if(~ (rd_req | wr_req) ) begin
                    next_state  =   IDLE;
                end
                else begin
                    if(tagvd_way[LRU_index[index]][0] == 0)
                        next_state  =   SWPI;
                    else
                        next_state  =   SWPO;
                end
            end
        end

        SWPO:   begin
            if(axi_gnt)
                    next_state  =   SWPI;
            else
                    next_state  =   SWPO;
        end

        SWPI:   begin
            if(axi_gnt)
                    next_state  =   WRIT;
            else
                    next_state  =   SWPI;
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
    //control signals
    always@(*) begin
        for(i = 0; i < 4; i++)begin
            we_way[i]       =   0;
        end
        for(i = 0; i < 16; i++) begin
            wr_data_bank[i]  =   32'b0;
            we_bank[i]      =   0;
            axi_wr_data[i]  =   32'b0;
        end
        valid               =   0;
        dirty               =   0;
        axi_wr_req          =   0;
        axi_rd_req          =   0;
        axi_addr            =   32'b0;
        case(current_state)
        IDLE:   begin
            if((|way_hit) && ram_ready && wr_req && !rst) begin
                we_way[way_num]         =   1;
                we_bank[offset[5:2]]    =   1;
                // wr_data_bank[offset[5:2]]=  {valid_lane[3] ? wr_data[31:24] : data_way_bank[way_num][offset[5:2]][31:24],
                //                              valid_lane[2] ? wr_data[23:16] : data_way_bank[way_num][offset[5:2]][23:16],
                //                              valid_lane[1] ? wr_data[15: 8] : data_way_bank[way_num][offset[5:2]][15: 8],
                //                              valid_lane[0] ? wr_data[ 7: 0] : data_way_bank[way_num][offset[5:2]][ 7: 0]};
                wr_data_bank[offset[5:2]]=  wr_data;
                valid                   =   1;
                dirty                   =   1;
            end
        end

        SWPO:   begin
            axi_wr_req      =   1;
            axi_wr_data     =   data_way_bank[LRU_index[index]];
            axi_addr        =   {tagvd_way[LRU_index[index]][20:2], index, 6'b00000};
        end

        SWPI:   begin
            axi_rd_req      =   1;
            axi_addr        =   {addr[31:6], 6'b00000};
        end

        WRIT: begin
            for(i = 0; i < 16; i++)
                we_bank[i]                  =   1;
            we_way[LRU_index[index]]        =   1;
            for(i = 0; i < 16; i++)
                wr_data_bank[i]             =   axi_rd_data[i];
            valid                           =   1;
            dirty                           =   0;
        end

        RSET: begin
            for(i = 0; i < 4; i++)
                we_way[i]       =   1;
            valid               =   0;
            dirty               =   0;
        end
        default:    ;
        endcase
    end
//==========stage machine end==========

    //fake LRU replace
    always@(posedge clk) begin
        if(rst) begin
            for(i = 0; i < 128; i++)
                LRU_index[i]    <=  0;
        end
        else if((|way_hit) && ram_ready && (rd_req || wr_req)) begin
            if(LRU_index[index] == way_num)
                LRU_index[index]    <=  LRU_index[index] + 1;
            else 
                LRU_index[index]    <=  LRU_index[index];
        end
    end

    //get ram ready
    always@(posedge clk) begin
        if(rst)
            index_old <= 0;
        else
            index_old   <=  index;
    end

    assign ram_ready    =   (index == index_old) ? 1 : 0;

    //reset count control
    always@(posedge clk) begin
        if(rst)
            reset_count <=  7'b0;
        else
            reset_count <=  reset_count + 1;
    end

endmodule