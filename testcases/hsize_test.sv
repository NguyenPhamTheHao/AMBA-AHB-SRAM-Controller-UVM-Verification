class hsize_test extends base_test;
    `uvm_component_utils(hsize_test)

    function new(string name = "hsize_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        sequence_hsize seq;
        seq = sequence_hsize::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
