#!/bin/bash
# lab-status.sh — проверка состояния SOC-лаборатории

OUTDIR="$(dirname "$0")/../logs"
mkdir -p "$OUTDIR"
DATE=$(date +%Y-%m-%d)
RESPOND="$OUTDIR/lab-status_${DATE}.log"

# Пароль Splunk из переменной окружения
SPLUNK_PASS="${SPLUNK_PASS:-}" #если переменная окружения SPLUNK_PASS не задана, подставить пустую строку
SPLUNK_BIN="/Applications/Splunk/bin/splunk" # путь к бинарнику Splunk на macOS.

# Функция логирования: на экран + в файл
log() {
    echo "$@" | tee -a "$RESPOND"
}

log "=== LAB STATUS ==="
log "Date: $(date)"
log ""

# 1. Wireshark
if [ -d "/Applications/Wireshark.app" ]; then
    log "Wireshark: INSTALLED"
else
    log "Wireshark: NOT INSTALLED"
fi

# 2. Splunk процесс
if pgrep -f "splunkd" > /dev/null; then #ищет процессы, у которых в полной командной строке (-f = full) встречается splunkd. Возвращает PID, если нашёл
    log "Splunk process: RUNNING"
else
    log "Splunk process: STOPPED"
fi

# 3. Splunk Web
CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000) #curl -s — тихий режим (без прогресс-бара).
                                                                        #-o /dev/null — тело ответа выбросить.
                                                                        #-w "%{http_code}" — вывести только HTTP-код ответа.
                                                                        #Ожидаемо: 200 (работает), 302 (редирект на логин — тоже норма), 000 (сервер недоступен).
                                                                        #CODE=$(...) — результат curl сохраняем в переменную.
log "Splunk Web: HTTP $CODE"

# 4. Splunk search (если есть пароль и бинарь)
if [ -z "$SPLUNK_PASS" ]; then
    log "Splunk search: SKIPPED (SPLUNK_PASS not set)"
elif [ ! -x "$SPLUNK_BIN" ]; then
    log "Splunk search: SKIPPED (binary not found at $SPLUNK_BIN)"
else
    COUNT=$("$SPLUNK_BIN" search "index=main | stats count" -auth "admin:${SPLUNK_PASS}" 2>/dev/null | tail -1) #"$SPLUNK_BIN" search "index=main | stats count" — запускаем Splunk CLI в режиме поиска. SPL-запрос: взять все события из индекса main и посчитать их количество.
                                                                                                                #-auth "admin:${SPLUNK_PASS}" — логин/пароль для аутентификации.
                                                                                                                #2>/dev/null — ошибки stderr выбросить (чтобы не мусорить).
                                                                                                                #| tail -1 — взять последнюю строку вывода. Splunk CLI часто печатает служебные строки, а результат — в конце.
                                                                                                                #COUNT=$(...) — сохранить результат в переменную.
    log "Events in index main: $COUNT"
fi

log ""
log "=== END ==="