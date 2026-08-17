class low_power_test extends base_test;
    `uvm_component_utils(low_power_test)

    function new(string name = "low_power_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        sequence_addr2 seq;
        seq = sequence_addr2::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
