#!/bin/bash
#скрипт анализирует переданный ему текстовый файл лога (например, веб-сервера или приложения), вычисляет количество строк и считает частоту упоминания IP-адресов. Затем он находит первые 10 строк с ошибками, подсчитывает статистику по уровням логирования (INFO, WARN, ERROR, CRITICAL)
FILE="$1"

if [ -z "$FILE" ]; then
    echo "Error: file argument is empty"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "$FILE is not a file or path is wrong"
    exit 1
fi

OUTDIR="$(dirname "$0")/../logs"
mkdir -p "$OUTDIR"
DATE=$(date +%Y-%m-%d-%H-%M-%S)
RESPOND="$OUTDIR/log-stats_${DATE}.log"

log() {
    echo "$@" | tee -a "$RESPOND"
}

log "=== LOG STATS ==="
log "File: $FILE"
log ""

TOTAL_STR=$(wc -l < "$FILE")
log "Total lines: $TOTAL_STR"
log ""

log "--- Top 10 IPs ---"
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$FILE" | sort | uniq -c | sort -rn | head -10 | tee -a "$RESPOND"
log ""

log "--- Top 10 ERROR lines ---"
grep -i "error" "$FILE" | head -10 | tee -a "$RESPOND"
log ""

log "--- Level counters ---"
for LEVEL in INFO WARN ERROR CRITICAL; do
    COUNT=$(awk -v lvl="$LEVEL" '$3 == lvl' "$FILE" | wc -l | tr -d ' ')
    log "$LEVEL: $COUNT"
done