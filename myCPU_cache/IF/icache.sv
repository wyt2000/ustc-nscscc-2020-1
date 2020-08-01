`timescale 1ns / 1ps

module icache (
    input               clk,
    input               rst,

    //connect with CPU
    output              miss,
    input       [31:0]  addr,
    output reg  [31:0]  rd_data,
    input               rd_req,

    //connect with axi module
    input               axi_gnt,
    input       [31:0]  axi_data[0:7],
    output      [31:0]  axi_addr,
    output reg          axi_rd_req,
    output reg  [1 :0]  current_state
);
    int             i;

    reg     [6 :0]  index_old;
    wire            ram_ready;

    wire    [19:0]  tag;
    wire    [6 :0]  index;
    wire    [4 :0]  offset;

    reg     [1 :0]  LRU_index[0:127];
    reg             we_way[0:3];
    wire    [20:0]  tagv_way[0:3];
    wire    [31:0]  data_way_bank[0:3][0:7];

    wire    [3 :0]  way_hit;

    reg     [1 :0]  next_state;

    reg     [6 :0]  reset_count;
    wire    [6 :0]  tagv_index;
    reg             valid;

    localparam      IDLE    =   1;
    localparam      REQ     =   2;
    localparam      WRIT    =   3;
    localparam      RSET    =   0;

    TAGV_RAM TAGV_WAY_0 (.clka(clk),    .addra(tagv_index),  .douta(tagv_way[0]),    .wea(we_way[0]),     .dina({tag, valid}),    .ena(1));
    TAGV_RAM TAGV_WAY_1 (.clka(clk),    .addra(tagv_index),  .douta(tagv_way[1]),    .wea(we_way[1]),     .dina({tag, valid}),    .ena(1));
    TAGV_RAM TAGV_WAY_2 (.clka(clk),    .addra(tagv_index),  .douta(tagv_way[2]),    .wea(we_way[2]),     .dina({tag, valid}),    .ena(1));
    TAGV_RAM TAGV_WAY_3 (.clka(clk),    .addra(tagv_index),  .douta(tagv_way[3]),    .wea(we_way[3]),     .dina({tag, valid}),    .ena(1));

    DATA_RAM DATA_WAY0_BANK0 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][0]),    .wea(we_way[0]),     .dina(axi_data[0]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK1 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][1]),    .wea(we_way[0]),     .dina(axi_data[1]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK2 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][2]),    .wea(we_way[0]),     .dina(axi_data[2]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK3 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][3]),    .wea(we_way[0]),     .dina(axi_data[3]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK4 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][4]),    .wea(we_way[0]),     .dina(axi_data[4]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK5 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][5]),    .wea(we_way[0]),     .dina(axi_data[5]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK6 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][6]),    .wea(we_way[0]),     .dina(axi_data[6]),    .ena(1));
    DATA_RAM DATA_WAY0_BANK7 (.clka(clk),   .addra(index),  .douta(data_way_bank[0][7]),    .wea(we_way[0]),     .dina(axi_data[7]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK0 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][0]),    .wea(we_way[1]),     .dina(axi_data[0]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK1 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][1]),    .wea(we_way[1]),     .dina(axi_data[1]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK2 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][2]),    .wea(we_way[1]),     .dina(axi_data[2]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK3 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][3]),    .wea(we_way[1]),     .dina(axi_data[3]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK4 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][4]),    .wea(we_way[1]),     .dina(axi_data[4]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK5 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][5]),    .wea(we_way[1]),     .dina(axi_data[5]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK6 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][6]),    .wea(we_way[1]),     .dina(axi_data[6]),    .ena(1));
    DATA_RAM DATA_WAY1_BANK7 (.clka(clk),   .addra(index),  .douta(data_way_bank[1][7]),    .wea(we_way[1]),     .dina(axi_data[7]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK0 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][0]),    .wea(we_way[2]),     .dina(axi_data[0]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK1 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][1]),    .wea(we_way[2]),     .dina(axi_data[1]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK2 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][2]),    .wea(we_way[2]),     .dina(axi_data[2]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK3 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][3]),    .wea(we_way[2]),     .dina(axi_data[3]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK4 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][4]),    .wea(we_way[2]),     .dina(axi_data[4]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK5 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][5]),    .wea(we_way[2]),     .dina(axi_data[5]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK6 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][6]),    .wea(we_way[2]),     .dina(axi_data[6]),    .ena(1));
    DATA_RAM DATA_WAY2_BANK7 (.clka(clk),   .addra(index),  .douta(data_way_bank[2][7]),    .wea(we_way[2]),     .dina(axi_data[7]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK0 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][0]),    .wea(we_way[3]),     .dina(axi_data[0]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK1 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][1]),    .wea(we_way[3]),     .dina(axi_data[1]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK2 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][2]),    .wea(we_way[3]),     .dina(axi_data[2]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK3 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][3]),    .wea(we_way[3]),     .dina(axi_data[3]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK4 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][4]),    .wea(we_way[3]),     .dina(axi_data[4]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK5 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][5]),    .wea(we_way[3]),     .dina(axi_data[5]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK6 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][6]),    .wea(we_way[3]),     .dina(axi_data[6]),    .ena(1));
    DATA_RAM DATA_WAY3_BANK7 (.clka(clk),   .addra(index),  .douta(data_way_bank[3][7]),    .wea(we_way[3]),     .dina(axi_data[7]),    .ena(1));

    assign  miss    = (((!(|way_hit)) || (!ram_ready)) && rd_req) || (current_state == RSET) || (rst);
    assign  {tag,   index,  offset} = addr;
    assign  way_hit = {((tag == tagv_way[3][20:1]) && tagv_way[3][0]), 
                       ((tag == tagv_way[2][20:1]) && tagv_way[2][0]), 
                       ((tag == tagv_way[1][20:1]) && tagv_way[1][0]), 
                       ((tag == tagv_way[0][20:1]) && tagv_way[0][0])};
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
    assign  axi_addr    =   {addr[31:5], 5'b00000};
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
            if(rst)begin
                next_state  =   RSET;
            end
            else begin
                if(| way_hit) begin
                    next_state  =   IDLE;
                end
                else if(~ ram_ready) begin
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
            if(axi_gnt)
                next_state  =   WRIT;
            else
                next_state  =   REQ;
        end

        WRIT:   begin
            next_state      =   IDLE;
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
        valid           =   0;
        for(i = 0; i < 4; i++)
            we_way[i]   =   0;
        axi_rd_req      =   0;
        case(current_state)
        IDLE:   begin
            if(((!(|way_hit)) && ram_ready && rd_req) && !rst)
                axi_rd_req  =   1;
        end

        REQ:    begin
            axi_rd_req      =   1;
        end

        WRIT:   begin
            we_way[LRU_index[index]]    =   1;
            valid                       =   1;
        end

        RSET:   begin
            for(i = 0; i < 4; i++)
                we_way[i]   =   1;
            valid           =   0;
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
        else if((|way_hit) && ram_ready) begin
            if(LRU_index[index] == (way_hit == 4'b1000 ? 2'b11 : way_hit >> 1))
                LRU_index[index]    <=  LRU_index[index] + 1;
            else 
                LRU_index[index]    <=  LRU_index[index];
        end
    end

    //get ram ready
    always@(posedge clk) begin
        if(rst) begin
            index_old <= 0;
        end
        else begin
            index_old   <=  index;
        end
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
