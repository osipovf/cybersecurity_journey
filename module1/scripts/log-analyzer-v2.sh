#!/bin/bash
#скрипт считает кол-во строк в файле а также количество error fail...
FILE="$1"

if [ -z "$FILE" ]; then
    echo "Error-$FILE is not <road/to/file"
    exit 1;
fi

if [ ! -f "$FILE" ]; then
    echo "$FILE-is not file or it not exists"
    exit 1;
fi

OUTDIR="$(dirname "$0")/../logs" 
mkdir -p "$OUTDIR"
DATE=$(date +%Y-%m-%d-%H-%M-%S)
REPORT=$OUTDIR/log-analizer-v2_${DATE}.log

log(){
    echo "$@" | tee -a "$REPORT" 
}

log "File analyz:$FILE" 
log "date: $DATE"
TOTAL_STR=$(wc -l < "$FILE")
log "Total count string: $TOTAL_STR"
for WORD in error fail denied unauthorized; do
    COUNT=$(grep -ci "$WORD" "$FILE")
    log "$WORD:$COUNT"
done

log "---5 the most useful word ---"
log "$(awk '{print $1}' "$FILE" | sort | uniq -c | sort -rn | head -5)"
log "===== END ====="


