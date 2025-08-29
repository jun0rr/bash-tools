#!/bin/bash

VERSION="202504.04"

function printHelp() {
	echo "---------------------------------"
	echo " PWG - Random Password Generator "
	echo "        Version: $VERSION        "
	echo "       Author: Juno Roesler      "
	echo "---------------------------------"
	echo " Usage: pwg [-h | -S] | ([-a] [-l] [-m <symbols>] [-n] [-s] [-u] [-w]) <length>"
	echo "   Each option can be repeated to increase the occurrence of its character type."
	echo "   When no option is provided, the default is: '-l -n -s -u'"
	echo " Options:"
	echo "   -a: Use lowercase letters, uppercase letters, and numbers."
	echo "   -h: Print this help text."
	echo "   -l: Use lower case letters in password."
	echo "   -m <symbols>: Use a custom set of symbols instead of the default."
	echo "   -n: Use numbers in password."
	echo "   -s: Use symbols in password."
	echo "   -S: Show default symbols character set."
	echo "   -u: Use upper case letters in password."
	echo "   -w: Use lowercase and uppercase letters only."
	echo " "
}


LOWER=('a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z')
UPPER=('A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z')
NUMBERS=('0' '1' '2' '3' '4' '5' '6' '7' '8' '9')
SYMBOLS=('!' '@' '#' '$' '%' '&' '*' '(' ')' '-' '=' '+' '[' ']' '{' '}' '|' '<' '>' '.' ',' ';' ':' '/' '?')

declare -a SHUFFLE

# Generates a random number (unsigned 4 bytes int) between min and max parameters
# {1} Min value
# {2} Max value + 1
# {return} Random int number
function randomInt() {
	rand=$(dd if=/dev/urandom bs=1 count=4 status=none | od -A n -t u4 | tr -d ' ')
	expr $1 + $rand % $2
}

function shuffle() {
	len=${#SHUFFLE[@]}
	idx=$(randomInt 0 $len)
	echo ${SHUFFLE[$idx]}
}

function randSource() {
	case $1 in 
		'l') SHUFFLE=(${LOWER[@]});;
		'u') SHUFFLE=(${UPPER[@]});;
		'n') SHUFFLE=(${NUMBERS[@]});;
		's') SHUFFLE=(${SYMBOLS[@]});;
		*) echo "ERROR: randSource($1)";;
	esac
	shuffle
}

set -f

opts=($@)
declare -a src
len=0

for ((i=0; i<${#opts[@]}; i++)); do
	opt=${opts[$i]}
	if [[ $opt =~ \-[almnsSuw]{2,8} ]]; then
		opts[$i]="-"${opt:1:1}
		ilast=$((${#opts[@]}-1))
		last=${opts[$ilast]}
		unset opts[$ilast]
		for ((j=2; j<${#opt}; j++)); do
			opts+=("-"${opt:$j:1})
		done
		opts+=($last)
	fi
	case ${opts[$i]} in
		"-S") 
			echo "Default Symbols Character Set:"
			echo " ${SYMBOLS[@]}"
			exit 0
			;;
		"-a") src+=('l' 'u' 'n');;
		"-h") printHelp
			exit 0;;
		"-l") src+=('l');;
		"-m") 
			((i++))
			SYMBOLS=()
			SYMBOLS=$(echo "${opts[$i]}" | grep -o .)
			;; 
		"-n") src+=('n');;
		"-s") src+=('s');;
		"-u") src+=('u');;
		"-w") src+=('l' 'u');;
		*)
			if [[ $i = $((${#opts[@]}-1)) && $i =~ [0-9]+ ]]; then
				len=${opts[$i]}
			else
				printHelp
				echo "ERROR: Unknown option (${opts[$i]})"
				exit 1
			fi
			;;
	esac
done


if [ $len -eq 0 ]; then
	printHelp
	echo "ERROR: Missing password length"
	exit 2
elif [ ${#src[@]} -eq 0 ]; then
	src=('l' 'u' 'n' 's')
fi

slen=${#src[@]}
x=$(randomInt 0 $slen)

passwd=""
for ((i=0; i<$len; i++)); do
	passwd="$passwd"$(randSource ${src[$x]})
	if [ $x -eq $((slen - 1)) ]; then
		x=0
	else
		((x++))
	fi
done

echo "$passwd"

set +f

