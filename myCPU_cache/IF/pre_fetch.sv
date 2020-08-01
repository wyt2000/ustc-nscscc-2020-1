`timescale 1ns / 1ps
`define PREFETCH_ENABLE
module pre_fetch (
    input               clk,
    input               rst,

    //connect with icache
    input       [19:0]  tag,
    input               we_way[0:3],
    input       [6 :0]  tagv_index,
    input               valid,
    input               miss,

    //IF stage request info
    input               rd_req,
    input       [31:0]  rd_addr,

    //connect with arbitrate
    output reg  [31:0]  buff_addr,
    output reg  [31:0]  buff_data[0:7],
    output reg          buff_ready,

    //AXI request
    output      [3 :0]  arid     ,
    output reg  [31:0]  araddr   ,
    output      [7 :0]  arlen    ,
    output      [2 :0]  arsize   ,
    output      [1 :0]  arburst  ,
    output      [1 :0]  arlock   ,
    output      [3 :0]  arcache  ,
    output      [2 :0]  arprot   ,
    output reg          arvalid  ,
    input               arready  ,
    //r           
    input       [3 :0]  rid      ,
    input       [31:0]  rdata    ,
    input       [1 :0]  rresp    ,
    input               rlast    ,
    input               rvalid   ,
    output reg          rready   ,
    //aw          
    output      [3 :0]  awid     ,
    output      [31:0]  awaddr   ,
    output      [7 :0]  awlen    ,
    output      [2 :0]  awsize   ,
    output      [1 :0]  awburst  ,
    output      [1 :0]  awlock   ,
    output      [3 :0]  awcache  ,
    output      [2 :0]  awprot   ,
    output              awvalid  ,
    input               awready  ,
    //w          
    output      [3 :0]  wid      ,
    output      [31:0]  wdata    ,
    output      [3 :0]  wstrb    ,
    output              wlast    ,
    output              wvalid   ,
    input               wready   ,
    //b           
    input       [3 :0]  bid      ,
    input       [1 :0]  bresp    ,
    input               bvalid   ,
    output              bready       

);
    int                 i;

    localparam          IDLE    =   0;
    localparam          HDSK    =   1;
    localparam          TRAN    =   2;

    localparam  BURST_LENGTH    =   8;
    localparam  BURST_TYPE_FIXED=   2'B00;
    localparam  BURST_TYPE_INCR =   2'B01;
    localparam  BURST_TYPE_WRAP =   2'B10;

    wire        [20:0]  tagv_way[0:3];
    wire        [3 :0]  way_hit;

    reg         [1 :0]  current_state,  next_state;
    reg         [3 :0]  count;

    BUFF_TAGV_RAM   MIRROR_WAY_0(.addra(tagv_index),    .clka(clk), .dina({tag, valid}),    .wea(we_way[0]),    .ena(1),    .addrb({tagv_index + 1}),   .clkb(clk), .doutb(tagv_way[0]),   .enb(1));
    BUFF_TAGV_RAM   MIRROR_WAY_1(.addra(tagv_index),    .clka(clk), .dina({tag, valid}),    .wea(we_way[1]),    .ena(1),    .addrb({tagv_index + 1}),   .clkb(clk), .doutb(tagv_way[1]),   .enb(1));
    BUFF_TAGV_RAM   MIRROR_WAY_2(.addra(tagv_index),    .clka(clk), .dina({tag, valid}),    .wea(we_way[2]),    .ena(1),    .addrb({tagv_index + 1}),   .clkb(clk), .doutb(tagv_way[2]),   .enb(1));
    BUFF_TAGV_RAM   MIRROR_WAY_3(.addra(tagv_index),    .clka(clk), .dina({tag, valid}),    .wea(we_way[3]),    .ena(1),    .addrb({tagv_index + 1}),   .clkb(clk), .doutb(tagv_way[3]),   .enb(1));

    assign  way_hit = {tagv_way[3][20:1] == rd_addr[31:12] && tagv_way[3][0],
                       tagv_way[2][20:1] == rd_addr[31:12] && tagv_way[2][0],
                       tagv_way[1][20:1] == rd_addr[31:12] && tagv_way[1][0],
                       tagv_way[0][20:1] == rd_addr[31:12] && tagv_way[0][0]};

//==========state machine begin==========//
    //state change
    always@(posedge clk) begin
        if(rst)
            current_state   <=  IDLE;
        else
            current_state   <=  next_state;
    end
    //next state logic
    always@(*) begin
        case(current_state)
        `ifdef PREFETCH_ENABLE
        IDLE:   begin
            if(rst)
                next_state  =   IDLE;
            else if((!(|way_hit) && !miss && rd_req))
                next_state  =   HDSK;
            else
                next_state  =   IDLE;
        end

        HDSK:   begin
            if(arvalid && arready)
                next_state  =   TRAN;
            else
                next_state  =   HDSK;
        end

        TRAN:   begin
            if(count == BURST_LENGTH - 1 && rlast && rvalid && rready)
                next_state  =   IDLE;
            else
                next_state  =   TRAN;
        end
        `endif
        default:begin
            next_state  =   IDLE;
        end
        endcase
    end
    //control signals
    always@(*) begin
        arvalid     =   0;
        rready      =   0;
        araddr      =   0;
        case(current_state)
        HDSK:   begin
            arvalid     =   1;
            araddr      =   buff_addr;
        end

        TRAN:   begin
            rready      =   1;
        end
        default:    ;
        endcase
    end
//==========stage machine end==========//
    //save req info
    always@(posedge clk) begin
        if(rst)
            buff_addr   <=  0;
        if((!(|way_hit) && !miss && rd_req) && current_state == IDLE)
            buff_addr   <=  {rd_addr[31:5] + 1, 5'b00000};
    end

    //buff ready
    always@(posedge clk) begin
        if(rst)
            buff_ready  <=  0;
        else if(rlast && rvalid && rready)
            buff_ready  <=  1;
        else if((!(|way_hit) && !miss && rd_req) && current_state == IDLE)
            buff_ready  <=  0;
    end

    //count and data control
    always@(posedge clk) begin
        if(rst) begin
            count   <=  0;
            for(i = 0; i < 8; i++) begin
                buff_data[i]    <=  0;
            end
        end
        else if(current_state == TRAN) begin
            if(rvalid && rready) begin
                buff_data[count]    <=  rdata;
                count               <=  count + 1;
            end
            else
                count               <=  count;
        end
        else
                count               <=  0;
    end

    assign arid     =   0;
    assign arlen    =   BURST_LENGTH - 1;
    assign arsize   =   2;
    assign arburst  =   BURST_TYPE_INCR;
    assign arlock   =   0;
    assign arcache  =   0;
    assign arprot   =   0;

    assign awid     =   0;
    assign awaddr   =   0;
    assign awlen    =   0;
    assign awsize   =   0;
    assign awburst  =   0;
    assign awlock   =   0;
    assign awcache  =   0;
    assign awprot   =   0;
    assign awvalid  =   0;

    assign wid      =   0;
    assign wdata    =   0;
    assign wstrb    =   0;
    assign wlast    =   0;
    assign wvalid   =   0;
    assign bready   =   0;
    // always@(*) begin
    //     arid        =   0;
    //     arlen       =   BURST_LENGTH - 1;
    //     arsize      =   2;
    //     arburst     =   BURST_TYPE_INCR;
    //     arlock      =   0;
    //     arcache     =   0;
    //     arprot      =   0;

    //     awid        =   4'b0;
    //     awaddr      =   32'b0;
    //     awlen       =   8'b0;
    //     awsize      =   0;
    //     awburst     =   0;
    //     awlock      =   0;
    //     awcache     =   0;
    //     awprot      =   0;
    //     awvalid     =   0;

    //     wid         =   0;
    //     wdata       =   0;
    //     wstrb       =   0;
    //     wlast       =   0;
    //     wvalid      =   0;

    //     bready      =   1;
    // end

endmodule