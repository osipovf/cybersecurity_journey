#!/bin/bash

FILE="$1"

if [ -z "$FILE" ]; then
    echo "Error: pcap file is empty, try again"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Error: '$FILE' is not a file"
    exit 1
fi

OUTDIR="$(dirname $0)/../logs"
mkdir -p "$OUTDIR"

DATA="$(date +%Y-%m-%d)"
REPORT="$OUTDIR/http-analyzer_${DATA}.log"

log() {
    echo "$@" | tee -a "$REPORT"
}

log "=== HTTP ANALYZER ==="
log "File: $FILE"
log "Date: $DATA"
log ""

log "Section 1: General statistics"

log "total http requests:"
tshark -r "$FILE" -Y 'http.request' \
    -T fields -e http.request.method 2>/dev/null \
    | wc -l | tee -a "$REPORT"

log "total http responses:"
tshark -r "$FILE" -Y 'http.response' \
    -T fields -e http.response.code 2>/dev/null \
    | wc -l | tee -a "$REPORT"

log "unique hosts:"
tshark -r "$FILE" -Y 'http.host' \
    -T fields -e http.host 2>/dev/null \
    | sort -u | wc -l | tee -a "$REPORT"

log ""

log "Section 2: Top 10 methods"
tshark -r "$FILE" -Y 'http.request' \
    -T fields -e http.request.method 2>/dev/null \
    | sort | uniq -c | sort -rn | head -10 | tee -a "$REPORT"

log ""

log "Section 3: Top 10 hosts"
tshark -r "$FILE" -Y 'http.request' \
    -T fields -e http.host 2>/dev/null \
    | sort | uniq -c | sort -rn | head -10 | tee -a "$REPORT"

log ""

log "Section 4: Top 10 URLs"
tshark -r "$FILE" -Y 'http.request' \
    -T fields -e http.request.full_uri 2>/dev/null \
    | sort | uniq -c | sort -rn | head -10 | tee -a "$REPORT"

log ""

log "Section 5: Status codes"
tshark -r "$FILE" -Y 'http.response' \
    -T fields -e http.response.code 2>/dev/null \
    | sort | uniq -c | sort -rn | tee -a "$REPORT"

log ""

log "Section 6: Top 10 User-Agents"
tshark -r "$FILE" -Y 'http.user_agent' \
    -T fields -e http.user_agent 2>/dev/null \
    | sort | uniq -c | sort -rn | head -10 | tee -a "$REPORT"

log ""

log "Section 7: Top 10 POST requests"
tshark -r "$FILE" -Y 'http.request.method == "POST"' \
    -T fields -e ip.src -e http.host -e http.request.uri 2>/dev/null \
    | sort | uniq -c | sort -rn | head -10 | tee -a "$REPORT"

log ""
log "=== END ==="