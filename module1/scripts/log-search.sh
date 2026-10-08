#!/bin/bash
#скрипт считает количество заданного слова в заданном файле а также выводит первые 10 строк с заданным словом
FILE="$1"
WORD="$2"

if [ -z "$FILE" ]; then
    echo "File empty - please input <road/to/file>"
    exit 1;
fi
if [ -z "$WORD" ]; then
    echo "$WORD empty - please input <road/to/file> and after WORD"
    exit 1;
fi

if [ ! -f "$FILE" ]; then 
    echo "$FILE-is not file"
    exit 1;
fi

OUTDIR="$(dirname "$0")/../logs"
mkdir -p "$OUTDIR"
DATE=$(date +%Y-%m-%d-%H-%M-%S)
REPORT="$OUTDIR/log-search.sh_${DATE}.log"

log(){
    echo "$@" | tee -a "$REPORT"
}

log " Search: $WORD in $FILE "

TOTAL_WORD=$( grep -ci "$WORD" "$FILE")
log "Total $WORD in $FILE: $TOTAL_WORD"

log "First_ten_string_with $WORD"
log "$(grep -i "$WORD" "$FILE" | head -10)"

log "END analyzing"


