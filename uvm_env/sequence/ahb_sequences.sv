class ahb_base_seq extends uvm_sequence #(ahb_transaction);
    `uvm_object_utils(ahb_base_seq)
    function new(string name = "ahb_base_seq");
        super.new(name);
    endfunction
endclass

class sequence_addr0 extends ahb_base_seq;
    `uvm_object_utils(sequence_addr0)
    function new(string name = "sequence_addr0");
        super.new(name);
    endfunction
    
    virtual task body();
        for (int i = 0; i < 20; i++) begin
            // Write
            `uvm_do_with(req, {req.haddr == i*4; req.hwrite == 1'b1; req.hsize == 3'b010;})
            // Read
            `uvm_do_with(req, {req.haddr == i*4; req.hwrite == 1'b0; req.hsize == 3'b010;})
        end
    endtask
endclass

class sequence_addr1 extends ahb_base_seq;
    `uvm_object_utils(sequence_addr1)
    function new(string name = "sequence_addr1");
        super.new(name);
    endfunction
    
    virtual task body();
        repeat(20) begin
            `uvm_do_with(req, {req.hsize == 3'b010;})
        end
    endtask
endclass

class sequence_addr2 extends ahb_base_seq;
    `uvm_object_utils(sequence_addr2)
    function new(string name = "sequence_addr2");
        super.new(name);
    endfunction
    
    virtual task body();
        repeat(20) begin
            `uvm_do_with(req, {req.hsize inside {3'b000, 3'b001, 3'b010};})
        end
    endtask
endclass

class sequence_hsize extends ahb_base_seq;
    `uvm_object_utils(sequence_hsize)
    function new(string name = "sequence_hsize");
        super.new(name);
    endfunction
    
    virtual task body();
        repeat(20) begin
            `uvm_do_with(req, {req.hsize == 3'b010;})
        end
    endtask
endclass

class seq_all_sizes extends ahb_base_seq;
    `uvm_object_utils(seq_all_sizes)

    function new(string name = "seq_all_sizes");
        super.new(name);
    endfunction: new

    virtual task body();
        bit [31:0] test_addr = 32'h0000;
        // 8-bit R/W
        `uvm_do_with(req, {req.haddr == test_addr; req.hwrite == 1'b1; req.hsize == 3'b000; req.hwrdata == 32'hA5;})
        `uvm_do_with(req, {req.haddr == test_addr; req.hwrite == 1'b0; req.hsize == 3'b000;})
        // 16-bit R/W
        `uvm_do_with(req, {req.haddr == test_addr; req.hwrite == 1'b1; req.hsize == 3'b001; req.hwrdata == 32'h5A5A;})
        `uvm_do_with(req, {req.haddr == test_addr; req.hwrite == 1'b0; req.hsize == 3'b001;})
        // 32-bit R/W
        `uvm_do_with(req, {req.haddr == test_addr; req.hwrite == 1'b1; req.hsize == 3'b010; req.hwrdata == 32'h12345678;})
        `uvm_do_with(req, {req.haddr == test_addr; req.hwrite == 1'b0; req.hsize == 3'b010;})
    endtask 
endclass: seq_all_sizes

class seq_bank_boundary extends ahb_base_seq;
    `uvm_object_utils(seq_bank_boundary)

    function new(string name = "seq_bank_boundary");
        super.new(name);
    endfunction: new

    virtual task body();
        // R/W at Bank 0 end boundary (0x7FFC)
        `uvm_do_with(req, {req.haddr == 32'h7FFC; req.hwrite == 1'b1; req.hsize == 3'b010; req.hwrdata == 32'hDEADBEEF;})
        `uvm_do_with(req, {req.haddr == 32'h7FFC; req.hwrite == 1'b0; req.hsize == 3'b010;})
        // R/W at Bank 1 start boundary (0x8000)
        `uvm_do_with(req, {req.haddr == 32'h8000; req.hwrite == 1'b1; req.hsize == 3'b010; req.hwrdata == 32'hCAFEBABE;})
        `uvm_do_with(req, {req.haddr == 32'h8000; req.hwrite == 1'b0; req.hsize == 3'b010;})
        // R/W at (0x7FFC)
        `uvm_do_with(req, {req.haddr == 32'hFFFC; req.hwrite == 1'b1; req.hsize == 3'b010; req.hwrdata == 32'hCAFEBABE;})
        `uvm_do_with(req, {req.haddr == 32'hFFFC; req.hwrite == 1'b0; req.hsize == 3'b010;})
    endtask 

endclass: seq_bank_boundary

class seq_walking_data extends ahb_base_seq;
    `uvm_object_utils(seq_walking_data)

    function new(string name = "seq_walking_data");
        super.new(name);
    endfunction: new

    virtual task body();
        bit [31:0] data;
        // Walking 1s
        for (int i = 0; i < 32; i++) begin
            data = 32'h1 << i;
            `uvm_do_with(req, {req.haddr == 32'h1000; req.hwrite == 1'b1; req.hsize == 3'b010; req.hwrdata == data;})
            `uvm_do_with(req, {req.haddr == 32'h1000; req.hwrite == 1'b0; req.hsize == 3'b010;})
        end
        // Walking 0s
        for (int i = 0; i < 32; i++) begin
            data = ~(32'h1 << i);
            `uvm_do_with(req, {req.haddr == 32'h1000; req.hwrite == 1'b1; req.hsize == 3'b010; req.hwrdata == data;})
            `uvm_do_with(req, {req.haddr == 32'h1000; req.hwrite == 1'b0; req.hsize == 3'b010;})
        end
    endtask 

endclass: seq_walking_data

class seq_back_to_back extends ahb_base_seq;
    `uvm_object_utils(seq_back_to_back)

    function new(string name = "seq_back_to_back");
        super.new(name);
    endfunction: new

    virtual task body();
        repeat(50) begin
            `uvm_do(req)
        end
    endtask 

endclass: seq_back_to_back

class seq_all_byte_offsets extends ahb_base_seq;
    `uvm_object_utils(seq_all_byte_offsets)

    function new(string name = "seq_all_byte_offsets");
        super.new(name);
    endfunction: new

    virtual task body();
        // Write to offset 0, 1, 2, 3
        `uvm_do_with(req, {req.haddr == 32'h2000; req.hwrite == 1'b1; req.hsize == 3'b000; req.hwrdata == 32'h11;})
        `uvm_do_with(req, {req.haddr == 32'h2001; req.hwrite == 1'b1; req.hsize == 3'b000; req.hwrdata == 32'h22;})
        `uvm_do_with(req, {req.haddr == 32'h2002; req.hwrite == 1'b1; req.hsize == 3'b000; req.hwrdata == 32'h33;})
        `uvm_do_with(req, {req.haddr == 32'h2003; req.hwrite == 1'b1; req.hsize == 3'b000; req.hwrdata == 32'h44;})
        // Read them back
        `uvm_do_with(req, {req.haddr == 32'h2000; req.hwrite == 1'b0; req.hsize == 3'b000;})
        `uvm_do_with(req, {req.haddr == 32'h2001; req.hwrite == 1'b0; req.hsize == 3'b000;})
        `uvm_do_with(req, {req.haddr == 32'h2002; req.hwrite == 1'b0; req.hsize == 3'b000;})
        `uvm_do_with(req, {req.haddr == 32'h2003; req.hwrite == 1'b0; req.hsize == 3'b000;})
    endtask
endclass: seq_all_byte_offsets

class seq_reset_write extends ahb_base_seq; 
    `uvm_object_utils(seq_reset_write)

    function new(string name = "seq_reset_write");
        super.new(name);
    endfunction: new

    virtual task body();
        virtual ahb_if vif;
        if (!uvm_config_db#(virtual ahb_if)::get(null, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not found in seq_reset_write")
        end

        // Wait for initial startup reset to deassert first
        wait(vif.hresetn === 1'b1);
        #10;

        // Assert reset by setting reset_trigger in interface
        vif.reset_trigger = 1'b1;
        // Attempt a write during reset
        `uvm_do_with(req, {req.haddr == 32'h4000; req.hwrite == 1'b1; req.hsize == 3'b010; req.hwrdata == 32'hBAADF00D;})
        #20;
        // Deassert reset
        vif.reset_trigger = 1'b0;
        #10;
        // Drive a read to confirm it was NOT written (should return 0 or old data)
        `uvm_do_with(req, {req.haddr == 32'h4000; req.hwrite == 1'b0; req.hsize == 3'b010;})
    endtask 
endclass: seq_reset_write

class seq_stress_random extends ahb_base_seq;
    `uvm_object_utils(seq_stress_random)

    function new(string name = "seq_stress_random");
        super.new(name);
    endfunction: new

    virtual task body();
        repeat(500) begin
            `uvm_do(req)
        end
    endtask 
endclass