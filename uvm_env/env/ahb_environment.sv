class sram_env extends uvm_env;
        `uvm_component_utils(sram_env)

        ahb_agent       agent;
        sram_scoreboard scoreboard;
        ahb_sram_coverage coverage;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = ahb_agent::type_id::create("agent", this);
            scoreboard = sram_scoreboard::type_id::create("scoreboard", this);
            coverage = ahb_sram_coverage::type_id::create("coverage", this);
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            agent.monitor.item_collected_port.connect(scoreboard.item_collected_imp);
            agent.monitor.item_collected_port.connect(coverage.analysis_export);
        endfunction
endclass