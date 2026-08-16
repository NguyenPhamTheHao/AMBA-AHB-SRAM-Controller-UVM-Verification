class ahb_agent extends uvm_agent;
    `uvm_component_tils(ahb_agent)

    ahb_sequencer sequencer;
    ahb_driver driver;
    ahb_monitor monitor;

    function new(string name ="ahb_agent",uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual void function build_phase(uvm_phase phase);
        monitor = ahb_monitor::type_id::create("monitor",this);
        if(get_is_active() ==UVM_ACTIVE) begin
            driver = ahb_driver::type_id::create("driver",this);
            sequencer = ahb_sequencer::type_id::create("sequencer",this);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        if(get_is_active()==UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
endclass