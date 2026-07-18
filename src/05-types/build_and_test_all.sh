#!/bin/bash

error=0
MAKE_GENERAL_OPS="--silent --file=../Makefile"

echo "----------------------------------------"
echo "5 module test:"

make $MAKE_GENERAL_OPS SOURCES="01_byte_mult_double/byte_mult_double.sv 01_byte_mult_double/byte_mult_double_tb.sv" TOPMODULE=byte_mult_double_tb || error=1
make $MAKE_GENERAL_OPS SOURCES="03_float_mult_byte_extended/float_mult_byte.sv 03_float_mult_byte_extended/float_mult_byte_tb.sv" TOPMODULE=float_mult_byte_tb 2>&1 | grep -v "sorry"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
        error=1
fi
make $MAKE_GENERAL_OPS SOURCES="04_scalar_product/scalar_product_float_to_byte.sv 04_scalar_product/scalar_product_float_to_byte_tb.sv 03_float_mult_byte_extended/float_mult_byte.sv" TOPMODULE=scalar_product_float_to_byte_tb 2>&1 | grep -v "sorry"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
        error=1
fi

exit $error
