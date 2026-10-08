1. curl -I https://google.com

Вывод:

text
HTTP/2 301
location: https://www.google.com/
content-type: text/html; charset=UTF-8
server: gws
content-length: 220
alt-svc: h3=":443"; ma=2592000
Статус-код: 301
Версия HTTP: HTTP/2
Сервер: gws (Google Web Server)
Content-Type: text/html; charset=UTF-8
HSTS: в этом ответе нет (приходит уже с www.google.com)
Разбор: Google отвечает 301 и редиректит на https://www.google.com/. Соединение по HTTP/2, alt-svc сообщает, что доступен HTTP/3 (QUIC) на порту 443. Заголовок content-security-policy-report-only — политика безопасности контента в режиме отчётов.

2. curl -I http://example.com

Вывод:

text
HTTP/1.1 200 OK
Date: Thu, 01 Oct 2026 14:47:54 GMT
Content-Type: text/html; charset=utf-8
Connection: keep-alive
Server: cloudflare
Last-Modified: Mon, 28 Sep 2026 16:19:32 GMT
Allow: GET, HEAD
Accept-Ranges: bytes
Age: 1320
cf-cache-status: HIT
CF-RAY: a43c43e5ac464150-AMS
Статус-код: 200
Версия HTTP: HTTP/1.1
Сервер: cloudflare
Content-Type: text/html; charset=utf-8
HSTS: нет
Разбор: сайт отдаёт контент по HTTP (незашифрованно). Это опасно, потому что данные идут в открытом виде. HSTS отсутствует, редиректа на HTTPS нет — любой посредник в сети может прочитать или подменить страницу. cf-cache-status: HIT — ответ отдан из кэша Cloudflare.

3. curl -I https://github.com

Вывод (из curl -v):

text
HTTP/2 200
server: GitHub.com
content-type: text/html; charset=utf-8
strict-transport-security: max-age=31536000; includeSubDomains; preload
Статус-код: 200
Версия HTTP: HTTP/2
Сервер: GitHub.com
Content-Type: text/html; charset=utf-8
HSTS: max-age=31536000; includeSubDomains; preload
Разбор: GitHub отдаёт контент по HTTPS через HTTP/2. HSTS с max-age=31536000 (1 год), includeSubDomains и preload — браузер год будет обращаться к GitHub только по HTTPS, включая поддомены. preload означает, что домен может быть вшит в список HSTS внутри браузеров.

4. curl -I http://github.com

Вывод:

text
HTTP/1.1 301 Moved Permanently
Content-Length: 0
Location: https://github.com/
Статус-код: 301
Location: https://github.com/
Версия HTTP: HTTP/1.1
Разбор: GitHub принудительно редиректит с HTTP на HTTPS. Это стандарт безопасности — все данные должны идти по шифрованному каналу. Content-Length: 0 — тело ответа пустое, только заголовки.

5. curl -v https://github.com

Вывод (ключевые строки):

text
* Host github.com:443 was resolved.
* IPv4: 140.82.121.4
*   Trying 140.82.121.4:443...
* Connected to github.com (140.82.121.4) port 443
* ALPN: curl offers h2,http/1.1
* SSL connection using TLSv1.3 / AEAD-CHACHA20-POLY1305-SHA256
* Server certificate:
*  subject: CN=github.com
*  issuer: C=GB; O=Sectigo Limited; CN=Sectigo Public Server Authentication CA DV E36
* using HTTP/2
> GET / HTTP/2
> Host: github.com
> User-Agent: curl/8.7.1
> Accept: */*
< HTTP/2 200
< server: GitHub.com
< content-type: text/html; charset=utf-8
< strict-transport-security: max-age=31536000; includeSubDomains; preload
IP-адрес: 140.82.121.4
Порт: 443
Версия TLS: TLSv1.3 / AEAD-CHACHA20-POLY1305-SHA256
Сертификат (subject): CN=github.com
Кто выдал (issuer): C=GB; O=Sectigo Limited; CN=Sectigo Public Server Authentication CA DV E36
Срок действия: Sep 1 2026 — Nov 29 2026
Заголовки запроса (строки с >): GET / HTTP/2, Host: github.com, User-Agent: curl/8.7.1, Accept: */*
Заголовки ответа (строки с <): HTTP/2 200, server: GitHub.com, content-type: text/html; charset=utf-8, strict-transport-security: ...
Разбор: curl разрешил github.com в 140.82.121.4, подключился на порт 443, прошёл TLS 1.3 с шифром ChaCha20-Poly1305. Сертификат выдан Sectigo (DV — Domain Validation), CN совпадает с хостом. ALPN согласовал HTTP/2.
