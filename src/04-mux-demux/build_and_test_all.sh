#!/bin/bash

error=0
MAKE_GENERAL_OPS="--silent --file=../Makefile"

echo "----------------------------------------"
echo "4 module test:"

make $MAKE_GENERAL_OPS SOURCES="01_mux_4to1_logic/mux_4to1_tb.sv  01_mux_4to1_logic/mux_4to1_logic.sv" TOPMODULE=mux_4to1_tb || error=1
make $MAKE_GENERAL_OPS SOURCES="mux_2to1.sv 04_ternary_relation/solution.sv 04_ternary_relation/solution_tb.sv" TOPMODULE=solution_tb || error=1

exit $error
