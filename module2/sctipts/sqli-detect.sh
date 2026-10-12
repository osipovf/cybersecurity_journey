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

if ! command -v tshark >/dev/null 2>&1; then
    echo "Error: tshark not found"
    exit 1
fi

OUTDIR="$(dirname $0)/../logs"
mkdir -p "$OUTDIR"

DATA="$(date +%Y-%m-%d)"
REPORT="$OUTDIR/sqli-detect_${DATA}.log"

log() {
    echo "$@" | tee -a "$REPORT"
}

# --- Паттерны ---
SQLI=("'" "--" "union" "select" "or 1=1" "sleep(" "benchmark(")
XSS=("<script" "javascript:" "onerror=" "alert(")
TRAVERSAL=("../" "..%2f" "/etc/passwd")

# --- Собираем все URI и тело один раз ---
URIS=$(tshark -r "$FILE" -Y 'http.request' \
    -T fields -e http.request.full_uri -e http.file_data 2>/dev/null)

log "=== SQLI / XSS / PATH TRAVERSAL DETECTOR ==="
log "File: $FILE"
log "Date: $DATA"
log ""

TOTAL=0

# --- SQL-инъекции ---
log "Section 1: SQL Injection patterns"
for PATTERN in "${SQLI[@]}"; do
    COUNT=$(echo "$URIS" | grep -ci -- "$PATTERN")
    TOTAL=$((TOTAL + COUNT))
    log "Pattern '$PATTERN': $COUNT matches"
    if [ "$COUNT" -gt 0 ]; then
        echo "$URIS" | grep -i -- "$PATTERN" | head -3 | while read -r uri; do
            log "    $uri"
        done
    fi
done
log ""

# --- XSS ---
log "Section 2: XSS patterns"
for PATTERN in "${XSS[@]}"; do
    COUNT=$(echo "$URIS" | grep -ci -- "$PATTERN")
    TOTAL=$((TOTAL + COUNT))
    log "Pattern '$PATTERN': $COUNT matches"
    if [ "$COUNT" -gt 0 ]; then
        echo "$URIS" | grep -i -- "$PATTERN" | head -3 | while read -r uri; do
            log "    $uri"
        done
    fi
done
log ""

# --- Path traversal ---
log "Section 3: Path Traversal patterns"
for PATTERN in "${TRAVERSAL[@]}"; do
    COUNT=$(echo "$URIS" | grep -ci -- "$PATTERN")
    TOTAL=$((TOTAL + COUNT))
    log "Pattern '$PATTERN': $COUNT matches"
    if [ "$COUNT" -gt 0 ]; then
        echo "$URIS" | grep -i -- "$PATTERN" | head -3 | while read -r uri; do
            log "    $uri"
        done
    fi
done
log ""

# --- Вердикт ---
log "=== VERDICT ==="
if [ "$TOTAL" -gt 0 ]; then
    log "[!] SUSPICIOUS TRAFFIC DETECTED"
    log "Total matches: $TOTAL"
else
    log "[+] No suspicious patterns found"
fi
log "=== END ==="