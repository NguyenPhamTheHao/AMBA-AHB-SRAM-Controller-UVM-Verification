`include "uvm_macros.svh"
 
 module top;
    import uvm_pkg::*;
    import ahb_agents_pkg::*;
    import ahb_env_pkg::*;
    import test_pkg::*;

    // 1. Clock and Reset Generation
    logic hclk;
    logic hresetn;

    initial begin
        hclk = 0;
        forever #5 hclk = ~hclk; // 100MHz clock
    end

    initial begin
        hresetn = 0;
        #20 hresetn = 1;
    end

    // 2. Instantiate the Physical Interface
    // We combine the top hresetn and the interface-driven reset_trigger
    // If reset_trigger is high, we pull actual_resetn low (active low reset)
    ahb_if p_if(hclk, hresetn);
    // 3. Instantiate the DUT (RTL)
    sram_ctrl dut (
        .hclk    (p_if.hclk),
        .hresetn (p_if.dut_resetn),
        .haddr   (p_if.haddr),
        .hsize   (p_if.hsize),
        .hsel    (p_if.hsel),
        .hwrite  (p_if.hwrite),
        .htrans  (p_if.htrans),
        .hwrdata  (p_if.hwrdata),
        .hrdata  (p_if.hrdata),
        .hready  (p_if.hready),
        .hreadyout(p_if.hready),
        .hresp   (p_if.hresp),
        .bank_sel(p_if.bank_sel)
    );

    // 4. Pass the Interface to UVM Configuration Database
    initial begin
        uvm_config_db#(virtual ahb_if)::set(null, "*", "vif", p_if);
        run_test();
    end
 endmodule