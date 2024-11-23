include ../../config.mk

.POSIX:
.SUFFIXES: .o .c .run

ALL = string-test map-test array-test text-test

test: test-string test-map test-array test-text

test-string: string-test
	@./string-test
test-map: map-test
	@./map-test
test-array: array-test
	@./array-test
test-text: text-test
	@./text-test

.o:
	${CC} ${CFLAGS} ${CFLAGS_STD} ${CFLAGS_EXTRA} ${LDFLAGS} ${LDFLAGS_ACL} $? -o $@

.c.o:
	${CC} ${CFLAGS} -I. -DSTRING_SIZE=4 -DBLOCK_SIZE=4 -c $< -o $@


ccan-config: ccan-config.c

config.h: ccan-config
	@echo Generating ccan configuration header
	./ccan-config "${CC}" ${CFLAGS} > $@ || rm -f $@

ccan/tap/tap.o: ccan/tap/tap.h config.h

string-test: ../../string.o ccan/tap/tap.o
string-test.o: config.h

map-test: ../../map.o ccan/tap/tap.o
map-test.o: config.h

array-test:  ../../array.o ccan/tap/tap.o
array-test.o: config.h

text-test: ../../array.o ccan/tap/tap.o \
	../../text.o \
	../../text-common.o \
	../../text-io.o \
	../../text-iterator.o \
	../../text-motions.o \
	../../text-objects.o \
	../../text-regex.o \
	../../text-util.o
text-test.o: config.h


debug: clean
	$(MAKE) CFLAGS_EXTRA='${CFLAGS_EXTRA} ${CFLAGS_DEBUG}'

coverage: clean
	$(MAKE) CFLAGS_EXTRA='--coverage'

asan: clean
	$(MAKE) CFLAGS_EXTRA='-fsanitize=address'

ubsan: clean
	$(MAKE) CFLAGS_EXTRA='-fsanitize=undefined'

msan: clean
	$(MAKE) CFLAGS_EXTRA='-fsanitize=memory -fsanitize-memory-track-origins'

valgrind: clean ${ALL}
	@for test in ${ALL}; do \
		valgrind --leak-check=full --log-file="$$test.valgrind" "./$$test"; \
		cat "$$test.valgrind"; \
		if grep -q LEAK "$$test.valgrind" then exit 1; fi; \
	done

tis: clean
	$(MAKE) CC="tis-interpreter.sh --cc" CFLAGS='"${CFLAGS} ${CFLAGS_STD} -DHAVE_MEMRCHR=0 -DTIS_INTERPRETER=1"' CFLAGS_STD='' CFLAGS_LIBC='' LDFLAGS='#' $(ALL)

clean:
	@echo cleaning
	@rm -f configuratortest.c configurator.out ccan-config
	@rm -f ccan/tap/tap.o *.o
	@rm -f data symlink hardlink
	@rm -f $(ALL)
	@rm -f *.gcov *.gcda *.gcno
	@rm -f *.valgrind

.PHONY: clean debug coverage tis valgrind asan ubsan msan
