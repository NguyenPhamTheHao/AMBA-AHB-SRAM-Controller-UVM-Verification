package test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ahb_agents_pkg::*;
    import ahb_seq_pkg::*;
    import ahb_env_pkg::*;

    `include "base_test.sv"
    `include "addr0_test.sv"
    `include "addr1_test.sv"
    `include "hsize_test.sv"
    `include "low_power_test.sv"
    `include "all_sizes_test.sv"
    `include "bank_boundary_test.sv"
    `include "walking_data_test.sv"
    `include "back_to_back_test.sv"
    `include "all_byte_offsets_test.sv"
    `include "reset_write_test.sv"
    `include "stress_random_test.sv"

endpackage
