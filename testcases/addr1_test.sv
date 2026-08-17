class addr1_test extends base_test;
    `uvm_component_utils(addr1_test)

    function new(string name = "addr1_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        sequence_addr1 seq;
        seq = sequence_addr1::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
