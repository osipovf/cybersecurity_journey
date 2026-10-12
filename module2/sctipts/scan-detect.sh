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
REPORT="$OUTDIR/scan-detect_${DATA}.log"

wlog(){
    echo "$1" | tee -a "$REPORT"
}

wlog "=== SCAN DETECT ==="
wlog "File: $FILE"
wlog "Date: $DATA"
wlog ""

TOTAL_SYN=$(tshark -r "$FILE" -Y 'tcp.flags.syn == 1 && tcp.flags.ack == 0' \
    -T fields -e frame.number 2>/dev/null | wc -l | tr -d ' ')

TOTAL_RST=$(tshark -r "$FILE" -Y 'tcp.flags.reset == 1' \
    -T fields -e frame.number 2>/dev/null | wc -l | tr -d ' ')

UNIQUE_PORTS=$(tshark -r "$FILE" -Y 'tcp.flags.syn == 1 && tcp.flags.ack == 0' \
    -T fields -e tcp.dstport 2>/dev/null | sort -u | wc -l | tr -d ' ')

UNIQUE_SRC=$(tshark -r "$FILE" -Y 'tcp.flags.syn == 1 && tcp.flags.ack == 0' \
    -T fields -e ip.src 2>/dev/null | sort -u | wc -l | tr -d ' ')

UNIQUE_DST=$(tshark -r "$FILE" -Y 'tcp.flags.syn == 1 && tcp.flags.ack == 0' \
    -T fields -e ip.dst 2>/dev/null | sort -u | wc -l | tr -d ' ')

wlog "Total SYN packets: $TOTAL_SYN"
wlog "Total RST packets: $TOTAL_RST"
wlog "Unique destination ports: $UNIQUE_PORTS"
wlog "Unique source IPs: $UNIQUE_SRC"
wlog ""
wlog "Top 3 source IPs:"

tshark -r "$FILE" -Y 'tcp.flags.syn == 1 && tcp.flags.ack == 0' \
    -T fields -e ip.src 2>/dev/null \
    | sort | uniq -c | sort -rn | head -3 \
    | while read -r count ip; do
        wlog "$ip: $count SYN"
      done

wlog ""
wlog "--- VERDICT ---"

if [ "$TOTAL_SYN" -gt 100 ] && [ "$UNIQUE_PORTS" -gt 20 ] && [ "$UNIQUE_SRC" -lt 5 ]; then
    wlog "[!] SCANNING DETECTED"
    wlog "Reason: $TOTAL_SYN SYN from $UNIQUE_SRC source(s) to $UNIQUE_PORTS unique ports"
elif [ "$TOTAL_SYN" -gt 100 ] && [ "$UNIQUE_DST" -gt 20 ]; then
    wlog "[!] HORIZONTAL SCANNING DETECTED"
    wlog "Reason: $TOTAL_SYN SYN to $UNIQUE_DST unique destination IPs"
else
    wlog "[+] NORMAL"
    wlog "Reason: no scanning patterns detected"
fi