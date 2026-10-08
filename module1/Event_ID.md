# Windows Event ID — конспект для SOC

Ключевые Event ID из Windows Security / System логов, которые нужно знать на позиции SOC L1.

## Таблица из 10 Event ID

| Event ID | Название | Что означает | Почему важен для SOC | Пример атаки |
|----------|----------|--------------|----------------------|--------------|
| **4624** | Successful Logon | Успешный вход в систему. Содержит Logon Type, Account Name, Source IP, Logon ID | Кто и когда вошёл. Logon Type 3 (Network) и 10 (RDP) — основа для детекта латерального перемещения | Pass-the-Hash, RDP-доступ к чужим хостам |
| **4625** | Failed Logon | Неудачная попытка входа. Содержит Logon Type, Status, Sub Status, Workstation Name | Признак брутфорса / password spraying. Всплеск 4625 с одного IP или по разным учёткам — красный флаг | Brute-force, password spraying |
| **4648** | Logon with Explicit Credentials | Вход с явно переданными учётными данными (runas, net use). Один из самых высокосигнальных ID | Легитимное использование редко. Помогает ловить использование украденных credential'ов | Pass-the-Hash, запуск процессов от имени другого пользователя |
| **4672** | Special Privileges Assigned | Специальные привилегии назначены новому логону (админский вход). Срабатывает на каждом админском логоне | Шумный, но 4672 от аккаунта, который не должен быть админом — чистый сигнал privilege escalation | Privilege Escalation, компрометация админской учётки |
| **4688** | Process Creation | Создание процесса. С включённым command-line auditing содержит полную командную строку и parent process | Реконструкция цепочки выполнения. Что запустил злоумышленник после входа | Запуск CMD/PowerShell, выполнение полезной нагрузки |
| **4720** | User Account Created | Создана новая учётная запись пользователя | Backdoor / persistence. Атакующий создаёт аккаунт для повторного доступа | Создание скрытого админского аккаунта |
| **4732** | Member Added to Security Group | Пользователь добавлен в локальную группу безопасности (например, Administrators) | Повышение привилегий. Атакующий добавляет себя в админы | Privilege Escalation, persistence |
| **5140** | Network Share Accessed | Доступ к сетевой папке (C$, ADMIN$, IPC$) | Латеральное перемещение через SMB. Кто и куда ходил по сети | SMB lateral movement, доступ к админским шарам |
| **7045** | New Service Installed | Установлена новая служба (System log, не Security) | Классика для PsExec, Cobalt Strike, ransomware loaders. Новый сервис от нетипичного пользователя — тревога | PsExec, Service Execution |
| **1102** | Audit Log Cleared | Журнал аудита очищен (Security log) | Практически нет легитимных причин. Прямой признак заметания следов. Всегда алерт | Defense Evasion, covering tracks |

## Logon Types (для контекста 4624 / 4625)

| Type | Название | Что означает |
|------|----------|--------------|
| 2 | Interactive | Локальный вход за клавиатурой |
| 3 | Network | SMB, доступ к шарам, WinRM |
| 4 | Batch | Запланированные задачи |
| 5 | Service | Запуск службы |
| 10 | RemoteInteractive | RDP, Terminal Services |

## Quick reference для SOC L1

- **4624 + Type 10** от не-jump-host → возможный RDP lateral movement
- **Всплеск 4625** → брутфорс / password spraying
- **4648** → высокий сигнал, редкий легитимный use case
- **4672** от нетипичного аккаунта → privilege escalation
- **1102** → всегда инцидент

## Где смотреть

- Security log — 4624, 4625, 4648, 4672, 4688, 4720, 4732, 5140
- System log — 7045
- Очистка Security log — 1102 (в самом Security log)
