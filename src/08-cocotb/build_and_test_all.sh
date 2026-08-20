#!/bin/bash

error=0
MAKE_GENERAL_OPS="--silent"
COL="\033[1;34m" # Bold blue
COL_OFF="\033[0m"

echo "----------------------------------------"
echo "7 module test:"

cd 01_merge_parallel_test
echo -e "${COL}\nmerge_parallel module test...${COL_OFF}"
make $MAKE_GENERAL_OPS || error=1

cd ../02_serial_adder_test
echo -e "${COL}\nserial_1bit_adder module test...${COL_OFF}"
make $MAKE_GENERAL_OPS || error=1

cd ../03_pairwise_test
echo -e "${COL}\npairwise module test...${COL_OFF}"
make $MAKE_GENERAL_OPS || error=1

cd ../04_windowed_test
echo -e "${COL}\nwindowed module test...${COL_OFF}"
make $MAKE_GENERAL_OPS || error=1

cd ../05_convolution_1d_test
echo -e "${COL}\nconvolution_1d module test...${COL_OFF}"
COCOTB_ANSI_OUTPUT=1 python3 -u convolution_1d_test.py 2>&1 | grep -v sorry
if [ ${PIPESTATUS[0]} -ne 0 ]; then
        error=1
fi

cd ../convolution_2d
echo -e "${COL}\nconvolution_2d module test...${COL_OFF}"
COCOTB_ANSI_OUTPUT=1 python3 -u convolution_2d_test.py 2>&1 | grep -v "sorry"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
        error=1
fi

exit $error
