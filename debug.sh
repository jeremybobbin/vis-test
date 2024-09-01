#!/bin/sh

{
	if [ $# -eq 1 ]; then
		find *"/$1.keys" | vis-menu
	else
		find | grep '\.keys$' | vis-menu
	fi
	printf '%s\n' print step | vis-menu
} | if ! read k; then
	printf "no test selected\n"
	exit 1
elif ! read a; then
	printf "failed to read action\n"
	exit 1
elif [ "$a" = step  ]; then
	t=${k%%.keys}
	t=${t#./}
	dir=${t%%/*}
	t=${t#"$dir"/}
	cd "$dir" && DEBUG=25 exec "./test.sh" "$t"
elif [ "$a" = print ]; then
	t=${k%%.keys}
	tput setaf 1; echo KEYS; tput setaf 7
	cat "$t.keys"
	echo
	tput setaf 1; echo INPUT; tput setaf 7
	cat "$t.in"
	echo
	tput setaf 1; echo DIFF; tput setaf 7
	if [ -e "$t.vim.out" ]; then 
		diff --color "$t.vim.out" "$t.vis.out"
	else
		diff --color "$t.ref" "$t.out"
	fi
else
	printf "unknown action %s\n" "$a"
	exit 1
fi
