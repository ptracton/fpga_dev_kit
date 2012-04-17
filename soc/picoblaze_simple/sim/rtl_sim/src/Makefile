
TEST_NAME = foobar  ## Must over ride these parameters when building from run_sim.py
TECHNOLOGY = asic
SIMULATOR = icarus


ROOT = ../../../

TESTS = ../../tests/
CC = $(ROOT)/tools/picoasm
CP = /bin/cp -f
RM = /bin/rm -f
TARGET = prog_rom


$(TARGET): 
	$(CP) $(ROOT)/tools/ROM* ../src
	$(CP) $(TESTS)/$(TEST_NAME).psm ../src/prog_rom.psm
	$(CC) -i ../src/prog_rom.psm -d $(TEST_NAME)_$(SIMULATOR)_$(TECHNOLOGY) -t ../src/ROM_form.v
	$(CP) ../src/*.log $(TEST_NAME)_$(SIMULATOR)_$(TECHNOLOGY)/
	$(RM) ../src/ROM* ../src/*.log ../src/*.psm ../src/*~
