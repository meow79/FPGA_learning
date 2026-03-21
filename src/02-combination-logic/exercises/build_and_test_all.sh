#!/bin/bash

error=0

make SOURCES="implication.sv testbenches/implication_tb.sv" TOPMODULE=implication_tb || error=1
make SOURCES="neg_implication.sv testbenches/neg_implication_tb.sv" TOPMODULE=neg_implication_tb || error=1
make SOURCES="peirce_arrow.sv testbenches/peirce_arrow_tb.sv" TOPMODULE=peirce_arrow_tb || error=1
make SOURCES="sheffer_stroke.sv testbenches/sheffer_stroke_tb.sv" TOPMODULE=sheffer_stroke_tb || error=1

exit $error
