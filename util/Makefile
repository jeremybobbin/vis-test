-include ../../config.mk

keys: keys.c ../../map.o ../../map.h ../../libkey.h ../../ui-terminal-keytab.h ../../util.h
	@echo Compiling keys utility
	$(CC) $(CFLAGS) $(CFLAGS_EXTRA) keys.c ../../libkey.o ../../map.o $(LDFLAGS) $(LDFLAGS_EXRA) -o keys

clean:
	@echo cleaning
	@rm -f keys

.PHONY: clean
