class addr0_test extends base_test;
    `uvm_component_utils(addr0_test)

    function new(string name = "addr0_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        sequence_addr0 seq;
        seq = sequence_addr0::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
