#!/bin/sh

export PATH="$PWD/../..:$PATH"
export LANG="en_US.UTF-8"
[ -z "$VIS" ] && VIS="../../vis"
export VIS

if [ -n "$DEBUG" ]; then
	exec 3>/dev/stderr
else
	exec 3>/dev/null
fi


if [ $# -eq 1 ]; then
	rm -f "$1.out"
	if ! timeout -s KILL 3s $VIS '+qall' "$1.in" < /dev/null 2>&3 || ! [ -e "$1.out" ]; then
	        echo "$1 ERROR"
	        if [ -n "$DEBUG" ]; then
			exit 2
		fi
		exit 255
	elif diff -u "$1.ref" "$1.out" > "$1.err"; then
	        echo "$1 PASS"
	        exit 0
	else
	        echo "$1 FAIL"
	        exit 1
	fi
else
	find . -type f -name '*.keys' | sed 's,.keys$,,; s,^./,,' |
	if  [ -n "$JOBS" ]  && [ "$JOBS" -gt 1 ] && command -v xargs >/dev/null 2>&1; then
		RECURSIVE=1 xargs -n1 -P"$JOBS" "$0" 2>&3
	else while read -r t; do
		RECURSIVE=1 "$0" "$t"
		if [ $? = 255 ]; then
			break
		fi
	done; fi | tee test.out
fi | if [ -n "$RECURSIVE" ]; then
	cat
else
	if ! $VIS -v 2>&1 | grep '+lua' >/dev/null; then
		echo "vis compiled without lua support, skipping tests" 1>&2
		exit 0
	fi

	if ! command -v tput >/dev/null 2>&1 || ! [ -t 1 ]; then
		tput() {
			:
		}
	fi

	printf ':help\n:/ Lua paths/,$ w! help\n:qall\n' | $VIS >/dev/null 2>&1 && cat help 1>&2 && rm -f help
	$VIS -v 1>&2

	awk \
		-v "red=$(tput setaf 1)" \
		-v "green=$(tput setaf 2)" \
		-v "white=$(tput setaf 7)" \
		-v "yellow=$(tput setaf 3)" \
		'
			/PASS/  {p++; c=green  }
			/SKIP/  {s++; c=yellow }
			/FAIL/  {     c=red    }
			/ERROR/ {     c=red    }
			{ printf "%-50s %s\n", $1, c $2 white }
			END { n=NR-s; printf "Tests ok %d/%d, skipped %d\n", p, NR, s | "cat 1>&2"; exit p != n }
		'
fi
