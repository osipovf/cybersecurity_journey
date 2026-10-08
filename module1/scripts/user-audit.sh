#!/bin/bash
# скрипт выполняет аудит пользователей в macOS (используя утилитные команды dscl Directory Service). Он собирает информацию о текущем пользователе, выводит список всех несистемных учетных записей (исключая служебные с префиксом _), проверяет их домашние директории и выявляет аккаунты с привилегиями суперпользователя (UID 0).
OUTDIR="$(dirname "$0")/../logs"
mkdir -p "$OUTDIR"
DATE=$(date +%Y-%m-%d)
RESPOND="$OUTDIR/user-audit_${DATE}.log"

log(){
    echo "$@" | tee -a "$RESPOND"
}

log "current user:"
whoami | tee -a "$RESPOND"

log "UID GUI Group:"
id | tee -a "$RESPOND"

log "Users in system:"
dscl . list /Users | grep -v "^_" | tee -a "$RESPOND"

log "Home directories:"
dscl . list /Users NFSHomeDirectory | grep -v "^_" | tee -a "$RESPOND"

log "UID-0:"
dscl . list /Users UniqueID | awk '$2 == 0 {print $1}' | tee -a "$RESPOND"