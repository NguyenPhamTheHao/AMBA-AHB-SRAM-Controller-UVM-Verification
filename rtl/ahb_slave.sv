module ahb_slave(
    input logic hclk,
    input logic hresetn,
    input logic hready,
    input logic hsel,
    input logic hwrite,
    input logic [2:0] hsize,
    input logic [1:0] htrans,
    input logic [15:0] haddr,
    input logic [31:0] hwrdata,
    input logic [31:0] sram_rdata,
    //Output for Master
    output logic [31:0] hrdata,
    output logic hreadyout,
    output logic [1:0] hresp,
    //Output for controlling Sram 
    output logic sram_write,
    output logic [2:0] sram_size,
    output logic [15:0] sram_addr,
    output logic [31:0] sram_wdata,
    output logic sram_ce
);
    localparam IDLE   = 2'b00;
    localparam BUSY   = 2'b01;
    localparam NONSEQ = 2'b10;
    localparam SEQ    = 2'b11;
    logic reg_write;
    //Pipeline Register for one cycle after data phase
    always @(posedge hclk or negedge hresetn) begin
        if(!hresetn) begin
            sram_addr<=16'h0;
            sram_ce<=1'b0;
            reg_write<=1'b0;
            sram_size<=3'b000;
        end
        else if(hready) begin
            sram_addr<=haddr;
            sram_ce<=hsel && (htrans==NONSEQ || htrans==SEQ);
            reg_write<=hwrite;
            sram_size<=hsize;
        end
    end
    assign sram_wdata=hwrdata;
    assign sram_write=sram_ce && reg_write;
    assign hrdata=sram_rdata;
    assign hreadyout=1'b1;
    assign hresp=2'b00;
endmodule

