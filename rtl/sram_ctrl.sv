module sram_ctrl (
    input  logic        hclk,
    input  logic        hresetn,
    input  logic        hready,
    input  logic        hsel,
    input  logic        hwrite,
    input  logic [2:0]  hsize,
    input  logic [1:0]  htrans,
    input  logic [15:0] haddr,
    input  logic [31:0] hwrdata,
    output logic [31:0] hrdata,
    output logic        hreadyout,
    output logic [1:0]  hresp,
    output logic [1:0]  bank_sel
);
    // INTERNAL SIGNALS DECLARATION 
    logic [31:0] w_sram_wdata; 
    logic        w_sram_write;  
    logic [2:0]  w_sram_size;  
    logic        w_sram_ce;     
    logic [3:0]  w_sram_we;     
    logic [31:0] w_sram_rdata;  

    // MODULE INSTANTIATIONS
    //Instantiate AHB Slave Interface
    ahb_slave u_ahb_slave (
        .hclk       (hclk),
        .hresetn    (hresetn),
        .hready     (hready),
        .hsel       (hsel),
        .hwrite     (hwrite),
        .hsize      (hsize),
        .htrans     (htrans),
        .haddr      (haddr),
        .hwrdata     (hwrdata),
        .sram_rdata (w_sram_rdata),      
        .hrdata     (hrdata),      
        .hreadyout  (hreadyout),
        .hresp      (hresp),  
        .sram_write (w_sram_write), 
        .sram_size  (w_sram_size),
        .sram_addr  (w_sram_addr),
        .sram_wdata (w_sram_wdata),
        .sram_ce    (w_sram_ce)
    );
    // Instantiate Byte Lane Masking Control Module
    byte_lane_masking_control u_byte_lane_mask (
        .addr_control (w_sram_addr[1:0]),
        .sram_write   (w_sram_write),
        .sram_size    (w_sram_size),
        .sram_ce      (w_sram_ce),
        .sram_we      (w_sram_we)        
    );
    //Instantiate SRAM Memory
    sram u_sram (
        .clk        (hclk),              
        .resetn     (hresetn),            
        .A          (w_sram_addr),        
        .WD         (w_sram_wdata),       
        .WE         (w_sram_we),        
        .CE         (w_sram_ce),         
        .RD         (w_sram_rdata)        
    );

    //Logic for sub output
    assign bank_sel =(sram_ce) ? (sram_addr[15] ? 2'b10 : 2'b01) : 2'b00;
endmodule