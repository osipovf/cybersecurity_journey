#!/bin/bash

FILE="$1"

if [ -z "$FILE" ]; then
    echo "Usage: $0 <path-to-pcap>"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Error: '$FILE' is not a file"
    exit 1
fi

OUTDIR="$(dirname "$0")/../logs"
mkdir -p "$OUTDIR"
DATA=$(date +%Y-%m-%d)
REPORT="$OUTDIR/top-talkers_${DATA}.log"

wlog(){
    echo "$@" | tee -a "$REPORT"
}

wlog "=== TOP TALKERS ==="
wlog "File: $FILE"
wlog "Date: $DATA"
wlog ""

wlog "--- Top 10 IP by packet count (all packets) ---"
tshark -r "$FILE" -T fields -e ip.src 2>/dev/null \
    | sort | uniq -c | sort -rn | head -10 \
    | while read -r count ip; do wlog "$count $ip"; done

wlog ""
wlog "--- Top 10 IP by bytes ---"
tshar -r "$FILE" -T fields -e ip.src -e frame.len 2>/dev/null \
    | awk '{if ($1 != "") sum[$1] += $2} END {for (ip in sum) print sum[ip], ip}' \
    | sort -rn | head -10 \
    | while read -r bytes ip; do wlog "$bytes $ip"; done

wlog ""
wlog "--- Top 10 IP pairs ---"
tshark -r "$FILE" -Y 'ip' -T fields -e ip.src -e ip.dst 2>/dev/null \
    | awk '{print $1" -> "$2}' | sort | uniq -c | sort -rn | head -10 \
    | while read -r count pair; do wlog "$count $pair"; done

wlog ""
wlog "--- Top 10 DNS queries ---"
tshark -r "$FILE" -Y 'dns.flags.response == 0' \
    -T fields -e dns.qry.name 2>/dev/null \
    | sort | uniq -c | sort -rn | head -10 \
    | while read -r count name; do wlog "$count $name"; done

wlog ""
wlog "--- Top 10 User-Agents ---"
tshark -r "$FILE" -Y 'http.user_agent' \
    -T fields -e http.user_agent 2>/dev/null \
    | sort | uniq -c | sort -rn | head -10 \
    | while read -r count ua; do wlog "$count $ua"; done

wlog ""
wlog "=== END ==="