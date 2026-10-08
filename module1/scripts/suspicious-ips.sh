#!/bin/bash
# скрипт автоматизирует поиск и аудит подозрительных IP-адресов в лог-файле, частота запросов которых превышает заданный порог $N (по умолчанию 10). Для каждого найденного IP он фиксирует количество вхождений и первые три сопутствующие строки лога
FILE="$1"
N="${2:-10}"



if [ -z "$FILE" ]; then
    echo "Error: file argument is empty"
    echo "Usage: $0 <logfile> [N]"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Error: '$FILE' is not a file or path is wrong"
    exit 1
fi

# Проверка, что N — положительное число
if ! [[ "$N" =~ ^[0-9]+$ ]]; then
    echo "Error: N must be a positive integer (got: $N)"
    exit 1
fi



OUTDIR="$(dirname "$0")/../logs"
mkdir -p "$OUTDIR"
DATE=$(date +%Y-%m-%d-%H-%M-%S)
RESPOND="$OUTDIR/suspicious-ips_${DATE}.log"

log() {
    echo "$@" | tee -a "$RESPOND"
}



log "=== SUSPICIOUS IP AUDIT ==="
log "File: $FILE"
log "Threshold (N): $N"
log "Date: $(date +%Y-%m-%d\ %H:%M:%S)"
log ""

# собираем список подозрительных IP 
# Извлекаем все IP, считаем частоты, фильтруем те, что > N.
# Результат сохраняем в переменную — чтобы потом проверить, пусто или нет.

SUSPICIOUS=$(grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$FILE" \
    | sort | uniq -c | sort -rn \
    | awk -v threshold="$N" '$1 > threshold')

#если никого не нашли говорим об этом

if [ -z "$SUSPICIOUS" ]; then
    log "No suspicious IPs found (nobody exceeds $N occurrences)."
    log "END"
    exit 0
fi

# для каждого подозрительного IP выводим детали 

log "--- Suspicious IPs (more than $N occurrences) ---"
log ""

echo "$SUSPICIOUS" | while read -r count ip; do
    log "IP: $ip"
    log "Count: $count"
    log "First 3 lines:"
    grep "$ip" "$FILE" | head -3 | tee -a "$RESPOND"
    log ""
done

log "=== END ==="