#!/bin/sh
export LANG="en_US.UTF-8"
export VIS_PATH=.
export EDITORS

[ -z "$VIS" ] && VIS="../../vis"
[ -z "$VIM" ] && VIM="vim"

if [ -n "$EDITORS" ]; then
	:
elif command -v "$VIM" >/dev/null 2>&1; then
	EDITORS="$VIM $VIS"
else
	EDITORS="$VIS"
fi

if [ -n "$DEBUG" ]; then
	exec 3>/dev/stderr
else
	exec 3>/dev/null
fi

if [ $# -eq 1 ]; then
	for EDITOR in $EDITORS; do
		e=$(basename "$EDITOR")
		if
			[ "$e" = "vis" ] && { ! [ -e "$1.ref" ] && ! [ -e "$1.vim.out" ]; }
		then
			# we're vis but we have no reference to compare it to
			echo "$e $1 SKIP"
			exit 0
		elif
			! sed 's,[ \t]*/\*.*\*/[ \t]*,,; $a\
				<Escape>:w! '"$1.$e.out"'<Enter>:qall!<Enter>' "$1.keys" |
			if [ -n "$DEBUG" ] && [ "$e" = "vis" ]; then
				exec ../util/keys -L "$DEBUG"
			else
				exec ../util/keys
			fi | (
				# escalate sigint bc vim & vis have their thumb up their ass - cannot be interupted
				trap 'kill 0' INT TERM
				rm -f "$1.$e.out"
				case "$e" in
					vim) $EDITOR --not-a-term -n -u NONE -U NONE -i NONE "$1.in" >/dev/null 2>&1;;
					vis|*) $EDITOR "$1.in" 1>&3 2>&1
				esac && ( [ -e "$1.$e.out" ] || ( printf "vis failed to produce output file\n" 1>&3; false ) )
			)
		then
		        echo "$e $1 ERROR"
		        if [ -n "$DEBUG" ]; then
				exit 2
			fi
			exit 255
		elif
			{ ! [ -e "$1.ref" ] && [ "$e" != "vis" ]; } || # other editor produces the reference - if it ran, it passed
			(
				{ [ -e "$1.ref" ] && diff -u "$1.ref" "$1.$e.out"; } ||
				{ [ "$e" = "vis" ] && [ -e "$1.vim.out" ] && diff -u "$1.vim.out" "$1.$e.out"; }
			) > "$1.$e.err"
		then

		        echo "$e $1 PASS"
		else
		        echo "$e $1 FAIL"
			exit 1
		fi
	done

	exit 0
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
	{
		$VIM --version | head -1
		$VIS -v
	} 1>&2 </dev/null

	if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
		:
	else
		tput() {
			:
		}
	fi

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
			{ printf "%s %-50s %s\n", $1, $2, c $3 white }
			END { n=NR-s; printf "Tests ok %d/%d, skipped %d\n", p, NR, s | "cat 1>&2"; exit p != n }
		'
fi
