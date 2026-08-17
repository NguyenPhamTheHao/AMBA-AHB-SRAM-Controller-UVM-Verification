class ahb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ahb_scoreboard)

    uvm_analysis_imp #(ahb_transaction, ahb_scoreboard) item_collected_imp;
    
    // Internal Memory Model for Checking
    logic [7:0] ref_mem [0:65535];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_imp = new("item_collected_imp", this);
        foreach (ref_mem[i]) ref_mem[i] = 8'h00;
    endfunction

    virtual function void write(ahb_transaction tr);
        if (tr.hwrite) begin
            case (tr.hsize)
                3'b000: begin // 8-bit 
                    case(tr.haddr[1:0]) 
                        2'b00: ref_mem[tr.haddr[15:0]] = tr.hwrdata[7:0];
                        2'b01: ref_mem[tr.haddr[15:0]] = tr.hwrdata[15:8];
                        2'b10: ref_mem[tr.haddr[15:0]] = tr.hwrdata[23:16];
                        2'b11: ref_mem[tr.haddr[15:0]] = tr.hwrdata[31:24];
                    endcase
                end
                3'b001: begin // 16-bit
                    case(tr.haddr[1])
                        1'b0: begin
                            ref_mem[{tr.haddr[15:1], 1'b0}] = tr.hwrdata[7:0];
                            ref_mem[{tr.haddr[15:1], 1'b1}] = tr.hwrdata[15:8];
                        end
                        1'b1: begin
                            ref_mem[{tr.haddr[15:1], 1'b0}] = tr.hwrdata[23:16];
                            ref_mem[{tr.haddr[15:1], 1'b1}] = tr.hwrdata[31:24];
                        end
                    endcase
                end
                3'b010: begin // 32-bit
                    ref_mem[{tr.haddr[15:2], 2'b00}] = tr.hwrdata[7:0];
                    ref_mem[{tr.haddr[15:2], 2'b01}] = tr.hwrdata[15:8];
                    ref_mem[{tr.haddr[15:2], 2'b10}] = tr.hwrdata[23:16];
                    ref_mem[{tr.haddr[15:2], 2'b11}] = tr.hwrdata[31:24];
                end
            endcase
            `uvm_info("SCB_WRITE", $sformatf("Addr: 0x%0h | Data: 0x%0h | Size: %0d", tr.haddr, tr.hwrdata, tr.hsize), UVM_MEDIUM)
        end else begin
            // Check read data
            logic [31:0] expected_data;
            expected_data = {ref_mem[{tr.haddr[15:2], 2'b11}], ref_mem[{tr.haddr[15:2], 2'b10}], ref_mem[{tr.haddr[15:2], 2'b01}], ref_mem[{tr.haddr[15:2], 2'b00}]};
            if (tr.hsize == 3'b000) begin
                logic [7:0] actual_byte = (tr.hrdata >> (8 * tr.haddr[1:0])) & 8'hFF;
                if (actual_byte !== ref_mem[tr.haddr[15:0]])
                    `uvm_error("SCB_MISMATCH", $sformatf("Addr: 0x%0h | Expected Byte: 0x%0h | Actual Byte: 0x%0h", tr.haddr, ref_mem[tr.haddr[15:0]], actual_byte))
                else
                    `uvm_info("SCB_MATCH", $sformatf("Addr: 0x%0h | Data: 0x%0h (Byte Match)", tr.haddr, actual_byte), UVM_MEDIUM)
            end  
            else if (tr.hsize == 3'b001) begin
                logic [15:0] actual_half = (tr.hrdata >> (16 * tr.haddr[1])) &  16'hFFFF;
                logic [15:0] exp_half = {ref_mem[{tr.haddr[15:1], 1'b1}], ref_mem[{tr.haddr[15:1], 1'b0}]};
                if (actual_half !== exp_half)
                    `uvm_error("SCB_MISMATCH", $sformatf("Addr: 0x%0h | Expected Half: 0x%0h | Actual Half: 0x%0h", tr.haddr, exp_half, actual_half))
                 else
                    `uvm_info("SCB_MATCH", $sformatf("Addr: 0x%0h | Data: 0x%0h (Half Match)", tr.haddr, actual_half), UVM_MEDIUM)
            end 
            if (tr.hrdata !== expected_data)
                    `uvm_error("SCB_MISMATCH", $sformatf("Addr: 0x%0h | Expected: 0x%0h | Actual: 0x%0h", tr.haddr, expected_data, tr.hrdata))
                else
                    `uvm_info("SCB_MATCH", $sformatf("Addr: 0x%0h | Data: 0x%0h", tr.haddr, tr.hrdata), UVM_MEDIUM)
        end
    endfunction
endclass