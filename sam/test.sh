#!/bin/sh

NL='
'

export LANG="en_US.UTF-8"

[ -z "$VIS" ] && VIS="../../vis"
[ -z "$PLAN9" ] && PLAN9="/usr/local/plan9/bin"

if [ -z "$SAM" ] || ! command -v "$SAM" >/dev/null 2>&1; then
	for path in sam "$PLAN9/sam" /opt/plan9/bin/sam /usr/lib/plan9/bin/sam 9; do
		if command -v "$path" >/dev/null 2>&1; then
			SAM="$path"
			break
		fi
	done
fi

if [ "$SAM" = "9" ]; then
	SAM="9 sam"
fi

echo "$SAM"
"$SAM" -h # for lack of version
$VIS -v

if ! $VIS -v | grep '+lua' >/dev/null 2>&1; then
	echo "vis compiled without lua support, skipping tests"
	exit 0
fi

TESTS=$1
[ -z "$TESTS" ] && TESTS=$(find . -name '*.cmd' | sed 's/\.cmd$//g')

TESTS_RUN=0
TESTS_OK=0

for t in $TESTS; do
	IN="$t.in"
	SAM_OUT="$t.sam.out"
	SAM_ERR="$t.sam.err"
	VIS_OUT="$t.vis.out"
	VIS_ERR="$t.vis.err"
	REF="$t.ref"
	rm -f "$SAM_OUT" "$SAM_ERR" "$VIS_OUT" "$VIS_ERR"

	command -v "$SAM" >/dev/null 2>&1 && {
		printf "Running test %s with sam ... " "$t"
		{
			echo ',{'
			cat "$t.cmd"
			echo '}'
			echo ,
		} | $SAM -d "$IN" > "$SAM_OUT" 2>/dev/null

		if [ $? -ne 0 ]; then
			printf "ERROR\n"
		elif [ -e "$REF" ]; then
			if cmp -s "$REF" "$SAM_OUT"; then
				printf "OK\n"
			else
				printf "FAIL\n"
				diff -u "$REF" "$SAM_OUT" > "$SAM_ERR"
			fi
		elif [ -e "$SAM_OUT" ]; then
			REF="$SAM_OUT"
			printf "OK\n"
		fi
	}

	if [ ! -e "$REF" ]; then
		continue
	fi

	TESTS_RUN=$((TESTS_RUN+1))

	$VIS '+qall!' "$IN" </dev/null 2>/dev/null
	RETURN_CODE=$?

	printf "Running test %s with vis ... " "$t"
	if [ $RETURN_CODE -ne 0 -o ! -e "$VIS_OUT" ]; then
		printf "ERROR\n"
	elif cmp -s "$REF" "$VIS_OUT"; then
		printf "OK\n"
		TESTS_OK=$((TESTS_OK+1))
	else
		printf "FAIL\n"
		diff -u "$REF" "$VIS_OUT" > "$VIS_ERR"
	fi
done

printf "Tests ok %d/%d\n" $TESTS_OK $TESTS_RUN

# set exit status
[ $TESTS_OK -eq $TESTS_RUN ]
