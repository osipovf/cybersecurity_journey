#!/bin/bash
#скрипт считает количество файлов в аргументе, а также количество файлов с разрешением md sh
DIR=$1

#проверка что аргумент передан 
if [ -z $DIR ]; then
    echo "use file-audit-v2.sh for <road_to_file>"
    exit 1
fi

#проверка что это файл и он существует
if [! -d $DIR ]; then
    echo "Error- $DIR is not direction"
    exit 1
fi

OUTDIR="$(dirname "$0")/../logs" 
mkdir -p "$OUTDIR"
DATE=$(date +%Y-%m-%d-%H-%M-%S)
REPORT=$OUTDIR/log-analizer-v2_${DATE}.log

DATE=$(date +%Y-%d-%m)
DATA="$OUTDIR/file-audit-v2_${DATE}.txt"

TOTAL=$(find "$DIR" -type f | wc -l)
MD=$(find "$DIR" -name "*.md" -type f |wc -l)
SH=$(find "$DIR" -name "*.sh" -type f | wc -l)

echo "____Data information____" | tee -a "$DATA"
echo "Direction:$DIR"| tee -a "$DATA"
echo "Total files:$TOTAL" | tee -a "$DATA"
echo ".md file count:$MD" | tee -a "$DATA" 
echo ".sh file count:$SH" | tee -a "$DATA"
echo "--- Files List ---" | tee -a "$DATA"
ls -lh "$DIR" | tee -a "$DATA"

echo ""
echo " DATA save: $DATA"

