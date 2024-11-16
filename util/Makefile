-include ../../config.mk

keys: keys.c ../../map.o ../../map.h ../../libkey.h ../../ui-terminal-keytab.h ../../util.h
	@echo Compiling keys utility
	$(CC) $(CFLAGS) keys.c ../../libkey.o ../../map.o $(LDFLAGS) -o keys

clean:
	@echo cleaning
	@rm -f keys

.PHONY: clean
