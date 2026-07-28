set_option -use_cpu_as_gpio 1
set_option -synthesis_tool gowinsynthesis
set_option -top_module huffman_top
set_option -verilog_std sysv2017

add_file -type verilog ../src/debouncer.sv
add_file -type verilog ../src/re_detector.sv
add_file -type verilog ../src/huffman_led_modified.sv
add_file -type verilog ../src/demux8.sv
add_file -type verilog ../src/huffman_top.sv
add_file -type sdc ../for_firmware/timing_constraints.sdc
