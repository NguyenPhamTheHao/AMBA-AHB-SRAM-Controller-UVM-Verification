interface ahb_if(input logic hclk, input logic hresetn);
    //AHB Signals
    logic hsel;
    logic write;
    logic [1:0] htrans;
    logic [2:0] hsize;
    logic [15:0] haddr;
    logic [31:0] hwrdata;
    logic hready; //Alwasy High
    logic [1:0] hresp;  //Always Ready
    logic [1:0] bank_sel;
    logic [31:0] hrdata;

    clocking cb @(posedge hclk);
        output hsel, hwrite, htrans, hsize, haddr, hwrdata;
        input hrdata, bank_sel;
    endclocking
endinterface