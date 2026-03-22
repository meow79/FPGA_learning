#!/bin/bash

error=0
MAKE_GENERAL_OPS="--silent --file=../../Makefile"

echo "----------------------------------------"
echo "2 module test:"

make $MAKE_GENERAL_OPS SOURCES="implication.sv testbenches/implication_tb.sv" TOPMODULE=implication_tb || error=1
make $MAKE_GENERAL_OPS SOURCES="neg_implication.sv testbenches/neg_implication_tb.sv" TOPMODULE=neg_implication_tb || error=1
make $MAKE_GENERAL_OPS SOURCES="peirce_arrow.sv testbenches/peirce_arrow_tb.sv" TOPMODULE=peirce_arrow_tb || error=1
make $MAKE_GENERAL_OPS SOURCES="sheffer_stroke.sv testbenches/sheffer_stroke_tb.sv" TOPMODULE=sheffer_stroke_tb || error=1

exit $error
