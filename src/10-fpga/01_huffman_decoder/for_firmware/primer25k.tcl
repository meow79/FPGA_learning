create_project -name primer25k_huffman_modified -pn GW5A-LV25MG121NES -device_version A -force
set_option -output_base_name primer25k_huffman_modified
add_file -type cst ../for_firmware/primer25k_pin_constraints.cst
source ../for_firmware/common.tcl
