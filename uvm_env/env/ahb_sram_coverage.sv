class ahb_sram_coverage extends uvm_subscriber#(ahb_transaction);

    `uvm_component_utils(ahb_sram_coverage)
    
    ahb_transaction ahb_tr_cov;

    covergroup cg_sram_bank;
        option.per_instance = 1;
        cp_address: coverpoint ahb_tr_cov.haddr[15:0] {
            bins bank0 = {[16'h0000:16'h7FFF]};
            bins bank1 = {[16'h8000:16'hFFFF]};
        }
        cp_hsize: coverpoint ahb_tr_cov.hsize {
            bins b8  = {3'b000};
            bins b16 = {3'b001};
            bins b32 = {3'b010};
        }
        cp_hwrite: coverpoint ahb_tr_cov.hwrite{
            bins bin_read = {1'b0};
            bins bin_write = {1'b1};
        }
        cp_byte_offset: coverpoint ahb_tr_cov.haddr[1:0] {
            bins bin_offset_0 = {2'b00};
            bins bin_offset_1 = {2'b01};
            bins bin_offset_2 = {2'b10};
            bins bin_offset_3 = {2'b11};
        }
        cp_addr_boundary: coverpoint ahb_tr_cov.haddr[15:0] {
            bins bin_boundaries[] = {16'h0000, 16'h7FFC, 16'h8000, 16'hFFFC};
        }
        cross cp_address, cp_hsize, cp_hwrite;
        cross cp_hsize, cp_byte_offset {
            ignore_bins b32_unaligned = binsof(cp_hsize.b32) && (!binsof(cp_byte_offset.bin_offset_0));
            ignore_bins b16_unaligned = binsof(cp_hsize.b16) && (binsof(cp_byte_offset.bin_offset_1) || binsof(cp_byte_offset.bin_offset_3)); 
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_sram_bank = new();
    endfunction: new

    virtual function void write(ahb_transaction t);
        ahb_tr_cov = t;
        cg_sram_bank.sample();
    endfunction: write

endclass: ahb_sram_coverage