#Работа с портами:скрипт проверяет состояние ключевых системных портов (22, 80, 443, 3306) через lsof. Он выводит статус LISTEN, если служба запущена и ждет подключения, или NOT LISTEN, если порт свободен.


#!/bin/bash 

echo "PORT CHECK"
if lsof -i:22 | grep -q LISTEN;then #grep -q LISTEN	Отфильтровать строки со словом LISTEN. -q = quiet, не печатать, только вернуть «да/нет»
    echo "LISTEN:PORT22"
else
    echo "NOT LISTEN:PORT22"
fi

if lsof -i:80 | grep -q LISTEN;then
    echo "LISTEN:PORT80"
else
    echo "NOT LISTEN:PORT80"
fi

if lsof -i:443 | grep -q LISTEN;then
    echo "LISTEN:PORT443"
else
    echo "NOT LISTEN:PORT443"
fi

if lsof -i:3306 | grep -q LISTEN;then
    echo "LISTEN:PORT3306"
else
    echo "NOT LISTEN:PORT3306"
fi
