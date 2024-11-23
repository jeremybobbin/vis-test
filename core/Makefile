include ../../config.mk

.POSIX:
.SUFFIXES: .o .c .run .a

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

.c.o:
	${CC} ${CFLAGS} -I. -DSTRING_SIZE=4 -DBLOCK_SIZE=4 -c $< -o $@

.o.a:
	${AR} ${ARFLAGS} $@ $?

.a:
	${CC} ${CFLAGS} ${CFLAGS_STD} ${CFLAGS_EXTRA} ${CFLAGS_ACL} ${CFLAGS_SELINUX} \
		$< -o $@ ${LDFLAGS} ${LDFLAGS_STD} ${LDFLAGS_EXTRA} ${LDFLAGS_ACL} ${LDFLAGS_SELINUX}


ccan-config: ccan-config.c

config.h: ccan-config
	@echo Generating ccan configuration header
	./ccan-config "${CC}" ${CFLAGS} > $@ || rm -f $@

ccan/tap/tap.o: config.h

string-test.o: config.h
map-test.o: config.h
array-test.o: config.h
text-test.o: config.h

string-test.a: ../../string.o ccan/tap/tap.o
map-test.a: ../../map.o ccan/tap/tap.o
array-test.a: ../../array.o ccan/tap/tap.o
text-test.a: ccan/tap/tap.o \
	../../array.o \
	../../text.o \
	../../text-common.o \
	../../text-io.o \
	../../text-iterator.o \
	../../text-motions.o \
	../../text-objects.o \
	../../text-regex.o \
	../../text-util.o



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
	@rm -f ccan/tap/tap.o *.o *.a
	@rm -f data symlink hardlink
	@rm -f $(ALL)
	@rm -f *.gcov *.gcda *.gcno
	@rm -f *.valgrind

.PHONY: clean debug coverage tis valgrind asan ubsan msan
