-include ../../config.mk

keys: keys.c ../../map.o ../../map.h ../../libkey.h ../../ui-terminal-keytab.h ../../util.h
	@echo Compiling keys utility
	$(CC) $(CFLAGS) $(CFLAGS_STD) $(CFLAGS_EXTRA) \
		keys.c ../../libkey.o ../../map.o \
		$(LDFLAGS) $(LDFLAGS_STD) $(LDFLAGS_EXTRA) -o keys

debug: keys.c ../../map.o ../../map.h ../../libkey.h ../../ui-terminal-keytab.h ../../util.h
	$(CC) $(CFLAGS) $(CFLAGS_STD) $(CFLAGS_EXTRA) $(CFLAGS_DEBUG) \
		keys.c ../../libkey.o ../../map.o \
		$(LDFLAGS) $(LDFLAGS_STD) $(LDFLAGS_EXTRA) -o keys

clean:
	@echo cleaning
	@rm -f keys

.PHONY: clean
