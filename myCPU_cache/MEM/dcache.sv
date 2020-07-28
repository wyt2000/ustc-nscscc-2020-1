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
    input       [3 :0]  valid_lane,

    //connect with axi module
    input               axi_gnt,
    output reg  [31:0]  axi_addr,
    output reg          axi_rd_req,
    input       [31:0]  axi_rd_data[0:7],
    output reg          axi_wr_req,
    output reg  [31:0]  axi_wr_data[0:7]
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
    wire    [21:0]  tagvd_way[0:3];
    wire    [31:0]  data_way_bank[0:3][0:7];
    reg     [31:0]  wr_data_bank[0:7];

    wire    [3 :0]  way_hit;
    wire    [1 :0]  way_num;

    reg     [2 :0]  current_state, next_state;
    
    reg     [6 :0]  reset_count;
    wire    [6 :0]  tagv_index;

    localparam      IDLE    =   0;
    localparam      SWPO    =   1;
    localparam      SWPI    =   2;
    localparam      WRIT    =   3;
    localparam      RSET    =   4;

    TAGVD_RAM TAGVD_WAY_0 (.clka(clk),    .addra(tagv_index),  .douta(tagvd_way[0]),    .wea(we_way[0]),     .dina({tag, valid, dirty}),    .ena(1));
    TAGVD_RAM TAGVD_WAY_1 (.clka(clk),    .addra(tagv_index),  .douta(tagvd_way[1]),    .wea(we_way[1]),     .dina({tag, valid, dirty}),    .ena(1));
    TAGVD_RAM TAGVD_WAY_2 (.clka(clk),    .addra(tagv_index),  .douta(tagvd_way[2]),    .wea(we_way[2]),     .dina({tag, valid, dirty}),    .ena(1));
    TAGVD_RAM TAGVD_WAY_3 (.clka(clk),    .addra(tagv_index),  .douta(tagvd_way[3]),    .wea(we_way[3]),     .dina({tag, valid, dirty}),    .ena(1));

    DATA_RAM DATA_WAY0_BANK0 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][0]),    .wea(we_way[0] & we_bank[0]),     .dina(wr_data_bank[0]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK1 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][1]),    .wea(we_way[0] & we_bank[1]),     .dina(wr_data_bank[1]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK2 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][2]),    .wea(we_way[0] & we_bank[2]),     .dina(wr_data_bank[2]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK3 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][3]),    .wea(we_way[0] & we_bank[3]),     .dina(wr_data_bank[3]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK4 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][4]),    .wea(we_way[0] & we_bank[4]),     .dina(wr_data_bank[4]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK5 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][5]),    .wea(we_way[0] & we_bank[5]),     .dina(wr_data_bank[5]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK6 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][6]),    .wea(we_way[0] & we_bank[6]),     .dina(wr_data_bank[6]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK7 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][7]),    .wea(we_way[0] & we_bank[7]),     .dina(wr_data_bank[7]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK0 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][0]),    .wea(we_way[1] & we_bank[0]),     .dina(wr_data_bank[0]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK1 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][1]),    .wea(we_way[1] & we_bank[1]),     .dina(wr_data_bank[1]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK2 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][2]),    .wea(we_way[1] & we_bank[2]),     .dina(wr_data_bank[2]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK3 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][3]),    .wea(we_way[1] & we_bank[3]),     .dina(wr_data_bank[3]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK4 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][4]),    .wea(we_way[1] & we_bank[4]),     .dina(wr_data_bank[4]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK5 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][5]),    .wea(we_way[1] & we_bank[5]),     .dina(wr_data_bank[5]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK6 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][6]),    .wea(we_way[1] & we_bank[6]),     .dina(wr_data_bank[6]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK7 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][7]),    .wea(we_way[1] & we_bank[7]),     .dina(wr_data_bank[7]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK0 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][0]),    .wea(we_way[2] & we_bank[0]),     .dina(wr_data_bank[0]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK1 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][1]),    .wea(we_way[2] & we_bank[1]),     .dina(wr_data_bank[1]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK2 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][2]),    .wea(we_way[2] & we_bank[2]),     .dina(wr_data_bank[2]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK3 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][3]),    .wea(we_way[2] & we_bank[3]),     .dina(wr_data_bank[3]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK4 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][4]),    .wea(we_way[2] & we_bank[4]),     .dina(wr_data_bank[4]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK5 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][5]),    .wea(we_way[2] & we_bank[5]),     .dina(wr_data_bank[5]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK6 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][6]),    .wea(we_way[2] & we_bank[6]),     .dina(wr_data_bank[6]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK7 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][7]),    .wea(we_way[2] & we_bank[7]),     .dina(wr_data_bank[7]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK0 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][0]),    .wea(we_way[3] & we_bank[0]),     .dina(wr_data_bank[0]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK1 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][1]),    .wea(we_way[3] & we_bank[1]),     .dina(wr_data_bank[1]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK2 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][2]),    .wea(we_way[3] & we_bank[2]),     .dina(wr_data_bank[2]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK3 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][3]),    .wea(we_way[3] & we_bank[3]),     .dina(wr_data_bank[3]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK4 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][4]),    .wea(we_way[3] & we_bank[4]),     .dina(wr_data_bank[4]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK5 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][5]),    .wea(we_way[3] & we_bank[5]),     .dina(wr_data_bank[5]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK6 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][6]),    .wea(we_way[3] & we_bank[6]),     .dina(wr_data_bank[6]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK7 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][7]),    .wea(we_way[3] & we_bank[7]),     .dina(wr_data_bank[7]),    .ena(1));

    assign  miss    = ((!(|way_hit)) || (!ram_ready)) && (rd_req || wr_req);
    assign  {tag,   index,  offset} = addr;
    assign  way_hit = {((tag == tagvd_way[3][21:2]) && tagvd_way[3][1]), 
                       ((tag == tagvd_way[2][21:2]) && tagvd_way[2][1]), 
                       ((tag == tagvd_way[1][21:2]) && tagvd_way[1][1]), 
                       ((tag == tagvd_way[0][21:2]) && tagvd_way[0][1])};
    assign  way_num = (way_hit == 4'b1000 ? 2'b11 : way_hit >> 1);
    assign tagv_index   =   current_state == RSET ? reset_count : index;

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
    //stage change
    always@(posedge clk) begin
        if(rst)
            current_state   <=  RSET;
        else
            current_state   <=  next_state;
    end
    //next state logic
    always@(*) begin
        case(current_state)
        IDLE:   begin
            if((!(|way_hit)) && ram_ready && (rd_req || wr_req)) begin
                if(tagvd_way[LRU_index[index]][0] == 0)
                    next_state  =   SWPI;
                else
                    next_state  =   SWPO;
            end
            else if(rst)
                    next_state  =   RSET;
            else
                    next_state  =   IDLE;
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
        for(i = 0; i < 8; i++) begin
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
            if((|way_hit) && ram_ready && wr_req) begin
                we_way[way_num]         =   1;
                we_bank[offset[4:2]]    =   1;
                wr_data_bank[offset[4:2]]=  {valid_lane[3] ? wr_data[31:24] : data_way_bank[way_num][offset[4:2]][31:24],
                                             valid_lane[2] ? wr_data[23:16] : data_way_bank[way_num][offset[4:2]][23:16],
                                             valid_lane[1] ? wr_data[15: 8] : data_way_bank[way_num][offset[4:2]][15: 8],
                                             valid_lane[0] ? wr_data[ 7: 0] : data_way_bank[way_num][offset[4:2]][ 7: 0]};
                valid                   =   1;
                dirty                   =   1;
            end
        end

        SWPO:   begin
            axi_wr_req      =   1;
            axi_wr_data     =   data_way_bank[LRU_index[index]];
            axi_addr        =   {tagvd_way[LRU_index[index]][21:2], index, 5'b00000};
        end

        SWPI:   begin
            axi_rd_req      =   1;
            axi_addr        =   {addr[31:5], 5'b00000};
        end

        WRIT: begin
            for(i = 0; i < 8; i++)
                we_bank[i]                  =   1;
            we_way[LRU_index[index]]        =   1;
            for(i = 0; i < 8; i++)
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