##################################################################################################
# Project: AHB SRAM Controller UVM Verification - TCL Script for QuestaSim/ModelSim
# Execution: Load script with 'do run.do' or 'source run.do'
##################################################################################################

set TEST_LIST { \
    base_test \
    all_sizes_test \
    bank_boundary_test \
    walking_data_test \
    back_to_back_test \
    all_byte_offsets_test \
    reset_write_test \
    stress_random_test \
}

proc clean {} {
    if {[file exists work]} { file delete -force work }
    if {[file exists log]}  { file delete -force log }
    if {[file exists coverage]} { file delete -force coverage }
    foreach f [glob -nocomplain *.log *.wlf *.ucdb transcript compile.log] {
        file delete -force $f
    }
    puts "\[INFO\] Cleaned all build, simulation logs, and coverage files."
}

proc build {} {
    if {![file exists log]} { file mkdir log }
    if {![file exists work]} { 
        vlib work 
        vmap work work
    }
    puts "\[INFO\] Compiling RTL with Coverage and UVM Testbench..."
    if {[catch {
        vlog -coveropt 3 +cover=bcestf -sv -f rtl.f
        vlog -coveropt 3 -sv -f tb.f
    } err]} {
        puts "\[ERROR\] Compilation Failed: $err"
    } else {
        puts "\[INFO\] Compilation Successful!"
    }
}

proc run_test {{test_name "base_test"} {seed "1"}} {
    if {![file exists log]} { file mkdir log }

    puts "=========================================================================="
    puts "\[INFO\] Running UVM Testcase: $test_name | Seed: $seed"
    puts "=========================================================================="
    set cmd "vsim -sv_seed $seed -coverage -coveranalysis -debugDB -l log/${test_name}_${seed}.log -voptargs=+acc -assertdebug -c top -do \"coverage save -codeAll -cvg -onexit ${test_name}.ucdb; log -r /*; run -all; exit\" +UVM_TESTNAME=${test_name}"
    
    eval $cmd
    
    if {[file exists log/${test_name}_${seed}.log]} {
        file copy -force log/${test_name}_${seed}.log run.log
    }
    puts "\[INFO\] Test execution finished. Log file: log/${test_name}_${seed}.log"
}

proc run_gui {{test_name "base_test"} {seed "1"}} {
    build
    puts "=========================================================================="
    puts "\[INFO\] Running GUI UVM Testcase: $test_name | Seed: $seed"
    puts "=========================================================================="
    
    vsim -sv_seed $seed -coverage -coveranalysis -debugDB -l log/${test_name}_${seed}.log -voptargs="+acc" -assertdebug top +UVM_TESTNAME=${test_name}
    
    add wave -r /top/*
    radix -hex
    run -all
}

proc run_all {} {
    global TEST_LIST
    build
    puts "\n=========================================================================="
    puts "                      STARTING REGRESSION RUN ALL                          "
    puts "=========================================================================="
    foreach t $TEST_LIST {
        puts "\n>>>> Running: $t <<<<"
        run_test $t 1
    }
    puts "\n=========================================================================="
    puts "                      ALL TESTS COMPLETED SUCCESSFULLY                      "
    puts "=========================================================================="
}

proc wave {} {
    if {[file exists vsim.wlf]} {
        dataset open vsim.wlf sim_wave
        add wave -r sim_wave:/top/*
        radix -hex
        puts "\[INFO\] Loaded waveform successfully."
    } else {
        puts "\[ERROR\] vsim.wlf not found! Please run a test first."
    }
}

proc gen_cov {} {
    if {![file exists coverage]} { file mkdir coverage }
    set ucdb_files [glob -nocomplain *.ucdb]
    
    if {[llength $ucdb_files] == 0} {
        puts "\[ERROR\] No .ucdb files found! Please run tests first."
        return
    }
    
    puts "\[INFO\] Merging UCDB files..."
    eval vcover merge IP.ucdb $ucdb_files
    
    puts "\[INFO\] Generating Summary Text Report..."
    vcover report -code bcesft -cvg IP.ucdb -output coverage/summary_report.txt

    puts "\[INFO\] Generating Detailed Code & Functional Coverage Report..."
    vcover report -zeros -details -code bcesft -cvg IP.ucdb -output coverage/detail_report.txt

    puts "\[INFO\] Generating Dedicated Functional Coverage Report..."
    vcover report -cvg -details IP.ucdb -output coverage/functional_coverage.txt
}

proc gen_html {} {
    if {![file exists coverage]} { file mkdir coverage }
    set ucdb_files [glob -nocomplain *.ucdb]
    
    if {[llength $ucdb_files] == 0} {
        puts "\[ERROR\] No .ucdb files found! Please run tests first."
        return
    }
    
    puts "\[INFO\] Merging UCDB files..."
    eval vcover merge IP.ucdb $ucdb_files
    
    puts "\[INFO\] Generating HTML Report..."
    vcover report -html -htmldir coverage/html_report -code bcesft -cvg -details -testhitdataAll IP.ucdb
    puts "\[INFO\] Done! Open 'coverage/html_report/index.html' in browser."
}

proc help {} {
    puts "=========================================================================="
    puts "                   AHB SRAM UVM TCL SCRIPT HELP                           "
    puts "=========================================================================="
    puts "  build                  : Compile all SV files listed in rtl.f and tb.f"
    puts "  run_test <test_name>   : Run a UVM testcase in background mode"
    puts "  run_gui <test_name>    : Run UVM testcase in GUI mode with full Wave"
    puts "  run_all                : Build and run ALL testcases sequentially"
    puts "  wave                   : Open wave viewer from saved vsim.wlf"
    puts "  gen_cov                : Merge .ucdb files & generate RTL Text Coverage"
    puts "  gen_html               : Merge .ucdb files & generate RTL HTML Coverage"
    puts "  clean                  : Delete compiled libraries, logs, and coverage"
    puts "  help                   : Display this help menu"
    puts "=========================================================================="
}