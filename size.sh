#!/bin/bash

declare -a unitsize
declare -a bb
declare -a kb
declare -a mb
declare -a gb
declare -a tb

bb=(0 'B')
kb=(1024, 'K')
mb=($((1024*1024)) 'M')
gb=($((1024*1024*1024)) 'G')
tb=($((1024*1024*1024*1024)) 'T')

unitsize=('bb' 'kb' 'mb' 'gb' 'tb')

declare -a units
units=('B' 'K' 'M' 'G' 'T')

declare -a sizes
sizes=(
        0 
        1024 
        $((1024*1024)) 
        $((1024*1024*1024)) 
        $((1024*1024*1024*1024))
)


# Divide 2 int numbers, returning a float number
# $1 - Numerator
# $2 - Denominator
# $3 - Number of decimals
# $r - Float number
function divInt() {
        num=$1
        den=$2
        ndc=$3
        mul=1
        for ((i=0; i<$ndc; i++)); do
                mul=$mul"0"
        done
        num=$((num*mul))
        int=$((num/den))
        iln=${#int}
        iln=$((iln-ndc))
        dec=${int:$iln:$((iln+ndc))}
        int=${int:0:$iln}
        echo $int"."$dec
}


function toHumanValue() {
        unit='B'
        size=0
        for i in "${!units[@]}"; do
                if [ $bytes -lt ${sizes[i]} ]; then
                        unit=${units[$((i-1))]}
                        size=${sizes[$((i-1))]}
                        break
                fi              
        done
        if [ $size -gt 0 ]; then
                value=$(divInt $bytes $size 2)"$unit"
        else
                value=$bytes"B"
        fi
}

function fromHumanValue() {
        bytes=$(echo "$bytes" | tr -d ' ')
        len=${#bytes}
        unit=${bytes:$(($len-1)):1}
        size=$(echo $bytes | tr -d $unit)
        idx=-1
        for i in "${!units[@]}"; do
                if [[ $unit = ${units[i]} ]]; then
                        idx=$i
                fi
        done
        if [ $idx -lt 0 ]; then
                echo "[ERROR] Unknown unit size: $unit"
                exit 2
        fi
        if [[ $size =~ ^[0-9]+\.[0-9]+$ ]]; then
                dec=$(echo "$size" | sed -E 's/^[0-9]+\.//g')
                size=$(echo "$size" | sed -E 's/\.[0-9]+//g')
                mult=1
                declen=${#dec}
                for ((i=0; i<declen; i++)); do
                        mult=$mult"0"
                done
                dec=$((${sizes[idx]}/$mult*$dec))
                value=$(($size*${sizes[idx]}+$dec))
        else
                value=$(($size*${sizes[idx]}))
        fi
}

bytes=$1
if [[ $bytes =~ ^[0-9]+$ ]]; then
        toHumanValue
elif [[ $1 =~ ^[0-9]+(\.[0-9]+)?[BKMGT]{1}$ ]]; then
        fromHumanValue
elif [ -f $bytes ]; then
        bytes=$(wc -c $bytes | cut -d ' ' -f 1)
        toHumanValue
else
        echo "[ERROR] Unknown input type: $bytes"
        exit 1
fi

echo $value
