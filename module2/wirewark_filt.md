Capture filters (фильтры захвата) — задаются до начала захвата. Уменьшают объём записываемого трафика. Синтаксис — BPF (Berkeley Packet Filter).
Примеры:
text
host 8.8.8.8          # только трафик с/на 8.8.8.8
port 443              # только порт 443
tcp                   # только TCP
udp                   # только UDP

Display filters (фильтры отображения) — задаются после захвата. Фильтруют то, что показывать. Синтаксис Wireshark.
Примеры:
text
ip.addr == 8.8.8.8
tcp.port == 443
dns
http
tls
tcp.flags.syn == 1
http.request.method == "GET"

основные display фильтры :
По IP:
ip.addr == 192.168.1.5          # любой трафик с/на IP
ip.src == 192.168.1.5           # только отправитель
ip.dst == 192.168.1.5           # только получатель
ip.addr == 192.168.1.0/24       # вся подсеть

По порту:
tcp.port == 443
udp.port == 53
tcp.srcport == 80
tcp.dstport == 443

По протоколу:
tcp
udp
dns
http
tls
arp
icmp

Комбинированные:
ip.addr == 192.168.1.5 && tcp.port == 443
ip.src == 192.168.1.5 || ip.src == 192.168.1.6
!(arp || dns)                    # исключить ARP и DNS
http.request.method == "POST"
tcp.flags.syn == 1 && tcp.flags.ack == 0   # только SYN (начало соединения)

tcpdump — альтернатива без графики
Если Wireshark нет, или нужно записать трафик на сервере без GUI — используется tcpdump.

sudo tcpdump -i en0                       # весь трафик (Ctrl+C)
sudo tcpdump -i en0 -c 10                 # 10 пакетов и стоп
sudo tcpdump -i en0 port 80               # только порт 80
sudo tcpdump -i en0 host 8.8.8.8          # только хост
sudo tcpdump -i en0 -w capture.pcap       # сохранить в файл
sudo tcpdump -r capture.pcap              # читать из файла
sudo tcpdump -i en0 -A port 80            # показать ASCII-содержимое
В SOC: tcpdump на сервере — стандарт для быстрого захвата. Потом .pcap открывают в Wireshark.

Рукопожатия
tcp.flags.syn == 1 покажет SYN и SYN-ACK. 
tcp.flags.ack == 1 && tcp.flags.syn == 0 — чистые ACK.