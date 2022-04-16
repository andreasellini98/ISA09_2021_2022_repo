
SHELL = /bin/bash -o pipefail

USING_DEFAULT_MODULE :=
ifndef MODULE
	MODULE := ADDER
	USING_DEFAULT_MODULE := " Using default module = 32-bit Adder"
endif

RUNLOGDIR := ../logs/$(MODULE)

SV_OPTS :=
BUILTOPTS :=
QUESTA_CMD :=
COMPILE_DESIGN :=
ifeq ($(strip $(MODULE)),ADDER)
	QUESTA_CMD := vlog
	SV_OPTS := -sv
	BUILDOPTS := +define+ADDER
	ifndef 64bit 
		COMPILE_DESIGN := ../src/32-bit_ADDER/adder.sv
	else
		COMPILE_DESIGN := ../src/64-bit_ADDER/adder.sv
		BUILDOPTS += +define+LONG
		RUNLOGDIR := ../logs/$(MODULE)_64
	endif
endif

ifeq ($(strip $(MODULE)),DADDA)
	QUESTA_CMD := vcom
	BUILDOPTS := +define+DADDA
	COMPILE_DESIGN := -f dadda.vc
endif

ifeq ($(strip $(MODULE)),FPMULT)
	QUESTA_CMD := vcom
	BUILDOPTS := +define+FPMULT
	ifdef LATENCY
		BUILDOPTS += +define+LATENCY=$(LATENCY)
	endif
	COMPILE_DESIGN := -f fpmult.vc
endif

ifeq ($(strip $(TESTBADREF)),yes)
	BUILDOPTS += +define+MISCOMPARE
endif

RUNLOG := | tee $(RUNLOGDIR)/run_$(MODULE).log

COMPILE += vlib work || exit 1;
COMPILE += $(QUESTA_CMD) $(SV_OPT) $(COMPILE_DESIGN) $(BUILDOPTS) -64 +acc=blnr || exit 1; 
COMPILE += vlog -sv ../tb/top.sv +acc=blnr $(BUILDOPTS) -64 || exit 1
RUN	+= vsim top $(BUILDOPTS) -64 -batch -do "run -all; quit -f" $(RUNLOG) || exit 1


.DEFAULT_GOAL := help


.PHONY: help run clean


help:
	@echo "###########################"; \
	echo "This is the Makefile to run the UVM environment"; \
	echo "make or make help shows this extra info"; \
	echo ""; \
	echo "make target [options]"; \
	echo "target is one of:"; \
	echo "run	: run the UVM test"; \
	echo "clean 	: remove the working library"; \
	echo "help	: shows this message"; \
	echo "----------------------------"; \
	echo "options can be: "; \
	echo "MODULE		: specifiy the module to be tested"; \
	echo "		  	  FPMULT: 32-bit floating point multiplier"; \
	echo "			  DADDA: 32-bit unsigned multiplier"; \
	echo " 			  ADDER: 32/64-bit adder."; \
	echo "64bit=yes 	: choose the 64-bit adder version."; \
	echo "LATENCY		: used with fpmult (default = 6), change if the dut has a different latency"; \
	echo "TESTBADREF=yes 	: choose to select a wrong reference model,"; \
	echo "----------------------------"; \


run: 
	@echo "Running UVM $(USING_DEFAULT_MODULE)"
	@mkdir -p $(RUNLOGDIR)
	@$(COMPILE)
	@$(RUN)

clean:
	rm -rf ./work
	rm ./vsim*
	rm transcript

 
