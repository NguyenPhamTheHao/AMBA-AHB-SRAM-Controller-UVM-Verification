class all_sizes_test extends base_test;
    `uvm_component_utils(all_sizes_test)

    function new(string name = "all_sizes_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        seq_all_sizes seq;
        seq = seq_all_sizes::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
