
TEST_NAME = echo


ROOT = ../../../

TESTS = ../../tests/
CC = $(ROOT)/tools/picoasm
CP = /bin/cp -f
RM = /bin/rm -f
TARGET = prog_rom


$(TARGET): 
	$(CP) $(ROOT)/tools/ROM* .
	$(CP) $(TEST_NAME).psm prog_rom.psm
	$(CC) -i prog_rom.psm -d . -t ROM_form.v
	$(RM) ROM* *.log *~

clean:
	$(RM) ROM* *.log *~