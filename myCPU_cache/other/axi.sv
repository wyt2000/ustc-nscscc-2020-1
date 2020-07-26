module axi
#(
    parameter                   LINE_ADDR_LEN = 3           ,
    parameter                   ADDR_LEN      = 8           
)
(
//requests from cache
    output  reg                 gnt                         ,
    input              [31: 0]  addr                        ,
    input                       rd_req                      ,
    output  reg        [31: 0]  rd_line [8]                 , 
    input                       wr_req                      ,
    input              [31: 0]  wr_line [8]                 , 

//AXI
    //global
    input         aclk         ,
    input         aresetn      ,
    //ar
    output reg [3 :0] arid     ,
    output reg [31:0] araddr   ,
    output reg [7 :0] arlen    ,
    output reg [2 :0] arsize   ,
    output reg [1 :0] arburst  ,
    output reg [1 :0] arlock   ,
    output reg [3 :0] arcache  ,
    output reg [2 :0] arprot   ,
    output reg        arvalid  ,
    input             arready  ,
    //r           
    input  [3 :0] rid          ,
    input  [31:0] rdata        ,
    input  [1 :0] rresp        ,
    input         rlast        ,
    input         rvalid       ,
    output reg    rready       ,
    //aw          
    output reg [3 :0] awid     ,
    output reg [31:0] awaddr   ,
    output reg [7 :0] awlen    ,
    output reg [2 :0] awsize   ,
    output reg [1 :0] awburst  ,
    output reg [1 :0] awlock   ,
    output reg [3 :0] awcache  ,
    output reg [2 :0] awprot   ,
    output reg        awvalid  ,
    input             awready  ,
    //w          
    output reg [3 :0] wid      ,
    output reg [31:0] wdata    ,
    output reg [3 :0] wstrb    ,
    output reg        wlast    ,
    output reg        wvalid   ,
    input             wready   ,
    //b           
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input         bvalid       ,
    output  reg   bready       
);

    //AXI info
    localparam  NUMBER_BYTES    =   2;      //feels strange, but only when it is 2 it works properly
    localparam  DATA_BUS_BYTES  =   4;
    localparam  BURST_LENGTH    =   (1<<LINE_ADDR_LEN);
    localparam  LOWER_BYTE_LANE =   0;
    localparam  UPPER_BYTE_LANE =   3;
    localparam  BURST_TYPE_FIXED=   2'B00;
    localparam  BURST_TYPE_INCR =   2'B01;
    localparam  BURST_TYPE_WRAP =   2'B10;

    //stage machine parameters
    localparam  IDLE            =   0;
    localparam  HDSK            =   1;
    localparam  TRANS           =   2;
    localparam  WR              =   1;
    localparam  RD              =   0;

    reg [31 :0] Start_Address;
    // reg [31 :0] write_data[BURST_LENGTH];
    reg         request_type;
    reg [3  :0] count;
    reg [1  :0] current_state,  next_state;
    
    //save request information
    always@(posedge aclk) begin
        if(!aresetn) begin
            request_type    <=  0;
            Start_Address   <=  0;
            // write_data      <=  0;
        end
        else if((rd_req || wr_req)) begin
            Start_Address   <=  addr;
            // write_data      <=  wr_line;
            if(wr_req)
                request_type<=  WR;
            else
                request_type<=  RD;
        end
        else begin
            Start_Address   <=  Start_Address;
            // write_data      <=  write_data;
            request_type    <=  request_type;
        end
    end

    //stage machine
    always@(posedge aclk) begin
        if(!aresetn) 
            current_state   <=  IDLE;
        else
            current_state   <=  next_state;
    end

    always@(*) begin
        case(current_state)
        IDLE:   begin
            if((rd_req || wr_req) && !gnt)
                next_state  =   HDSK;
            else
                next_state  =   IDLE;
        end
        HDSK:   begin
            if((arvalid && arready) || (awvalid && awready))
                next_state  =   TRANS;
            else
                next_state  =   HDSK;
        end
        TRANS:  begin
            if(/*(rvalid && rlast && rready) || (wvalid && wlast && wready)*/count == BURST_LENGTH)
                next_state  =   IDLE;
            else
                next_state  =   TRANS;
        end
        default:    begin
            next_state = IDLE;
        end
        endcase
    end

    always@(*) begin
        gnt     =   0;
        arvalid =   0;
        rready  =   0;
        awvalid =   0;
        wvalid  =   0;
        wlast   =   0;
        case(current_state)
        HDSK: begin
            if(request_type == RD)
                arvalid     =   1;
            else
                awvalid     =   1;
        end
        TRANS:begin
            if(request_type == RD) begin
                rready      =   1;
                if(count == BURST_LENGTH)
                    gnt     =   1;
            end
            else begin
                wvalid      =   1;
                if(count == BURST_LENGTH) begin
                    wlast   =   1;
                    gnt     =   1;
                end
            end
        end
        default:    ;
        endcase 
    end

    //count control and data control
    always@(posedge aclk) begin
        if(!aresetn)
            count   <=  0;
        else if(current_state == TRANS) begin
            if(request_type == RD) begin
                if(rvalid && rready) begin
                    rd_line[count]  <=  rdata;
                    count           <=  count + 1;
                end
                else
                    count           <=  count;
            end
            else begin
                if(wvalid && wready)
                    count           <=  count + 1;
                else
                    count           <=  count;
            end
        end
        else 
                    count           <=  0;
    end
    always@(*) begin
        wdata = wr_line[count];
    end

    //constants
    always@(*) begin
        arid        =   0;
        araddr      =   addr;
        arlen       =   BURST_LENGTH - 1;
        arsize      =   NUMBER_BYTES;
        arburst     =   BURST_TYPE_INCR;
        arlock      =   0;
        arcache     =   0;
        arprot      =   0;

        awid        =   0;
        awaddr      =   addr;
        awlen       =   BURST_LENGTH - 1;
        awsize      =   NUMBER_BYTES;
        awburst     =   BURST_TYPE_INCR;
        awlock      =   0;
        awcache     =   0;
        awprot      =   0;

        wid         =   0;
        wstrb       =   4'b1111;
        
        bready      =   1;
    end

endmodule