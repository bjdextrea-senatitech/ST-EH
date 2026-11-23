# Recetario de NMAP — 80 ejemplos para el pentester

> **Clase 04 · Explotación de servicios · SENATI.** Material de consulta rápida.
> Una línea de teoría por comando. Cámbialo `<objetivo>` por la IP o rango real.
> Regla de oro: **solo contra tu laboratorio o un alcance autorizado por escrito** (Ley 30096, art. 12).
>
> Objetivos del laboratorio de hoy (red `10.40.0.0/24`):
> `.5` fw · `.14` mssql(opcional) · `.21` ftp · `.22` ssh · `.33` db · `.38` rdp · `.45` files · `.63` cache

---

## 0. Antes de disparar: ¿cómo funciona nmap?

nmap manda paquetes a los puertos y **deduce el estado** por la respuesta:

| Respuesta del objetivo | Estado que reporta nmap | Qué significa |
|---|---|---|
| SYN/ACK | `open` | Hay un servicio escuchando |
| RST (reset) | `closed` | Nada escucha, pero el host responde |
| Nada (timeout) | `filtered` | Un firewall se traga el paquete |
| ICMP port-unreachable | `filtered` | Un firewall lo rechaza con ICMP |
| SYN/ACK en `-sA` | `unfiltered` | El ACK pasa el firewall (no sabemos si abierto) |

Hoy vas a **ver los cinco estados en vivo** en el host `.5` (el "gimnasio").

---

## 1. Descubrimiento de host (¿quién está vivo?)

```bash
# 1 · Barrido de ping: lista rápida de hosts vivos, sin escanear puertos
nmap -sn 10.40.0.0/24

# 2 · Solo mostrar los que están UP (salida "grepeable" para seguir con scripts)
nmap -sn 10.40.0.0/24 -oG - | grep Up

# 3 · Descubrimiento con ping ICMP echo (el "ping" clásico)
nmap -sn -PE 10.40.0.5

# 4 · Descubrimiento por TCP SYN a un puerto concreto (sirve si bloquean ICMP)
nmap -sn -PS80,443,22 10.40.0.5

# 5 · Descubrimiento por TCP ACK (otra forma de colarse por firewalls)
nmap -sn -PA80 10.40.0.5

# 6 · Descubrimiento por UDP (puerto cerrado devuelve ICMP unreachable)
nmap -sn -PU53 10.40.0.5

# 7 · NO hacer descubrimiento: tratar el host como vivo aunque no responda ping
nmap -Pn 10.40.0.5

# 8 · Solo listar objetivos (no envía ni un paquete): revisa tu rango antes de atacar
nmap -sL 10.40.0.0/24

# 9 · No resolver DNS (más rápido y silencioso)
nmap -sn -n 10.40.0.0/24
```

> El host `.5` **no responde ping** (DROP a ICMP echo). El ejemplo 3 dirá "host down";
> el 4 lo encuentra igual. Lección: si el ping falla, usa `-Pn` o `-PS`.

---

## 2. Escaneo de puertos: tipos de sondeo

```bash
# 10 · SYN scan ("half-open"), el predeterminado como root: rápido y discreto
sudo nmap -sS 10.40.0.21

# 11 · TCP connect scan: completa el 3-way handshake (sin root, pero más ruidoso)
nmap -sT 10.40.0.21

# 12 · UDP scan: lento pero imprescindible (DNS, SNMP, TFTP viven aquí)
sudo nmap -sU 10.40.0.5

# 13 · TCP + UDP a la vez
sudo nmap -sS -sU 10.40.0.5

# 14 · ACK scan: NO dice abierto/cerrado, dice filtered/unfiltered → mapea el firewall
sudo nmap -sA -p 22,80,443,8080,9999 10.40.0.5

# 15 · Window scan: variante del ACK que a veces distingue abierto de cerrado
sudo nmap -sW -p 22,80,443 10.40.0.5

# 16 · Null scan: paquete sin flags (evade filtros tontos)
sudo nmap -sN 10.40.0.21

# 17 · FIN scan: solo el flag FIN
sudo nmap -sF 10.40.0.21

# 18 · Xmas scan: FIN+PSH+URG ("árbol de navidad")
sudo nmap -sX 10.40.0.21

# 19 · Ping de un solo puerto para ver cómo responde (reason explica el porqué)
sudo nmap -sS -p 443 --reason 10.40.0.5
```

> En el `.5` el ejemplo 14 es la joya: 8080/9999 salen `filtered` (DROP) y 443 `unfiltered`
> (REJECT con reset). Así se **dibuja la política del firewall** sin tocar los servicios.

---

## 3. Selección de puertos

```bash
# 20 · Un puerto
nmap -p 22 10.40.0.22

# 21 · Varios puertos sueltos
nmap -p 21,22,80,445,3306 10.40.0.0/24

# 22 · Rango de puertos
nmap -p 1-1000 10.40.0.33

# 23 · TODOS los 65535 puertos (encuentra servicios escondidos en puertos raros)
nmap -p- 10.40.0.63

# 24 · Los 100 más comunes (rápido)
nmap -F 10.40.0.33

# 25 · Top-N puertos por frecuencia estadística
nmap --top-ports 20 10.40.0.0/24

# 26 · Puertos por protocolo: T:TCP U:UDP
sudo nmap -p T:80,443,U:53,161 10.40.0.5

# 27 · Todos los puertos pero rápido (tasa alta, cuidado en redes reales)
nmap -p- --min-rate 2000 10.40.0.63
```

> **Clave del día:** en `.63` (Redis) el top-1000 no ve nada; `-p-` (ejemplo 23) revela
> el 6379. Moraleja: *un top-ports limpio no significa que el host esté limpio.*

---

## 4. Detección de servicios y versiones

```bash
# 28 · Detección de versión: nombre y versión exacta del software (base para buscar CVEs)
nmap -sV 10.40.0.21

# 29 · Intensidad de la detección (0=ligero … 9=agresivo)
nmap -sV --version-intensity 9 10.40.0.21

# 30 · Mostrar el "banner" crudo que devuelve el servicio
nmap -sV --script banner -p 21 10.40.0.21

# 31 · Detección de SO (necesita root; poco fiable contra contenedores)
sudo nmap -O 10.40.0.22

# 32 · "Agresivo": versión + SO + scripts por defecto + traceroute, todo junto
nmap -A 10.40.0.33

# 33 · Light: adivina el SO sin tanto paquete
sudo nmap -O --osscan-limit 10.40.0.22
```

> `-sV` sobre `.21` imprime **vsftpd 2.3.4** → tu señal para buscar CVE-2011-2523.
> Sobre `.22` sale **OpenSSH 8.2p1 Ubuntu** y sobre `.33` **MariaDB** y **Apache 2.4.58**.

---

## 5. NSE — el motor de scripts (lo que separa a un pro)

```bash
# 34 · Scripts por defecto (seguros y útiles): títulos web, certs, info básica
nmap -sC 10.40.0.33

# 35 · Toda una categoría: "default" y "safe"
nmap --script "default,safe" 10.40.0.33

# 36 · Un script concreto
nmap -p 21 --script ftp-anon 10.40.0.21

# 37 · Varios scripts
nmap -p 21 --script ftp-anon,ftp-syst,banner 10.40.0.21

# 38 · Comodín: todos los scripts "ftp-*"
nmap -p 21 --script "ftp-*" 10.40.0.21

# 39 · Categoría "vuln": comprueba vulnerabilidades conocidas
nmap -p 21 --script vuln 10.40.0.21

# 40 · El que resuelve el reto FTP de hoy: detecta la puerta trasera 2.3.4
nmap -p 21 --script ftp-vsftpd-backdoor 10.40.0.21

# 41 · Pasar argumentos a un script
nmap -p 22 --script ssh-auth-methods --script-args="ssh.user=rhuaman" 10.40.0.22

# 42 · Ver qué hace un script antes de lanzarlo
nmap --script-help ftp-vsftpd-backdoor

# 43 · Actualizar la base de datos de scripts
sudo nmap --script-updatedb
```

---

## 6. NSE por servicio (el catálogo que usarás hoy)

### FTP — `.21`
```bash
# 44 · Login anónimo
nmap -p 21 --script ftp-anon 10.40.0.21
# 45 · Sistema operativo según el servidor FTP
nmap -p 21 --script ftp-syst 10.40.0.21
# 46 · Backdoor vsftpd 2.3.4 (CVE-2011-2523)
nmap -p 21 --script ftp-vsftpd-backdoor 10.40.0.21
```

### SSH — `.22`
```bash
# 47 · Métodos de autenticación aceptados (¿password? ¿solo llave?)
nmap -p 22 --script ssh-auth-methods --script-args="ssh.user=rhuaman" 10.40.0.22
# 48 · Algoritmos y claves del host
nmap -p 22 --script ssh2-enum-algos 10.40.0.22
# 49 · Huella (fingerprint) de la llave del servidor
nmap -p 22 --script ssh-hostkey 10.40.0.22
```

### SMB — `.45`
```bash
# 50 · Dialectos SMB soportados (SMB1/2/3)
nmap -p 445 --script smb-protocols 10.40.0.45
# 51 · ¿Exige firma de mensajes? (si no, abre la puerta a relay)
nmap -p 445 --script smb2-security-mode 10.40.0.45
# 52 · Capacidades SMB2
nmap -p 445 --script smb2-capabilities 10.40.0.45
# 53 · Intento de enumerar recursos compartidos (en este lab se hace mejor con smbclient)
nmap -p 445 --script smb-enum-shares 10.40.0.45
```

### MySQL / MariaDB — `.33`
```bash
# 54 · Info del servidor MySQL (versión, capacidades)
nmap -p 3306 --script mysql-info 10.40.0.33
# 55 · ¿root sin contraseña?
nmap -p 3306 --script mysql-empty-password 10.40.0.33
# 56 · Bases de datos visibles con una credencial
nmap -p 3306 --script mysql-databases --script-args="mysqluser=webapp,mysqlpass=W3bApp#2023" 10.40.0.33
# 57 · Usuarios de MySQL
nmap -p 3306 --script mysql-users --script-args="mysqluser=webapp,mysqlpass=W3bApp#2023" 10.40.0.33
```

### Redis — `.63`
```bash
# 58 · Info de Redis (versión → CVE-2022-0543)
nmap -p 6379 --script redis-info 10.40.0.63
```

### RDP — `.38`
```bash
# 59 · Cifrado y nivel de seguridad del RDP
nmap -p 3389 --script rdp-enum-encryption 10.40.0.38
# 60 · Info NTLM que a veces filtra el nombre de máquina/dominio
nmap -p 3389 --script rdp-ntlm-info 10.40.0.38
```

### HTTP — `.5` y `.33`
```bash
# 61 · Título de la página
nmap -p 80 --script http-title 10.40.0.5
# 62 · Cabeceras HTTP (servidor, tecnologías)
nmap -p 8080 --script http-headers 10.40.0.33
# 63 · Enumerar rutas comunes (/admin, /uploads, robots.txt…)
nmap -p 8080 --script http-enum 10.40.0.33
# 64 · Métodos HTTP permitidos (PUT, DELETE…)
nmap -p 8080 --script http-methods 10.40.0.33
```

### MSSQL — `.14` (opcional)
```bash
# 65 · Info de SQL Server
nmap -p 1433 --script ms-sql-info 10.40.0.14
# 66 · Fuerza bruta a 'sa' con un diccionario
nmap -p 1433 --script ms-sql-brute --script-args="userdb=usuarios.txt,passdb=dicc.txt" 10.40.0.14
```

---

## 7. Tiempo, sigilo y evasión

```bash
# 67 · Plantillas de tiempo: -T0 (paranoico) … -T5 (loco). T4 = rápido y usable
nmap -T4 10.40.0.33

# 68 · Puerto de origen falso 53 (DNS): se cuela por firewalls que "confían" en DNS
sudo nmap -sS -g 53 -p 9999 10.40.0.5

# 69 · Fragmentar paquetes para despistar IDS sencillos
sudo nmap -f 10.40.0.21

# 70 · Señuelos: mezcla tu IP entre direcciones falsas
sudo nmap -D RND:5 10.40.0.21

# 71 · MTU personalizado (otra forma de fragmentar)
sudo nmap --mtu 16 10.40.0.21

# 72 · Controlar la velocidad de paquetes (sigilo o fuerza)
nmap --max-rate 50 10.40.0.21

# 73 · Retraso entre sondas (muy sigiloso)
nmap --scan-delay 1s -p 22,80 10.40.0.21
```

> El ejemplo 68 es el que **abre el panel oculto del `.5`**: el 9999 solo responde a
> tráfico cuyo puerto de origen es 53. Un escaneo normal lo ve `filtered`; con `-g 53`, `open`.

---

## 8. Salida, evidencia y reportes

```bash
# 74 · Guardar en los 3 formatos a la vez (normal, grepeable, XML). ¡Siempre para evidencia!
nmap -sV -oA evidencia/qhapaq_db 10.40.0.33

# 75 · Solo formato normal
nmap -sV -oN db.txt 10.40.0.33

# 76 · Formato grepeable (para awk/grep)
nmap -sV -oG db.grep 10.40.0.33

# 77 · XML (para importar a Metasploit, o convertir a HTML)
nmap -sV -oX db.xml 10.40.0.33

# 78 · Convertir el XML a un informe HTML legible
xsltproc db.xml -o db.html

# 79 · Verboso + mostrar el motivo de cada estado (ideal para aprender)
nmap -v --reason 10.40.0.5

# 80 · Reanudar un escaneo interrumpido desde su salida normal
nmap --resume db.txt
```

---

## 9. Chuletas finales

**El escaneo "primer contacto" de todo pentest:**
```bash
sudo nmap -sS -sV -sC -T4 -p- -oA evidencia/<host> <objetivo>
```

**El escaneo UDP que casi todos olvidan (y donde está el TFTP de hoy):**
```bash
sudo nmap -sU --top-ports 50 -oA evidencia/<host>-udp <objetivo>
```

**Recuerda la cadena de hoy:**
`.5` dibuja el firewall (estados + `-g 53` + UDP/TFTP) → `.21` versión FTP → CVE →
`.45` SMB filtra la llave → `.22` SSH → `.33` MySQL→webshell → `.63` Redis → root.

> Todo lo que hagas déjalo con `-oA` y `date -Is`. **Sin evidencia, no hubo pentest.**
