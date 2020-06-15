//AXI 请求模块

module axi(
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

//以下读写暂时默认字对齐，如有非对齐访问需要可以另行修改
//=================================================//
//需要适配的寄存器/堆
reg read_en, write_en;
reg [31:0] read_addr, read_length, write_addr, write_length, addr;
reg [31:0] cache [0:31];
//=================================================//
    //read
    //假设cache需要读read_addr处的地址，读read_length个字节，存放在cache缓存write_addr地址中，读的时候read_en有效，按字节寻址
    reg [1:0] rcs, rns;
    always@(posedge aclk) begin
        if(aresetn)
            rcs <= 0;
        else 
            rcs <= rns;
    end
    always@(*) begin
        case(rcs)
        0: begin
            if(read_en)
                rns = 1;
            else
                rns = 0;
        end
        1: begin
            if(arready)
                rns = 2;
            else
                rns = 1;
        end
        2: begin
            if(rlast)
                rns = 0;
            else 
                rns = 2;
        end
        default: ;
        endcase
    end
    always@(*)begin
        case(rcs)
        0: begin
            araddr = 0;
            arvalid = 0;

            rready = 0;
        end
        1: begin
            araddr = read_addr;
            arlen = read_length - 1;
            arvalid = 1;
        end
        2: begin
            rready = 1;
        end
        default: ;
        endcase
    end
    always@(posedge aclk) begin
        if(rvalid && rready)
            cache[write_addr] <= rdata;
        write_addr <= write_addr + 32'd4;
    end

    //write
    //假设将cache的addr写入mem的write_addr中，write_en有效，写write_length个字节
    reg [1:0] wcs, wns;
    always@(posedge aclk) begin
        if(aresetn)
            wcs <= 0;
        else 
            wcs <= wns;
    end
    always@(*) begin
        case(wcs)
        0: begin
            if(write_en)
                wns = 1;
            else 
                wns = 0;
        end
        1: begin
            if(awready)
                wns = 2;
            else 
                wns = 1;
        end
        2: begin
            if(wlast)
                wns = 3;
            else
                wns = 2;
        end
        3: begin
            if(bresp && bvalid && bready)
                wns = 0;
            else
                wns = 3;
        end
        default: ;
        endcase
    end
    always@(*) begin
        case(wcs)
        0: begin
            awvalid = 0;
            wvalid = 0;
            bready = 0;
        end
        1: begin
            awaddr = write_addr;
            awvalid = 1;
            awlen = write_length - 1;
        end
        2: begin
            wdata = cache[addr];
            wvalid = 1;
            bready = 1;
        end
        3: begin
            awvalid = 0;
            wvalid = 0;
            bready = 0;
        end
        default: ;
        endcase
    end
    always@(posedge aclk) begin
        if(wready && wvalid && bready)
            addr <= addr + 32'd4;
        if(wready && wvalid && bready && write_length >= 1) 
            write_length <= write_length - 1;
        else if(wready && wvalid && bready && write_length == 1) begin
            write_length <= write_length - 1;
            wlast <= 1;
        end
        else begin
            write_length <= write_length;
            wlast <= 0;
        end
    end


    //常量赋值，一般用不到
    always@(*) begin
         arid = 4'd0;
         arburst = 2'd01;
         arlock = 2'd0;
         arcache = 4'd0;
         arprot = 3'd0;
         awid = 4'd1;
         awburst = 2'd1;
         awlock = 2'd0;
         awcache = 4'd0;
         awprot = 3'd0;
         wid = 4'd1;
    end
    
endmodule