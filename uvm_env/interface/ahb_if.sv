interface ahb_if(input logic hclk, input logic hresetn);
    //AHB Signals
    logic hsel;
    logic hwrite;
    logic [1:0] htrans;
    logic [2:0] hsize;
    logic [15:0] haddr;
    logic [31:0] hwrdata;
    logic hready; //Alwasy High
    logic [1:0] hresp;  //Always Ready
    logic [1:0] bank_sel;
    logic [31:0] hrdata;
    logic reset_trigger = 1'b0; 
    
    logic dut_resetn;
    
    assign dut_resetn = reset_trigger ? 1'b0 : hresetn;
    clocking cb @(posedge hclk);
        output haddr, hwrdata, hwrite, htrans, hsize, hsel;
        input  hrdata, bank_sel;
    endclocking

    // AHB Protocol Assertions 
    property hresp_always_okay;
        @(posedge hclk)
        disable iff(!hresetn)
        hresp == 2'b00;
    endproperty

    property hreadyout_always_high;
        @(posedge hclk)
        disable iff(!hresetn)
        hready == 1'b1;
    endproperty

    property aligned_16bit_addr;
        @(posedge hclk)
        disable iff(!hresetn)
        (hsel && htrans[1] && hsize == 3'b001) |-> (haddr[0] == 1'b0);
    endproperty

    property aligned_32bit_addr;
        @(posedge hclk)
        disable iff(!hresetn)
        (hsel && htrans[1] && hsize == 3'b010) |-> (haddr[1:0] == 2'b00);
    endproperty

    property valid_htrans;
        @(posedge hclk)
        disable iff(!hresetn)
        htrans inside {2'b00, 2'b10};
    endproperty

    assert_valid_htrans:    assert property (valid_htrans)
                            else $error("ASSERT FAIL: invalid htrans value");

    assert_hresp:           assert property(hresp_always_okay)
                            else $error("ASSERT FAIL: hresp is not OKAY");

    assert_hready:          assert property (hreadyout_always_high)
                            else $error("ASSERT FAIL: hreadyout is not high");

    assert_align16:         assert property (aligned_16bit_addr)
                            else $error("ASSERT FAIL: 16-bit address misaligned");

    assert_align32:         assert property (aligned_32bit_addr)
                            else $error("ASSERT FAIL: 32-bit address misaligned");

    // SRAM Controller Assertions 
    property bank0_sel_when_addr15_low;
        @(posedge hclk) disable iff (!hresetn)
        (hsel && htrans[1] && !haddr[15]) |=> (bank_sel == 2'b01);
    endproperty

    property bank1_sel_when_addr15_high;
        @(posedge hclk) disable iff (!hresetn)
        (hsel && htrans[1] && haddr[15]) |=> (bank_sel == 2'b10);
    endproperty

    property no_bank_when_idle;
        @(posedge hclk) disable iff (!hresetn)
        !(hsel && htrans[1]) |=> (bank_sel == 2'b00);
    endproperty


    property read_data_valid;
        @(posedge hclk) disable iff (!hresetn)
        (hsel && htrans[1] && !hwrite) |=> (!$isunknown(hrdata));
    endproperty

    assert_bank0:           assert property (bank0_sel_when_addr15_low)
                            else $error("ASSERT FAIL: bank0 not selected when addr[15]=0");

    assert_bank1:           assert property (bank1_sel_when_addr15_high)
                            else $error("ASSERT FAIL: bank1 not selected when addr[15]=1");

    assert_no_bank:         assert property (no_bank_when_idle)
                            else $error("ASSERT FAIL: bank active during idle");

    assert_read_valid:      assert property (read_data_valid)
                            else $error("ASSERT FAIL: read data contains X or Z");

endinterface