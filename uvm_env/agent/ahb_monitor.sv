class ahb_monitor extends uvm_monitor #(ahb_transaction);
    `uvm_component_utils(ahb_monitor)

    virtual ahb_if vif;
    uvm_analysis_port#(ahb_transaction) item_collected_port;

    function new(string name= "ahb_monitor", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_collected_port=new("item_collected_port",this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(vif.cb);
            if(vif.hsel && (vif.htrans==2'b10 || vif.htrans==2'b11)) begin
                fork
                    capture_data_phase(vif.haddr, vif.hwrite, vif.hsize);
                join_none
            end
        end
    endtask

    task capture_data_phase(bit [31:0] addr, bit write, bit [2:0] size);
        ahb_transaction tr;
        @(vif.cb);
        tr=ahb_transaction::type_id::create("tr");
        tr.haddr=addr;
        tr.write=write;
        tr.hsize=size;

        if(write) begin
            tr.hwrdata = vif.hwdata;
        end
        else begin
            @(vif.cb);
            tr.hrdata=vif.cb.hrdata;
        end
        `LP_CHECK(vif.cb.bank_sel==2'b10 ? 1 :0),vif.cb.sram_ce);
        item_collected_port.write(tr);
    endtask
endclass