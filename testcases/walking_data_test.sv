//Description: Test class for seq_walking_data
class walking_data_test extends base_test;
    `uvm_component_utils(walking_data_test)

    function new(string name = "walking_data_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        seq_walking_data seq;
        seq = seq_walking_data::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
