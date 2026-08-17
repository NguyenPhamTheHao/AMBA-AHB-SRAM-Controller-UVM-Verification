class ahb_driver extends uvm_driver #(ahb_transaction);
    `uvm_component_utils(ahb_driver)

    virtual ahb_if vif;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual ahb_if)::get(this,"","vif",vif))
            `uvm_fatal("NO_VIF","Virtual interface not found")
    endfunction

    virtual task run_phase(uvm_phase phase);
        vif.cb.hsel    <= 1'b0;
        vif.cb.htrans  <= 2'b00; 
        vif.cb.hwrite  <= 1'b0;
        vif.cb.hsize   <= 3'b000;
        wait(vif.hresetn==1'b1);
        @(vif.cb);
        forever begin  
            seq_item_port.get_next_item(req);
            driver_transaction(req);
            seq_item_port.item_done();
        end
    endtask

    task driver_transaction(ahb_transaction tr);
        //Address phase
        @(vif.cb);
        vif.cb.haddr <= tr.haddr;
        vif.cb.hwrite <=tr.hwrite;
        vif.cb.hsize <= tr.hsize;
        vif.cb.htrans <= 2'b10; //NONSEQ
        vif.cb.hsel  <=1'b1;

        if(tr.hwrite) begin
            //Data phase : Present write data
            @(vif.cb);
            vif.cb.hwrdata <= tr.hwrdata;
            vif.cb.hsel <= 1'b0;
            vif.cb.htrans <=2'b00; //IDLE
        end
        else begin
            @(vif.cb);
            vif.cb.hsel <=1'b0;
            vif.cb.htrans <=2'b00;
            @(vif.cb);
            tr.hrdata =vif.cb.hrdata;
        end
    endtask
endclass