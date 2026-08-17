class stress_random_test extends base_test;
    `uvm_component_utils(stress_random_test)

    function new(string name = "stress_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        seq_stress_random seq;
        seq = seq_stress_random::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
