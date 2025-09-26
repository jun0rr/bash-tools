#!/bin/bash

# Align text to center, adding {2} <char> to left and right until {1} line size.
# {1} Line size
# {2} Padding char
# {3} Text
function padCenter() {
    lineSize=$1
    char="$2"
    text="$3"
    textLen=${#text}
    size=$(($lineSize-$textLen))
    sizeL=$(($size/2))
    sizeR=$sizeL
    if [ $(($sizeL*2)) -lt $size ]; then
        sizeR=$(($sizeL+1))
    fi
    for ((i=0; i<sizeL; i++)); do
        echo -n "$char"
    done
    echo -n "$text"
    for ((i=0; i<sizeR; i++)); do
        echo -n "$char"
    done
    echo ""
}


# Align text to right, adding {2} <char> to left until {1} line size.
# {1} Line size
# {2} Padding char
# {3} Text
function padLeft() {
    lineSize=$1
    char="$2"
    text="$3"
    textLen=${#text}
    size=$(($lineSize-$textLen))
    for ((i=0; i<size; i++)); do
        echo -n "$char"
    done
    echo "$text"
}


VERSION="202411.08"

function printHelp() {
	padCenter 36 '-'
	padCenter 36 ' ' 'HideSH - Bash Script Obfuscation'
	padCenter 36 ' ' "Version: $VERSION"
	padCenter 36 ' ' 'Author: Juno Roesler'
	padCenter 36 '-'
	line="Usage: hide.sh [-h] [-o <file>] (-u | -i | [-n] [-e [-E | -p]] [-s]) [input]"
    padLeft $((${#line}+1)) ' ' "$line"
	line="When [input] is not provided, content is readed from stdin"
    padLeft $((${#line}+3)) ' ' "$line"
	line="Options:"
    padLeft $((${#line}+1)) ' ' "$line"
    line="-e/--encrypt ......: Encrypt input script with random password"
    padLeft $((${#line}+3)) ' ' "$line"
    line="-E/--env <var=file>: Use an environment file with var=password for encryption"
    padLeft $((${#line}+3)) ' ' "$line"
    line="-h/--help .........: Print this help text"
    padLeft $((${#line}+3)) ' ' "$line"
    line="-i/--info .........: Print info of an obfuscated cotent"
    padLeft $((${#line}+3)) ' ' "$line"
    line="-n/--num ..........: Number of iterations (default=1)"
    padLeft $((${#line}+3)) ' ' "$line"
    line="-o/--out ..........: Output file (default stdout)"
    padLeft $((${#line}+3)) ' ' "$line"
    line="-p/--pass <pwd>....: Use a custom password for encryption"
    padLeft $((${#line}+3)) ' ' "$line"
    line="-s/--src ..........: Call 'source' on script instead of executing it"
    padLeft $((${#line}+3)) ' ' "$line"
    line="-u/--unhide .......: Unhide obfuscated content"
    padLeft $((${#line}+3)) ' ' "$line"
    line="-v/--version ......: Print version"
    padLeft $((${#line}+3)) ' ' "$line"
	echo ""
}


opts=($@)
olen=${#opts[@]}
OPTN=0
ARGN=1
OPTO=0
ARGO=""
OPTS=0
OPTE=0
OPTU=0
OPTI=0
OPTP=0
ARGP=""
OPTENV=0
ARGENV=""
INPUT=""

for ((i=0; i<olen; i++)); do
	opt=${opts[i]}
	case $opt in
		-n | --num)
			OPTN=1
            if [ $i -ge $((${#opts[@]}-1)) ]; then
                printHelp
                echo "[ERROR] Number of iterations (-n) missing"
                exit 1
            fi
            i=$((i+1))
            ARGN=${opts[$i]}
            ;;
        -e | --encrypt) OPTE=1;;
        -E | --env)
            OPTENV=1
            if [ $i -ge $((${#opts[@]}-1)) ]; then
                printHelp
                echo "[ERROR] Enviroment variable name (-E) not found"
                exit 2
            fi
            i=$((i+1))
            ARGENV=${opts[$i]}
            ;;
        -s | --src) OPTS=1;;
        -o | --out)
            OPTO=1
            if [ $i -ge $((${#opts[@]}-1)) ]; then
                printHelp
                echo "[ERROR] Output file (-o) not found"
                exit 3
            fi
            i=$((i+1))
            ARGO=${opts[$i]}
            ;;
        -p | --pass)
            OPTP=1
            if [ $i -ge $((${#opts[@]}-1)) ]; then
                printHelp
                echo "[ERROR] Password (-p) not found"
                exit 4
            fi
            i=$((i+1))
            ARGP=${opts[$i]}
            ;;
        -u | --unhide) OPTU=1;;
        -i | --info) OPTI=1;;
        -h | --help)
            printHelp
            exit 0
            ;;
        -v | --version)
            echo "HideSH Version: $VERSION"
            exit 0
            ;;
        *)
			if [[ $opt =~ ^\-[a-z]$ || $opt =~ ^\-\-[a-z]+$ ]]; then
				printHelp
			    echo "[ERROR] Unknown option: $opt"
			    exit 3
			elif [ -z "$INPUT" ]; then
				INPUT="$opt"
			else
			    INPUT="$INPUT $opt"
			fi
            ;;
    esac
done

if [ $OPTU -eq 1 -a $((OPTN+OPTS+OPTE)) -gt 0 ]; then
	printHelp
	echo "[ERROR] Option -u/--unhide can not be used with -n|-s|-e"
	exit 4
fi

function parseInput() {
    if [ -e "$INPUT" ]; then
        c=$(cat $INPUT | sed ':a;N;$!ba;s/\n/_NL_/g')
    elif [ ! -z "$INPUT" ]; then
        c=$(echo "$INPUT" | sed ':a;N;$!ba;s/\n/_NL_/g')
    else
        c=$(timeout 3s cat - | sed ':a;N;$!ba;s/\n/_NL_/g')
        if [ -z "$c" ]; then
        	printHelp
            echo "[ERROR] Nothig readed from stdin"
            exit 4
        fi
    fi
	INFILEN=$(echo -n "$c" | wc -c)
}

function encodeInput() {
	parseInput
	if [[ ! $c =~ ^#!/.* ]]; then
		c='#!/bin/bash_NL_'$c
	fi
	c=$(echo $c | sed 's/_NL_/\n/g' | gzip | base64 | tr '\n' ' ' | sed -r 's/\s$//g')
}

function encryptInput() {
    pname=$(openssl rand -hex 8)
    pname='p'$pname
	if [ $OPTP -eq 1 -a ! -z "$ARGP" ]; then
		pass="$ARGP"
		out=$out"read -p 'Password required: ' -s $pname;echo '';"
	elif [ $OPTENV -eq 1 -a ! -z "$ARGENV" ]; then
		name=$(echo "$ARGENV" | sed -E 's|^([a-zA-Z]+[a-zA-Z0-9_]+)=.+$|\1|')
		file=$(echo "$ARGENV" | sed -E 's|^[a-zA-Z]+[a-zA-Z0-9_]=(.+)$|\1|')
		if [ -z "$name" ]; then
			printHelp
			echo "[ERROR] Environment variable cannot be empty!"
			exit 5
		fi
		if [ ! -e "$file" ]; then
			printHelp
			echo "[ERROR] Environment file does not exists: $file"
			exit 5
		fi
    file=$(realpath "$file")
		source $file
		pass=$(eval 'echo $'$name)
		callsrc=$(echo "source $file;" | gzip | base64 | tr '\n' ' ' | sed -r 's/\s$//g')
		out=$out'eval $(echo "'$callsrc'" | sed "s/ /\n/g" | base64 -d | gzip -d);'
		setpass=$(echo $pname'=$'$name | gzip | base64 | tr '\n' ' ' | sed -r 's/\s$//g')
		out=$out'eval $(echo "'$setpass'" | sed "s/ /\n/g" | base64 -d | gzip -d);'
	else
    	pass=$(openssl rand -hex 32)
    	epass=$(echo "$pname=$pass" | gzip | base64 | tr '\n' ' ' | sed -r 's/\s$//g')
    	out=$out'eval $(echo "'$epass'" | sed "s/ /\n/g" | base64 -d | gzip -d);'
	fi
    c=$(echo "$c" | openssl enc -aes-256-cbc -pbkdf2 -salt -pass "pass:$pass" | base64 | tr '\n' ' ' | sed -r 's/\s$//g')
	out=$out'$_x;echo "'$c'" | sed "s/ /\n/g" | base64 -d | openssl enc -d -aes-256-cbc -pbkdf2 -pass "pass:$'$pname'" | sed "s/ /\n/g" | base64 -d | gzip -d > $df;'
}

function formatOutput() {
	out=$out'chmod +x $df;'
	if [ $OPTS -eq 1 ]; then
       	out=$out'source $df;'
	else
       	out=$out'$df $@;'
	fi
	out=$out'rm $df'
 	for ((i=0; i<ARGN; i++)); do
     	out=$(echo "$out" | gzip | base64 | tr '\n' ' ' | sed -r 's/\s$//g')
        out=$(echo 'eval $(echo "'$out'" | sed "s/ /\n/g" | base64 -d | gzip -d)')
	done
}

function decodeInput() {
	parseInput
	if [[ ! $c =~ ^eval.* && ! $c =~ ^#!/.+_NL_eval.* ]]; then
		printHelp
		echo "[ERROR] Input is not obfuscated"
		exit 5
	fi
	c=$(echo "$c" | sed -E 's|^#!/.+_NL_||g')
	while [[ $c =~ ^eval.+ ]]; do
		c=$(echo $c | sed 's/eval $(echo "//g' | sed 's/".*//g')
		c=$(echo $c | sed "s/ /\n/g" | base64 -d | gzip -d)
		INFITE=$((INFITE+1))
	done
	# if is encrypted
	if [[ $c =~ .*pass:\$p[a-z0-9]{16}.* ]]; then
		# get password
		if [[ $c =~ .*read\ -p.+ ]]; then
			read -p 'Password required: ' -s pass;echo '' 
		elif [[ $c =~ .*H4sIAAAAAAAA.+H4sIAAAAAAAA.+ ]]; then
			src=$(echo $c | sed -E 's|^.*eval \$\(echo "(H4sIAAAAAAAA[a-zA-Z0-9/=+]{40,60}).+;eval \$\(echo "H4sIAAAAAAAA.+|\1|' | sed "s/ /\n/g" | base64 -d | gzip -d)
			eval $(echo "$src")
			var=$(echo $c | sed -E 's|^.*eval \$\(echo "H4sIAAAAAAAA.+;eval \$\(echo "(H4sIAAAAAAAA[a-zA-Z0-9/=+]{40,60}).+|\1|' | base64 -d | gzip -d | sed -E 's|^p[a-zA-Z0-9]{16}=\$(.+)|\1|')
			eval $(echo 'pass=$'$var)
		else
			pass=$(echo $c | sed -E 's|^.+eval \$\(echo "(H4sIAAAAAAAA[A-Za-z0-9 /=+]{90,110})".+|\1|' | sed "s/ /\n/g" | base64 -d | gzip -d | sed -E 's/^p[a-z0-9]{16}=//g')
		fi
		# get encrypted content
		c=$(echo $c | sed -E 's|.+;\$_x;echo "([A-Za-z0-9 /=+]+).+|\1|')
		# decrypt content
		c=$(echo $c | sed "s/ /\n/g" | base64 -d | openssl enc -d -aes-256-cbc -pbkdf2 -pass "pass:$pass" | sed "s/ /\n/g" | base64 -d | gzip -d | sed ':a;N;$!ba;s/\n/_NL_/g')
		INFENC=1
	else
		c=$(echo $c | sed -E 's|^.+("[A-Za-z0-9/+=]+(\s[A-Za-z0-9/+=]+)+").*|\1|' | sed 's/"//g' | sed "s/ /\n/g" | base64 -d | gzip -d | sed ':a;N;$!ba;s/\n/_NL_/g')
	fi
	out="$c"
	INFOLEN=$(echo -n "$out" | wc -c)
}


# Divide 2 int numbers, returning a float number
# $1 - Numerator
# $2 - Denominator
# $3 - Number of decimals
# $r - Float number
function divInt() {
    num=$1
    den=$2
    ndc=$3
    # Multiply by 10^ndc for precision
    multiplier=$((10**ndc))
    result=$((num * multiplier / den))
    # Split into integer and decimal parts
    int_part=$((result / multiplier))
    dec_part=$((result % multiplier))
    # Format decimal part with leading zeros if needed
    printf "%d.%0*d\n" $int_part $ndc $dec_part
}


INFILEN=0
INFOLEN=0
INFITE=0
INFENC=0

out='df=/tmp/$(uuidgen | sed "s/-//g");'
c=""

if [ $((OPTI+OPTU)) -ge 1 ]; then
	decodeInput
else
	encodeInput
	if [ $OPTE -eq 1 ]; then
		encryptInput
	else
		out=$out'echo "'$c'" | sed "s/ /\n/g" | base64 -d | gzip -d > $df;'
	fi
	formatOutput
fi

if [ $OPTO -eq 1 ]; then
	echo -n "" > $ARGO
	if [[ ! $out =~ ^#!/.+ ]]; then
		echo '#!/bin/bash' >> $ARGO
	fi
	echo $out | sed 's/_NL_/\n/g' >> $ARGO
elif [ $OPTI -eq 1 ]; then
	padCenter 36 '-'
	padCenter 36 ' ' 'Obfuscated Content Info'
	padCenter 36 '-'
	line="Iterations ...: $INFITE"
        padLeft $((${#line}+4)) ' ' "$line"
	if [ $INFENC -eq 1 ]; then
		INFENC="aes-256-cbc"
	else
		INFENC="No"
	fi
	line="Encryption ...: $INFENC"
  padLeft $((${#line}+4)) ' ' "$line"
	if [ $INFILEN -le $INFOLEN ]; then
		size=$((INFOLEN-INFILEN))
		size=$((size*100))
		size=$(divInt $size $INFOLEN 1)
		line="Size Diff ....: < $size%"
	else
		size=$((INFILEN-INFOLEN))
		size=$((size*100))
		size=$(divInt $size $INFOLEN 1)
		line="Size Diff ....: > $size%"
	fi
  padLeft $((${#line}+4)) ' ' "$line"
  padCenter 36 '-'
else
	echo $out | sed 's/_NL_/\n/g'
fi

