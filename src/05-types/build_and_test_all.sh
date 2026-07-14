#!/bin/bash

error=0
MAKE_GENERAL_OPS="--silent --file=../Makefile"

echo "----------------------------------------"
echo "5 module test:"

make $MAKE_GENERAL_OPS SOURCES="01_byte_mult_double/byte_mult_double.sv 01_byte_mult_double/byte_mult_double_tb.sv" TOPMODULE=byte_mult_double_tb || error=1

exit $error
