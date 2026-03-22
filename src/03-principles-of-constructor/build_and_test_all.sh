#!/bin/bash

error=0
MAKE_GENERAL_OPS="--silent --file=../Makefile"

echo "----------------------------------------"
echo "3 module test:"
make $MAKE_GENERAL_OPS SOURCES="./01_peirce_arrow_operations/testbenches/conjunction_tb.sv ./01_peirce_arrow_operations/conjunction.sv  ../02-combination-logic/exercises/peirce_arrow.sv" TOPMODULE=conjunction_tb || error=1
make $MAKE_GENERAL_OPS SOURCES="./01_peirce_arrow_operations/testbenches/disjunction_tb.sv ./01_peirce_arrow_operations/disjunction.sv  ../02-combination-logic/exercises/peirce_arrow.sv" TOPMODULE=disjunction_tb || error=1
make $MAKE_GENERAL_OPS  SOURCES="./01_peirce_arrow_operations/testbenches/implication_tb.sv ./01_peirce_arrow_operations/implication.sv  ../02-combination-logic/exercises/peirce_arrow.sv" TOPMODULE=implication_tb || error=1

exit $error
