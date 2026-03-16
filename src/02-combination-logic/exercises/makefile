IVERILOG ?= iverilog
SOURCES = implication.sv testbenches/implication_tb.sv
TOPMODULE = implication_tb
FLAGS = -g2012

.PHONY: all
all: test

.PHONY: build
build: $(SOURCES)
	mkdir -p build
	$(IVERILOG) -s $(TOPMODULE) $^ $(FLAGS) -o build/$(TOPMODULE)

.PHONY: test
test: build
	build/$(TOPMODULE)

.PHONY: clean
clean:
	rm -r build
