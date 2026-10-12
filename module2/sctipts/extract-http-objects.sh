#!/bin/bash

FILE=$1
DIR=$2

if [ -z "$FILE" ]; then 
    echo "file is empty , try again"
    exit 1
fi 

if [ ! -f "$FILE" ]; then 
    echo "$FILE is not file"
    exit 1
fi

if [ -z "$DIR" ]; then
    echo "Error: output dir is empty"
    exit 1
fi

mkdir -p "$DIR"

OUTDIR="$(dirname $0)/../logs"
mkdir -p "$OUTDIR"
DATA=$(date +%Y-%m-%d)
REPORT="$OUTDIR/extract-http-objects_${DATA}.log"

wlog(){
    echo "$@" | tee -a "$REPORT"
}



wlog "START"
wlog "FROM file : $FILE"
wlog "TO dir : $DIR"
tshark -r "$FILE" --export-objects http,"$DIR" 2>/dev/null
wlog "file count:"
ls "$DIR" | wc -l | tee -a "$REPORT"
wlog "union SIZE:"
du -sh "$DIR"| tee -a "$REPORT"
wlog "list file-size:"
ls -lh "$DIR" | tee -a "$REPORT"
wlog "END"