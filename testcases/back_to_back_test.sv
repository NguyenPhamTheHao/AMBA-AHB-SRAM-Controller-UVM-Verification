class back_to_back_test extends base_test;
    `uvm_component_utils(back_to_back_test)

    function new(string name = "back_to_back_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        seq_back_to_back seq;
        seq = seq_back_to_back::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
