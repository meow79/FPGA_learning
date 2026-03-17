IVERILOG ?= iverilog
VVP ?= vvp
YOSYS = yosys
NPX = npx

SOURCES = implication.sv testbenches/implication_tb.sv
TOPMODULE = implication_tb
FLAGS = -g2012

.PHONY: all
all: test

build: $(SOURCES)
	mkdir -p build
	$(IVERILOG) -s $(TOPMODULE) $^ $(FLAGS) -o build/$(TOPMODULE)

test: build
	$(VVP) build/$(TOPMODULE)

clean:
	rm -r build

circuit:
	mkdir -p build
	$(YOSYS) -p "prep -top $(TOPMODULE); write_json build/$(TOPMODULE).json" $(SOURCES)
	$(NPX) netlistsvg build/$(TOPMODULE).json -o build/$(TOPMODULE).svg

.PHONY: test
.PHONY: build
.PHONY: clean
