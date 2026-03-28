#!/bin/bash

error=0
MAKE_GENERAL_OPS="--silent --file=../Makefile"

PEIRCE_ARROW_PATH=../02-combination-logic/exercises/peirce_arrow.sv
SHEFFER_STROKE_PATH=../02-combination-logic/exercises/sheffer_stroke.sv

echo "----------------------------------------"
echo "3 module test:"

echo "Peirce arrow operations test:"
make $MAKE_GENERAL_OPS SOURCES="tests_for_01_and_02_tasks/conjunction_tb.sv ./01_peirce_arrow_operations/conjunction.sv  $PEIRCE_ARROW_PATH" TOPMODULE=conjunction_tb || error=1
make $MAKE_GENERAL_OPS SOURCES="tests_for_01_and_02_tasks/disjunction_tb.sv ./01_peirce_arrow_operations/disjunction.sv  $PEIRCE_ARROW_PATH" TOPMODULE=disjunction_tb || error=1
make $MAKE_GENERAL_OPS  SOURCES="tests_for_01_and_02_tasks/implication_tb.sv ./01_peirce_arrow_operations/implication.sv  $PEIRCE_ARROW_PATH" TOPMODULE=implication_tb || error=1

echo -e "\nSheffer stroke operations test:"
make $MAKE_GENERAL_OPS SOURCES="tests_for_01_and_02_tasks/conjunction_tb.sv ./02_sheffer_stroke_operations/conjunction.sv  $SHEFFER_STROKE_PATH" TOPMODULE=conjunction_tb || error=1
make $MAKE_GENERAL_OPS SOURCES="tests_for_01_and_02_tasks/disjunction_tb.sv ./02_sheffer_stroke_operations/disjunction.sv  $SHEFFER_STROKE_PATH" TOPMODULE=disjunction_tb || error=1
make $MAKE_GENERAL_OPS  SOURCES="tests_for_01_and_02_tasks/implication_tb.sv ./02_sheffer_stroke_operations/implication.sv  $SHEFFER_STROKE_PATH" TOPMODULE=implication_tb || error=1

exit $error
