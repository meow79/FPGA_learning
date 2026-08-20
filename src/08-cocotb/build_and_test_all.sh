#!/bin/bash

error=0
MAKE_GENERAL_OPS="--silent"
COL="\033[1;34m" # Bold blue
COL_OFF="\033[0m"

export COCOTB_ANSI_OUTPUT=1

echo "----------------------------------------"
echo "7 module test:"

cd 01_merge_parallel_test
printf "\n${COL}merge_parallel module test...${COL_OFF}"
make $MAKE_GENERAL_OPS || error=1

cd ../02_serial_adder_test
printf "\n${COL}serial_1bit_adder module test...${COL_OFF}"
make $MAKE_GENERAL_OPS || error=1

cd ../03_pairwise_test
printf "\n${COL}pairwise module test...${COL_OFF}"
make $MAKE_GENERAL_OPS || error=1

cd ../04_windowed_test
printf "\n${COL}windowed module test...${COL_OFF}"
make $MAKE_GENERAL_OPS || error=1

cd ../05_convolution_1d_test
printf "\n${COL}convolution_1d module test...${COL_OFF}"
python3 -u convolution_1d_test.py 2>&1 | grep -v sorry
if [ ${PIPESTATUS[0]} -ne 0 ]; then
        error=1
fi

cd ../convolution_2d
printf "\n${COL}сonvolution_2d module test...${COL_OFF}"
python3 -u convolution_2d_test.py 2>&1 | grep -v "sorry"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
        error=1
fi

exit $error
