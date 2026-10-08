#!/bin/bash
#скрипт определяет тип переданного аргумента Узнает владельца, группу, размер и права доступа (в текстовом и числовом виде).
FILE="$1"

if [ -z "$FILE" ]; then
    echo "Error: no file argument"
    exit 1
fi

if [ ! -e "$FILE" ]; then
    echo "Error: '$FILE' does not exist"
    exit 1
fi

OUTDIR="$(dirname "$0")/../logs"
mkdir -p "$OUTDIR"
DATE=$(date +%Y-%m-%d-%H-%M-%S)
RESPOND="$OUTDIR/permission-check_${DATE}.log"

log() {
    echo "$@" | tee -a "$RESPOND"
}


if [ -L "$FILE" ]; then
    TYPE="symlink"
elif [ -d "$FILE" ]; then
    TYPE="directory"
elif [ -f "$FILE" ]; then
    TYPE="regular file"
else
    TYPE="other"
fi

PERMISSIONS=$(ls -l "$FILE" | awk '{print $1}')

# Кроссплатформенный stat
# для Macos
if stat -f "%A" "$FILE" >/dev/null 2>&1; then
    NUMERIC=$(stat -f "%A" "$FILE")
    OWNER=$(stat -f "%Su" "$FILE")
    GROUP=$(stat -f "%Sg" "$FILE")
    SIZE=$(stat -f "%z" "$FILE")
else # для Linux
    NUMERIC=$(stat -c "%a" "$FILE")
    OWNER=$(stat -c "%U" "$FILE")
    GROUP=$(stat -c "%G" "$FILE")
    SIZE=$(stat -c "%s" "$FILE")
fi

log "=== PERMISSION CHECK ==="
log "File: $FILE"
log "Type: $TYPE"
log "Permissions: $PERMISSIONS"
log "Numeric: $NUMERIC"
log "Owner: $OWNER"
log "Group: $GROUP"
log "Size: $SIZE bytes"

# Проверка опасных прав
WARNED=0
if [ "$NUMERIC" = "777" ]; then
    log "WARNING: 777 permissions (world-writable)!"
    WARNED=1
fi
if echo "$PERMISSIONS" | grep -q "s"; then
    log "WARNING: SUID/SGID bit is set!"
    WARNED=1
fi
if [ $WARNED == 0 ]; then
    log "Warnings: (none)"
fi
