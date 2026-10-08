ls — list. Список файлов
ls           # просто имена
ls -l        # подробно (права, размер, дата)
ls -la       # + скрытые файлы
ls -lh       # размер в KB/MB
ls -la /etc  # список /etc

cd — change directory.
cd /etc          # перейти в /etc
cd ..            # на уровень выше
cd ~             # в домашнюю
cd -             # в предыдущую

rm — remove.
rm file.txt        # удалить файл
rm -r folder/      # удалить папку рекурсивно
rm -rf folder/     # без подтверждения (ОПАСНО)

cp — copy.
cp file.txt backup.txt
cp -r folder/ backup/   # рекурсивно

mv — move / rename.
mv old.txt new.txt       # переименовать
mv file.txt /tmp/        # переместить

Просмотр файлов: cat, less, head, tail, nano:
cat — показать содержимое.
cat file.txt
cat file1.txt file2.txt   # несколько

less — постранично (выход — q).
less bigfile.log

head / tail — первые / последние строки.
head file.txt       # 10 строк
head -20 file.txt   # 20 строк
tail file.txt       # последние 10
tail -f log.txt     # следить в реальном времени (Ctrl+C для выхода)

nano — редактор.
nano file.txt
# Ctrl+O — сохранить
# Ctrl+X — выйти

Поиск: grep, find, which
grep — поиск строк по тексту.
grep "error" file.log          # строки с error
grep -i "error" file.log       # без учёта регистра
grep -c "error" file.log       # подсчёт
grep -v "error" file.log       # инверсия (без error)
grep -r "error" /var/log/      # рекурсивно
grep -E "err|warn" file.log    # регулярка (или)
grep -B 2 -A 2 "error" file    # 2 строки до и после

find — поиск файлов.
find . -name "*.md"            # все .md в текущей папке
find / -name "passwd" 2>/dev/null  # по всей системе, без ошибок
find . -type f                 # только файлы
find . -type d                 # только папки
find . -size +10M              # файлы больше 10 МБ

which — где находится программа.
which python3     # /usr/bin/python3
which git         # /usr/bin/git

Pipe, редиректы:
ps aux | grep python           # процессы python
ls -la | grep ".md"            # только .md-файлы
cat file.log | wc -l           # подсчёт строк
history | grep dig             # команды с dig в истории
Редиректы:
> — записать в файл (перезаписать).
>> — добавить в конец.
2> — перенаправить ошибки.
2>&1 — ошибки туда же, куда обычный вывод.
echo "привет" > file.txt       # перезаписать
echo "ещё" >> file.txt         # добавить
ls /nonexistent 2> errors.txt  # ошибки в файл
command > output.txt 2>&1      # и вывод, и ошибки

Условия: if, then, else, fi:
if [ условие ]; then
    # что делать, если истина
elif [ другое_условие ]; then
    # если первое ложно, а это истина
else
    # если всё ложно
fi
Операторы для строк
[ -z "$VAR" ] — истина, если строка пустая.
[ -n "$VAR" ] — истина, если строка не пустая.
Операторы для чисел:
[ "$A" -eq "$B" ] — равно.
[ "$A" -ne "$B" ] — не равно.
[ "$A" -gt "$B" ] — больше.
[ "$A" -lt "$B" ] — меньше.
[ "$A" -ge "$B" ] — больше или равно.
Операторы для файлов:
[ -e "$FILE" ] — существует.
[ -f "$FILE" ] — это файл.
[ -d "$FILE" ] — это папка.
[ -r "$FILE" ] — можно читать.
[ -w "$FILE" ] — можно писать.
[ -x "$FILE" ] — можно выполнять.
[ ! -f "$FILE" ] — не файл (! = отрицание).

Циклы: for, while
for:
for i in 1 2 3 4 5; do
    echo "Число: $i"
done
По файлам:
for FILE in *.txt; do
    echo "Файл: $FILE"
done
По массиву:
PORTS=(22 80 443 3306)
for PORT in "${PORTS[@]}"; do
    echo "Порт: $PORT"
done
По строкам файла:
while read LINE; do
    echo "Строка: $LINE"
done < file.txt

while:

COUNT=1
while [ $COUNT -le 5 ]; do
    echo "Итерация $COUNT"
    COUNT=$((COUNT + 1))
done

Функции:
log() {
    echo "$@" | tee -a "$LOGFILE"
}
#$@ — все аргументы функции.
log "Сообщение"
log "Ещё одно"
Подстановка команд: $(...):
DATE=$(date +%Y-%m-%d)         # результат date в переменную
FILES=$(ls)                    # список файлов
COUNT=$(ls | wc -l)            # число файлов
SCRIPT_DIR="$(dirname "$0")"   # папка скрипта
Как работает: bash выполняет команду в $(...) и подставляет её вывод.

awk — обработка колонок.
awk '{print $1}' file.log            # первая колонка
awk '{print $1, $3}' file.log        # первая и третья
awk -F: '{print $1}' /etc/passwd     # разделитель :
awk '$9 == 404 {print $7}' access.log  # только 404, вывести путь

sed — замена текста.
sed 's/old/new/' file.log            # заменить первое в строке
sed 's/old/new/g' file.log           # заменить все
sed -n '10,20p' file.log             # строки 10-20

sort — сортировка.
sort file.log                # алфавитно
sort -n file.log             # численно
sort -r file.log             # в обратном порядке
sort -nrk 3 file.log         # по 3-й колонке, численно, обратно
sort file              # по алфавиту (лексикографически)
sort -n file           # по числовому значению (2 < 10, а не "10" < "2")
sort -r file           # reverse — в обратном порядке
sort -rn file          # числовой + обратный
sort -u file           # unique — убрать дубликаты (как sort | uniq, но быстрее)
sort -k2 file          # сортировать по 2-му столбцу
sort -k2 -n file       # по 2-му столбцу численно
sort -t: -k3 -n file   # разделитель ':', сортировать по 3-му полю численно
sort -h file           # human-readable (1K < 1M < 1G)
sort -f file           # игнорировать регистр

uniq — уникальные строки.
sort file.log | uniq         # убрать дубликаты
sort file.log | uniq -c      # с подсчётом
sort file.log | uniq -c | sort -rn   # по частоте

uniq file              # убрать соседние дубликаты
uniq -c file           # count — добавить счётчик повторений (число + строка)
uniq -d file           # только дублирующиеся строки
uniq -u file           # только уникальные (встречаются 1 раз)

wc — word count.
wc -l file.log               # строк
wc -w file.log               # слов
wc -c file.log               # байт

cut — вырезать колонки.
cut -d: -f1 /etc/passwd      # 1-я колонка, разделитель :
cut -d, -f2,3 file.csv       # 2-я и 3-я

tr — замена символов.
echo "HELLO" | tr 'A-Z' 'a-z'   # hello

xargs — передать вывод как аргументы.
find . -name "*.md" | xargs wc -l    # посчитать строки во всех .md

su — switch user
su                      # стать root (нужен пароль root)
su -                    # стать root с его окружением (login shell)
su - username           # стать пользователем username с его окружением
su username             # стать username, но окружение остаётся твоё
su -c "команда"         # выполнить одну команду от имени root
su - username -c "cmd"  # выполнить команду от имени username

sudo — superuser do
sudo команда                    # выполнить от root
sudo -u username команда        # выполнить от другого пользователя
sudo -i                         # интерактивный root-shell (аналог su -)
sudo -s                         # root-shell с твоим окружением
sudo -k                         # "забыть" кэш пароля
sudo -l                         # показать, что тебе разрешено
sudo -v                         # обновить таймстамп пароля
sudo !!                         # повторить последнюю команду с sudo

2>/dev/null— специальный файл-«чёрная дыра». Всё, что туда пишется, исчезает.


Констркуции из скиптов:

pgrep -f "splunkd" > /dev/null
(((((pgrep — найти PID процесса по имени.
-f — искать по полной командной строке, а не только по имени.
"splunkd" — что искать.
> /dev/null — выкинуть вывод (нам важен только код возврата).)))))

grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$FILE"
grep -o — вывести только совпадение, не всю строку.
-E — расширенная регулярка.
\b — граница слова.
([0-9]{1,3}\.){3}[0-9]{1,3} — паттерн IP: 1-3 цифры, точка, три раза, потом 1-3 цифры.

SPLUNK_PASS="${SPLUNK_PASS:-}" — если переменная окружения SPLUNK_PASS установлена, взять её. Если нет — пустая строка. ${VAR:-default} — значение по умолчанию.

CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000)
-s — silent.
-o /dev/null — выбросить тело ответа.
-w "%{http_code}" — вывести только HTTP-код.
$(...) — записать в CODE.