#!/bin/bash
# скрипт выполняет экспресс-аудит системы: собирает информацию о топ-10 процессах по нагрузке на CPU и RAM, проверяет подозрительную активность и фиксирует текущие сетевые соединения
OUTDIR="$(dirname "$0")/../logs"
mkdir -p "$OUTDIR"
DATE=$(date +%Y-%m-%d)
RESPOND="$OUTDIR/process-audit_${DATE}.log"   

log(){
    echo "$@" | tee -a "$RESPOND"
}

log "PROCESS AUDIT:"
log "Date: $DATE"
log ""

log "_______________Top 10 process by CPU:_______________"
ps aux | sort -nrk 3 | head -10 | tee -a "$RESPOND"

log "_______________Top 10 processes by MEM _______________:"
ps aux | sort -nrk 4 | head -10 | tee -a "$RESPOND"

TOTAL_process=$(ps aux | wc -l)
log "_______________Total processes: $TOTAL_process"

log "_______________Suspicious-named processes_______________"
ps aux | grep -E "python|node|nc |socat|nmap" | grep -v grep | tee -a "$RESPOND"

log "___________Listening ports_______________"
lsof -i -P | grep LISTEN | tee -a "$RESPOND"

log "_______________Established connections_______________ "
lsof -i -P | grep ESTABLISHED | tee -a "$RESPOND"