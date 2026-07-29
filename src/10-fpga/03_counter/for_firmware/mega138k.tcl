create_project -name mega138k_counter -pn GW5AST-LV138FPG676AES -device_version B -force

set_option -output_base_name mega138k_counter

add_file -type cst ../for_firmware/mega138k_pin_constraints.cst

set_option -use_cpu_as_gpio 1
set_option -synthesis_tool gowinsynthesis
set_option -top_module counter_top
set_option -verilog_std sysv2017

add_file -type verilog ../../01_huffman_decoder/src/debouncer.sv
add_file -type verilog ../../01_huffman_decoder/src/re_detector.sv
add_file -type verilog ../src/PMOD_DTx2_controller.sv
add_file -type verilog ../src/digits_storer_and_incrementer.sv
add_file -type verilog ../src/demux_digit.sv
add_file -type verilog ../src/counter_top.sv
add_file -type sdc ../for_firmware/timing_constraints.sdc
