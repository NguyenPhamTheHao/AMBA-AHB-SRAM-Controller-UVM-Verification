class ahb_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_monitor)

    virtual ahb_if vif;
    uvm_analysis_port#(ahb_transaction) item_collected_port;

    function new(string name= "ahb_monitor", uvm_component parent);
        super.new(name,parent);
         item_collected_port=new("item_collected_port",this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ahb_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not found")
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
        tr.hwrite=write;
        tr.hsize=size;

        if(write) begin
            tr.hwrdata = vif.hwrdata;
        end
        else begin
            @(vif.cb);
            tr.hrdata=vif.cb.hrdata;
        end
        item_collected_port.write(tr);
    endtask
endclass