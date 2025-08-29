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

VERSION="202410.04"

function printHelp()  {
	padCenter 38 '-'
	padCenter 38 ' ' "Cipher.sh - Encryption/Decryption tool"
	padCenter 38 ' ' "RSA/AES/CBC Algorithms"
	padCenter 38 ' ' "Version: $VERSION"
	padCenter 38 ' ' "Author: Juno Roesler"
	padCenter 38 '-'
	line="cipher.sh [-h | -g] | (-e <-k | -p <pass>> | -d [-k] -p <pass>) [file]"
	padLeft $((${#line}+2)) ' ' "$line"
	line="Options:"
	padLeft $((${#line}+2)) ' ' "$line"
	line="-d/--dec ...: Decrypt file/stdin"
	padLeft $((${#line}+4)) ' ' "$line"
	line="-e/--enc ...: Ecrypt file/stdin"
	padLeft $((${#line}+4)) ' ' "$line"
	line="-g/--gen ...: Generate RSA key pair"
	padLeft $((${#line}+4)) ' ' "$line"
	line="-h/--help ..: Print this help text"
	padLeft $((${#line}+4)) ' ' "$line"
	line="-k/--key ...: Private/Public key"
	padLeft $((${#line}+4)) ' ' "$line"
	line="-p/--pass ..: Password"
	padLeft $((${#line}+4)) ' ' "$line"
	line="-v/--version: Print Cipher version"
	padLeft $((${#line}+4)) ' ' "$line"
	echo ""
}

opts=($@)
olen=${#opts[@]}
OPTE=0
OPTD=0
OPTG=0
OPTP=0
OPTK=0
ARGP=""
ARGK=""
INFILE=""

for ((i=0; i<olen; i++)); do
	case ${opts[$i]} in
		-e | --enc)
			OPTE=1
			;;
		-d | --dec)
			OPTD=1
			;;
		-g | --gen)
			OPTG=1
			;;
		-p | --pass)
			OPTP=1
			if [ $i -ge $(($olen-1)) ]; then
				printHelp
				echo "[ERROR] Password not found"
				exit 1
			fi
			i=$((i+1))
			ARGP=${opts[$i]}
			;;
		-k | --key)
			OPTK=1
			if [ $i -ge $((${#opts[@]}-1)) ]; then
				printHelp
				echo "[ERROR] Private/Public key not found"
				exit 1
			fi
			i=$((i+1))
			ARGK=${opts[$i]}
			;;
		-h | --help)
			printHelp
			exit 0
			;;
		-v | --version)
			echo "CR2 Version: $VERSION"
			exit 0
			;;
		*)
			if [ -e ${opt[$i]} ]; then
				INFILE=${opt[$i]}
			else
				printHelp
				echo "[ERROR] Unknown option: ${opt[$i]}"
				exit 3
			fi
			;;
	esac
done

if [ -z "$INFILE" -a "$ARGK" != ${opts[$((olen-1))]} -a -e ${opts[$((olen-1))]} ]; then
	INFILE=${opts[$((olen-1))]}
fi

if [ $((OPTE+OPTD+OPTG)) -lt 1 ]; then
	printHelp
	echo "[ERROR] Missing mandatory option: <-e|-d|-g>"
	exit 4
elif [ $((OPTE+OPTD+OPTG)) -gt 1 ]; then
	printHelp
	echo "[ERROR] Multiple exclusive options present: <-e|-d|-g>"
	exit 5
elif [ $OPTE -eq 1 -a $((OPTK+OPTP)) -lt 1 ]; then
	printHelp
	echo "[ERROR] Missing encryption option: <-k|-p>"
	exit 6
elif [ $OPTE -eq 1 -a $((OPTK+OPTP)) -gt 1 ]; then
	printHelp
	echo "[ERROR] Multiple encryption options present: <-k|-p>"
	exit 7
elif [ $OPTD -eq 1 -a $OPTK -eq 1 -a $OPTP -lt 1 ]; then
	printHelp
	echo "[ERROR] Missing decryption private key password: -p <pass>"
	exit 8
elif [ $OPTK -eq 1 -a ! -e "$ARGK" ]; then
	printHelp
	echo "[ERROR] Missing private/public key: -k <key>"
	exit 9 
fi

TMPFILE=0
if [ $OPTG -eq 0 ]; then
	if [ -z "$INFILE" -o ! -e "$INFILE" ]; then
		TMPFILE=1
		INFILE="/tmp/$(uuidgen | base64 | sed 's/[=|\/]//g')"
		cat - > $INFILE
	fi
	if [ ! -e $INFILE ]; then
		printHelp
		echo "[ERROR] File does not exists: $INFILE"
		exit 2
	fi
fi

function genKeyPair() {
	echo "[INFO] Generating RSA key pair..."
	read -p "  RSA key bits <1024|2048|4096> (2048): " BITS
	read -p "  Private key file (pkey.pem): " PKEY
	read -p "  Public key file (pubkey.pem): " PUBKEY
	read -p "  Enter key password: " -s PASS && echo ''
	if [ -z "$BITS" ]; then
		BITS=2048
	elif [ ! $BITS -eq 1024 -o ! $BITS -eq 2048 -o ! $BITS -eq 4096 ]; then
		echo -e "\n[ERROR] Invalid RSA key bits: $BITS"
		exit 10
	fi
	if [ -z "$PASS" ]; then
		echo -e "\n[ERROR] Password can not be empty!"
		exit 11
	elif [ ${#PASS} -lt 4 ]; then
		echo -e "\n[ERROR] Password is too short (min 4 chars)!"
		exit 12
	fi
	if [ -z "$PKEY" ]; then
		PKEY="./pkey.pem"
	fi
	if [ -z "$PUBKEY" ]; then
		PUBKEY="./pubkey.pem"
	fi
	openssl genpkey -algorithm RSA -outform PEM -pass "pass:$PASS" -pkeyopt "rsa_keygen_bits:$BITS" -out "$PKEY" -outpubkey "$PUBKEY" -quiet
	echo -e "\n[INFO] Key pair generated successfully!"
	ls -lh $PKEY $PUBKEY
}

function encryptKeyLT224() {
	outfile="/tmp/$(uuidgen | base64 | sed 's/[=|\/]//g')"
	echo "-1" | base64 > $outfile
	cat $INFILE | openssl pkeyutl -encrypt -inkey $ARGK -pubin | base64 >> $outfile
	cat $outfile
	rm $outfile
}

function encryptKeyGT224() {
	simkey=$(openssl rand -hex 64)
	enckey=$(echo $simkey | openssl pkeyutl -encrypt -inkey $ARGK -pubin | base64)
	outfile="/tmp/$(uuidgen | base64 | sed 's/[=|\/]//g')"
	echo ${#enckey} | base64 > $outfile
	echo $enckey | sed 's/ /\n/g' >> $outfile
	cat $INFILE | openssl enc -aes-256-cbc -salt -pbkdf2 -pass "pass:$simkey" | base64 >> $outfile
	cat $outfile
	rm $outfile
}

function encryptKey() {
	cont=$(cat $INFILE)
	len=${#cont}
	if [ $len -gt 224 ]; then
		encryptKeyGT224
	else
		encryptKeyLT224
	fi
}

function encryptPass() {
	cat $INFILE | openssl enc -aes-256-cbc -salt -pass "pass:$ARGP" | base64
}

# {1} skip bytes
function decryptKeyLT224() {
	skip=$1
	cat $INFILE | tail -c+$((skip+1)) | base64 -d | openssl pkeyutl -decrypt -inkey $ARGK -passin "pass:$ARGP"
}

# {1} Header bytes
# {2} Key size
function decryptKeyGT224() {
	hdbytes=$1
	keysize=$2
	enckey=$(head -c $hdbytes $INFILE | tail -c $keysize)
	deckey=$(echo $enckey | sed 's/ /\n/g' | base64 -d | openssl pkeyutl -decrypt -inkey $ARGK -passin "pass:$ARGP")
	cat $INFILE | tail -c+$((hdbytes+2)) | base64 -d | openssl enc -d -aes-256-cbc -pbkdf2 -pass "pass:$deckey"
}

function decryptKey() {
	keysize=$(head -n 1 $INFILE)
	sizebytes=${#keysize}
	keysize=$(echo $keysize | base64 -d)
	if [ $keysize -lt 0 ]; then
		decryptKeyLT224 $sizebytes
	else
		hdbytes=$(($keysize+$sizebytes+1))
		decryptKeyGT224 $hdbytes $keysize
	fi
}

function decryptPass() {
	cat $INFILE | base64 -d | openssl enc -d -aes-256-cbc -pass "pass:$ARGP"
}

if [ $OPTG -eq 1 ]; then
	genKeyPair
elif [ $OPTE -eq 1 -a $OPTK -eq 1 ]; then
	encryptKey
elif [ $OPTE -eq 1 -a $OPTP -eq 1 ]; then
	encryptPass
elif [ $OPTD -eq 1 -a $OPTK -eq 1 ]; then
	decryptKey
else
	decryptPass
fi

if [ $TMPFILE -eq 1 ]; then
	rm $INFILE
fi

