#!/bin/bash
# Скрипт анализирует .pcap-файл через tcpdump

FILE=$1

if [ -z "$FILE" ]; then
    echo "File is empty"
    exit 1;
fi

if [ ! -f "$FILE" ]; then
    echo "$FILE is not file, please past <road_to_file>"
    exit 1;
fi

OUTDIR="$(dirname "$0")/../logs"
mkdir -p "$OUTDIR"
DATE=$(date +%Y-%m-%d-%H-%M-%S)
RESPOND="$OUTDIR/pcap-info_${DATE}.log"

log() {
    echo "$@" | tee -a "$RESPOND"
}

log "Analyz:"
log "Total count packets: $(tcpdump -r "$FILE" -n 2>/dev/null | wc -l)"
log "Top 10 ip-address:"
tcpdump -r "$FILE" -n 2>/dev/null | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort | uniq -c | sort -rn | head -10 | tee -a "$RESPOND"
log "Top 10 ports:"
tcpdump -r "$FILE" -n 2>/dev/null \
    | awk '{print $3, $5}' \
    | tr ':' ' ' \
    | awk '{print $1, $2}' \
    | tr '.' ' ' \
    | awk '{print $NF}' \
    | sort -n | uniq -c | sort -rn | head -10 \
    | tee -a "$RESPOND"
log "Unique protocols "
tcpdump -r "$FILE" -n 2>/dev/null \
    | grep -oE '\b(TCP|UDP|ICMP|ARP|DNS|HTTP|TLS)\b' \
    | sort | uniq -c | sort -rn | head -10 \
    | tee -a "$RESPOND"
log "=== END ==="