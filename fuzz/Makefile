-include ../../config.mk

ALL = text-fuzzer string-fuzzer
CC = afl-clang-fast

TEXT_OBJ = ../../text.o ../../text-common.o ../../text-io.o ../../text-iterator.o ../../text-util.o ../../text-motions.o ../../text-objects.o ../../text-regex.o ../../array.o

.o:
	${CC} ${CFLAGS} ${CFLAGS_STD} ${CFLAGS_LIBC} ${CFLAGS_EXTRA} ${LDFLAGS} ${LDFLAGS_ACL} $? -o $@

.c.o:
	${CC} ${CFLAGS} ${CFLAGS_LIBC} ${CFLAGS_EXTRA} -I. -DSTRING_SIZE=4 -DBLOCK_SIZE=4 -c $< -o $@


test: $(ALL)

text-fuzzer: $(TEXT_OBJ)
text-fuzzer.o: text-fuzzer.c fuzzer.h

string-fuzzer: ../../string.o
string-fuzzer.o: string-fuzzer.c fuzzer.h

debug: clean
	$(MAKE) CFLAGS_EXTRA='${CFLAGS_EXTRA} ${CFLAGS_DEBUG}'

afl-fuzz-text: text-fuzzer
	@mkdir -p "results/$<"
	@afl-fuzz -i - -x "dictionaries/$<.dict" -o "results/$<" -- "./$<" || \
	 afl-fuzz -i "inputs/$<" -x "dictionaries/$<.dict" -o "results/$<" -- "./$<"

libfuzzer-text: text-libfuzzer
	@mkdir -p "results/$<"
	@./$< -close_fd_mask=1 -only_ascii=1 -print_final_stats=1 "-dict=dictionaries/$<.dict" "inputs/$<" "results/$<"

afl-fuzz-string: string-fuzzer
	@mkdir -p "results/$<"
	@afl-fuzz -i - -x "dictionaries/$<.dict" -o "results/$<" -- "./$<" || \
	 afl-fuzz -i "inputs/$<" -x "dictionaries/$<.dict" -o "results/$<" -- "./$<"

clean:
	@echo cleaning
	@rm -f $(ALL) *.o

distclean: clean
	@rm -rf results/

.PHONY: clean distclean debug afl-fuzz-text libfuzzer-text afl-fuzz-string
