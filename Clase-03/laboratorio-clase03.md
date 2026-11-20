# Laboratorio Clase 03 · Reconocimiento y enumeración

**SENATI · DC05 Ethical Hacking y Seguridad Ofensiva · Capítulo 3 del sílabo**
Reconocimiento pasivo y activo · Google Dorking · OSINT · Shodan · theHarvester · Nmap avanzado · Fingerprinting de servicios

Un pentester profesional pasa más tiempo **mirando** que atacando. Hoy recorres las dos mitades del reconocimiento:

- **Pasivo (OSINT):** todo lo que se puede saber de una organización, una persona o una foto **sin tocar sus sistemas**.
- **Activo:** escanear y conversar con cada servicio de la red interna de *Inversiones Qhapaq SAC* hasta sacarle todo lo que dice de sí mismo.

Al final entregas un **mapa de la superficie de ataque**: la materia prima de la Clase 04 (explotación).

---

## Reglas de esta clase (léelas antes de empezar)

1. **Pasivo = mirar, no tocar.** Si una herramienta te muestra una IP expuesta en Shodan, la anotas. **No te conectas a ella.**
2. **Personas: solo tú.** Las herramientas de usuarios y correos (WhatsMyName, Namechk, Maigret, Blackbird, holehe) se usan con **tu propio** usuario y **tu propio** correo, o con los de un compañero que te dé permiso **en voz alta y delante del docente**. Nunca con terceros. Es tratamiento de datos personales (Ley 29733).
3. **Activo: solo el alcance.** En la red de Qhapaq, `10.30.0.250` aparece en su DNS pero es de un tercero. **No se toca.** Sus visitas quedan registradas.
4. **Las credenciales que encuentres hoy NO se usan.** Se anotan en el mapa de superficie para la Clase 04.

---

## Agenda (240 min)

| Tiempo | Bloque | Tipo |
|---|---|---|
| 20 min | Teoría (PPT) | — |
| 10 min | Lab 0 · Entorno y carpeta de trabajo | — |
| 40 min | Lab 1 · OSINT de organizaciones: dorks, certificados, theHarvester, DNS, tecnologías | Pasivo |
| 20 min | Lab 2 · Buscadores de dispositivos: Shodan y Censys | Pasivo |
| 30 min | Lab 3 · OSINT de personas: tu propia huella digital | Pasivo |
| 10 min | Pausa | |
| 25 min | Lab 4 · OSINT de imágenes: metadatos, ELA y búsqueda inversa | Pasivo |
| 60 min | Lab 5 · Reconocimiento activo de la red interna de Qhapaq | Activo |
| 25 min | Lab 6 · Mapa de superficie de ataque y entrega | Reporte |

**Meta mínima:** Labs 1, 3 y 4 con evidencias + banderas 05 a 08.
**Meta completa:** las 6 banderas (05 a 10) + mapa de superficie completo con la correlación pasivo ↔ activo.

---

## Lab 0 · Entorno (10 min)

> **Tarea previa obligatoria:** instala las herramientas y construye el laboratorio **antes** de la clase. Tarda entre 10 y 15 minutos y descarga paquetes.

Todo se hace en tu Kali (VM de VirtualBox o Kali en WSL con Docker instalado **dentro** de Kali).

> 👤 **Trabaja con tu usuario normal, no como root.** Si tu prompt dice `root@...` o termina en `#`, escribe `exit`. Todo lo que dice `~` en esta guía es tu carpeta personal (`/home/tu_usuario`). Como root, `~` sería `/root` y el script de verificación no encontraría tus herramientas. Usa `sudo` solo donde la guía lo indica.

### 0.0 Descargar la clase desde GitHub

Las clases están en el repositorio `ST-EH`. **No** copies la dirección que ves en el navegador al abrir la carpeta:

```bash
git clone https://github.com/bjdextrea-senatitech/ST-EH/tree/main/Clase-03   # ❌ falla: "repository not found"
```
`git clone` solo sabe clonar **repositorios completos** (`.../ST-EH.git`). La parte `/tree/main/Clase-03` es la página web con la que GitHub **muestra** una carpeta. No es un repositorio.

**Opción A · Git, solo la carpeta de la clase (recomendada)**

Si es la primera vez que descargas una clase:

```bash
sudo apt install -y git
cd ~
git clone --filter=blob:none --sparse https://github.com/bjdextrea-senatitech/ST-EH.git
cd ~/ST-EH
git sparse-checkout set Clase-03
ln -sfn ~/ST-EH/Clase-03 ~/Clase-03
ls ~/Clase-03
```
- `--filter=blob:none` descarga el índice del repositorio, pero no el contenido de los archivos todavía.
- `--sparse` deja la carpeta vacía, salvo los archivos de la raíz.
- `git sparse-checkout set Clase-03` le dice a Git que **solo** descargue y llene esa carpeta.
- `ln -sfn` crea un acceso directo `~/Clase-03`, que es la ruta que usa esta guía.

Si ya tienes `~/ST-EH` de una clase anterior, **no vuelvas a clonar**. Solo agrega la carpeta nueva:

```bash
cd ~/ST-EH
git pull
git sparse-checkout add Clase-03
ln -sfn ~/ST-EH/Clase-03 ~/Clase-03
```
`git pull` trae lo último que publicó el docente; `add` suma la carpeta nueva **sin quitar** las anteriores.

Si el docente corrige algo después, actualizas con `cd ~/ST-EH && git pull`.

**Opción B · Git, todo el repositorio (todas las clases)**

Si prefieres tener todas las clases de una vez:

```bash
cd ~
git clone https://github.com/bjdextrea-senatitech/ST-EH.git
ln -sfn ~/ST-EH/Clase-03 ~/Clase-03
ls ~/Clase-03
```
Sin `--sparse`, Git descarga **todas** las carpetas del repositorio. El acceso directo `~/Clase-03` sigue siendo necesario porque esta guía usa esa ruta. Para las clases siguientes basta con `cd ~/ST-EH && git pull`.

**Opción C · Sin Git (ZIP)**

En el navegador, abre `github.com/bjdextrea-senatitech/ST-EH`, haz clic en el botón verde **Code** y luego en **Download ZIP**. Ese ZIP trae **todas** las clases. Después:

```bash
cd ~
unzip ~/Downloads/ST-EH-main.zip
cp -r ~/ST-EH-main/Clase-03 ~/Clase-03
```
Con esta opción no puedes actualizar con `git pull`: si hay correcciones, tienes que descargar el ZIP otra vez.

### 0.1 Herramientas del sistema

```bash
sudo apt update
sudo apt install -y docker.io docker-compose nmap dnsutils curl netcat-openbsd openssl smbclient snmp onesixtyone redis-tools whatweb libimage-exiftool-perl xsltproc theharvester pipx git unzip python3-dev build-essential
```
`apt install` instala de una vez todo lo de la clase: escáner, clientes de cada protocolo (DNS, SMB, SNMP, Redis), metadatos de imágenes y theHarvester. `python3-dev` y `build-essential` sirven para compilar dependencias de Blackbird (por ejemplo `aiohttp`) en las versiones nuevas de Python que trae Kali.

> Si `apt update` muestra un error de firma en un repositorio de **NVIDIA/CUDA** ("SHA1 is not considered secure"), ese repositorio externo usa una firma que Kali ya no acepta. No afecta a la clase. Desactívalo con `grep -rl nvidia /etc/apt/sources.list.d/` y cambia el nombre de ese archivo agregándole `.disabled` al final.

### 0.2 Herramientas OSINT de Python (aisladas con pipx)

> ⚠️ Haz **todo** el Lab 0.2 y el 0.4 con el **mismo usuario**. `pipx` y Blackbird se instalan en la carpeta personal (`~`) de quien los ejecuta. Si instalas como root y verificas como tu usuario (o al revés), el script te marcará `[FALTA]` aunque sí los instalaste.

```bash
pipx install maigret
pipx install holehe
pipx ensurepath
exec bash
maigret --version && holehe --help | head -1
```
`pipx` instala cada herramienta de Python en su propio entorno para que no rompa el Python del sistema. `ensurepath` agrega `~/.local/bin`, donde quedan sus comandos, a tu `PATH`. `exec bash` recarga la terminal para que el cambio tome efecto sin tener que cerrarla. La última línea comprueba que los dos comandos ya se encuentran.

```bash
git clone https://github.com/p1ngul1n0/blackbird ~/blackbird
python3 -m venv ~/blackbird/.venv
~/blackbird/.venv/bin/pip install -r ~/blackbird/requirements.txt
```
`git clone` descarga Blackbird; `python3 -m venv` le crea un entorno propio y `pip install -r` instala sus dependencias ahí dentro.

```bash
git clone https://github.com/UnaPibaGeek/ctfr ~/ctfr
python3 -m venv ~/ctfr/.venv
~/ctfr/.venv/bin/pip install -r ~/ctfr/requirements.txt
```
**CTFR**, de Sheila Berta (*UnaPibaGeek*), saca subdominios de los registros de Certificate Transparency desde la terminal. Se instala igual que Blackbird, con su propio `.venv`, porque Kali no deja usar `pip3 install` directo sobre el Python del sistema.

### 0.3 Levantar la red interna de Qhapaq

Primero apaga el laboratorio de la clase anterior, si sigue encendido. Sus contenedores y su red pueden chocar con los de esta clase:

```bash
docker compose -p qhapaq down --remove-orphans
```
`-p qhapaq` es el **nombre del proyecto** de la Clase 02 (la línea `name:` de su `docker-compose.yml`). Con `-p`, el comando funciona **desde cualquier carpeta**, aunque ya no tengas la Clase 02 descargada. `down` apaga y **borra** los contenedores y la red de ese laboratorio, pero no los archivos de la clase. `--remove-orphans` también quita contenedores que ya no están en el `docker-compose.yml`. Si no había nada encendido, no pasa nada.

> Si quieres empezar **completamente limpio** (borra **todos** tus contenedores, no solo los del curso):
> ```bash
> docker rm -f $(docker ps -aq) 2>/dev/null
> docker network prune -f
> ```

Ahora sí, construye y levanta la red de Qhapaq.

> 📁 `docker compose` busca el archivo `docker-compose.yml` **en la carpeta donde estás**. En esta clase está en `Clase-03/objetivo/`, no en `Clase-03/`. Si te sale `no configuration file provided: not found`, estás en la carpeta equivocada.

```bash
cd ~/Clase-03/objetivo
ls docker-compose.yml
docker compose down --remove-orphans
docker compose up -d --build --force-recreate
docker compose ps
```
El `down` de esta clase limpia un intento anterior que haya quedado a medias; `--build` construye las imágenes y `--force-recreate` crea los contenedores desde cero. Deben aparecer 7 contenedores `qi-*` en estado *Up*.

Si cambiaste algo en `objetivo/` o el docente publicó una corrección (`git pull`), reconstruye sin usar la caché: `docker compose build --no-cache && docker compose up -d --force-recreate`.

### 0.4 Verificar

```bash
bash ~/Clase-03/scripts/00-verificar-entorno.sh
```
Solo **lee**: revisa herramientas, Docker y que los objetivos respondan. No toca el `10.30.0.250`.

### 0.5 Carpeta de trabajo

```bash
mkdir -p ~/recon-qhapaq/{01-pasivo,02-personas,03-imagenes,04-activo,evidencias}
cp ~/Clase-03/plantillas/*.md ~/recon-qhapaq/
cp ~/Clase-03/casos/imagenes/*.jpg ~/recon-qhapaq/03-imagenes/
cd ~/recon-qhapaq
script -q -f -a evidencias/terminal-$(date +%F).log
```
Una carpeta por tipo de reconocimiento, las plantillas en la raíz, las imágenes del caso en `03-imagenes/` y `script` grabando todo (como en la Clase 02).

---

## Lab 1 · OSINT de organizaciones (40 min) · Pasivo

**Objetivo de práctica:** `vulnweb.com`, un dominio que Acunetix publica **para que se practique** sobre él, y `zonetransfer.me`, creado por DigiNinja para enseñar transferencias de zona.

### 1.1 Google Dorking (10 min)

Los operadores de búsqueda filtran lo que Google ya indexó. Prueba cada uno en el navegador y anota **cuántos resultados** y **qué descubriste**:

| Dork | Qué busca |
|---|---|
| `site:vulnweb.com` | todo lo indexado del dominio y sus subdominios |
| `site:vulnweb.com -www` | subdominios que **no** son `www` |
| `site:vulnweb.com inurl:php` | URLs con `php` (tecnología del backend) |
| `site:vulnweb.com intitle:login` | páginas de inicio de sesión |
| `site:vulnweb.com ext:txt OR ext:xml OR ext:bak` | archivos que no son páginas web |
| `"vulnweb.com" -site:vulnweb.com` | quién **habla** del dominio desde fuera |

Abre la **Google Hacking Database** (exploit-db.com/google-hacking-database) y elige un dork de la categoría *Files Containing Juicy Info*. Escribe en tu bitácora qué buscaría y **por qué es peligroso**, pero **no abras** resultados de terceros.

> 🧠 Pro: un dork es un hallazgo solo si lo puedes **reproducir**. Guarda la consulta exacta, la fecha y una captura.

### 1.2 Certificados: Certificate Transparency (5 min)

Abre en el navegador:

```
https://crt.sh/?q=%25.vulnweb.com
```
`crt.sh` lista todos los certificados TLS emitidos públicamente para el dominio; `%25` es el comodín `%`. Cada nombre que aparece es un subdominio que **alguien pidió proteger**.

Ahora lo mismo desde la terminal con **CTFR**:

```bash
~/ctfr/.venv/bin/python ~/ctfr/ctfr.py -d vulnweb.com -o ~/recon-qhapaq/01-pasivo/ctfr-vulnweb.txt
sort -u ~/recon-qhapaq/01-pasivo/ctfr-vulnweb.txt
```
`-d` es el dominio y `-o` guarda la lista como evidencia. CTFR no adivina nombres ni usa diccionarios: solo **lee** lo que ya está publicado en los registros de certificados (por dentro consulta a `crt.sh`). Por eso sigue siendo reconocimiento **pasivo**. `sort -u` ordena la lista y quita los repetidos.

> 💡 `crt.sh` es un servicio gratuito y a veces se satura. Si CTFR termina con un error largo (`JSONDecodeError`, `502` o `timeout`), espera un minuto y vuelve a intentarlo. No es un error tuyo.

❓ ¿CTFR encontró los mismos subdominios que viste en el navegador? ¿Por qué conviene tenerlo en la terminal? (Pista: se puede automatizar y guardar como evidencia.)

Anota los subdominios únicos. Vuelve a esta lista en el Lab 5: un certificado **interno** también delata subdominios.

### 1.3 theHarvester (10 min)

```bash
theHarvester -d vulnweb.com -b crtsh,certspotter,hackertarget,duckduckgo -l 200 -f 01-pasivo/harvester-vulnweb
```
`-d` es el dominio; `-b` elige fuentes que **no necesitan API key**; `-l` limita resultados por fuente; `-f` guarda el resultado (XML/JSON) como evidencia.

Compara con lo que sacaste de `crt.sh`/CTFR y de los dorks: ¿qué subdominios aparecen solo en una fuente? **Ninguna herramienta lo ve todo**: el profesional cruza fuentes.

### 1.4 DNS público (10 min)

```bash
dig vulnweb.com ANY +noall +answer
```
`dig` consulta el DNS; `ANY` pide todos los registros que el servidor quiera dar; `+noall +answer` muestra solo las respuestas.

```bash
dig MX vulnweb.com +short
dig TXT vulnweb.com +short
```
`MX` dice quién recibe el correo (¿Google? ¿Microsoft? ¿propio?) y `TXT` suele traer SPF y verificaciones de servicios que la empresa usa.

Ahora la falla clásica, en el dominio hecho para practicarla:

```bash
dig NS zonetransfer.me +short
dig axfr zonetransfer.me @nsztm1.digi.ninja | tee 01-pasivo/axfr-zonetransfer.txt
```
`NS` muestra los servidores de nombres; `axfr` le pide a uno de ellos **la zona completa**. Un servidor bien configurado lo rechaza. Este no. `tee` muestra y guarda a la vez.

❓ ¿Cuántos registros salieron? ¿Ves alguno que una empresa real **no** querría publicar?

### 1.5 Tecnologías del sitio (5 min)

- **BuiltWith:** abre `builtwith.com/testphp.vulnweb.com`: servidor, lenguaje, analítica, CDN y librerías JavaScript.
- **Wappalyzer** (extensión del navegador): abre `http://testphp.vulnweb.com` y mira el ícono.
- **Wayback Machine:** abre `web.archive.org/web/*/vulnweb.com*` para ver URLs que existieron y quizá ya no están enlazadas.

```bash
whatweb -a 3 http://testphp.vulnweb.com | tee 01-pasivo/whatweb-testphp.txt
```
`whatweb` identifica tecnologías desde la terminal; `-a 3` es el nivel de agresividad (hace más peticiones). Ojo: **esto ya es activo**, porque le hablas al servidor. Se permite porque el sitio existe para practicar.

---

## Lab 2 · Buscadores de dispositivos: Shodan y Censys (20 min) · Pasivo

Shodan y Censys escanean internet **por ti** y guardan lo que cada servicio responde. Tú consultas su base de datos: no le envías ni un paquete al objetivo.

### 2.1 Shodan

Crea una cuenta gratuita en `shodan.io` (los filtros necesitan sesión iniciada). Si tienes correo institucional, revisa la mejora académica en `help.shodan.io`.

Consultas para hacer **mirando solo el conteo y las estadísticas** de la columna izquierda:

| Consulta | Pregunta |
|---|---|
| `country:PE port:3389` | ¿cuántos escritorios remotos (RDP) expone Perú? |
| `country:PE port:445` | ¿y SMB? |
| `country:PE "220" "vsftpd 2.3.4"` | ¿quedan FTP con una versión famosa por su puerta trasera? |
| `country:PE product:"Apache httpd"` | ¿qué versiones de Apache dominan? (mira *Top Versions*) |
| `org:"SENATI"` | ¿qué tiene tu institución publicado? (solo mirar) |

> ❌ No hagas clic en las IPs para conectarte a ellas. Leer el resultado de Shodan es pasivo; conectarte a esa IP ya no.

Sin cuenta y sin clave, Shodan ofrece **InternetDB**, una API mínima por IP. Pruébala con `scanme.nmap.org`, un servidor que Nmap publica para que se pruebe contra él:

```bash
dig +short scanme.nmap.org
curl -s https://internetdb.shodan.io/45.33.32.156
```
La primera línea resuelve la IP; la segunda devuelve en JSON los puertos, tecnologías (CPE) y CVE que Shodan vio en esa IP, sin que tú la toques.

### 2.2 Censys

Entra a `platform.censys.io` (cuenta gratuita; el buscador antiguo `search.censys.io` ya no atiende a usuarios gratuitos).

1. Busca la IP `45.33.32.156` y compara puertos y servicios con lo que dijo InternetDB.
2. Escribe una consulta con el estilo de Shodan (por ejemplo, puerto 3389 en Perú). Si la sintaxis no es la correcta, Censys ofrece **convertirla** a su lenguaje (CenQL). Anota la consulta convertida: es la forma más rápida de aprender su sintaxis.

❓ ¿Los dos buscadores coinciden? ¿Por qué podrían no hacerlo? (Pista: cada uno escanea desde lugares distintos y en momentos distintos.)

---

## Lab 3 · OSINT de personas: tu propia huella digital (30 min) · Pasivo

> 🔒 **Solo con TU usuario y TU correo.** Al final de este lab sabrás qué encuentra un atacante sobre ti, y podrás cerrar lo que no quieras público.

Escribe en tu bitácora el usuario que más usas (`TU_USUARIO`) y tu correo personal (`TU_CORREO`).

### 3.1 En el navegador (5 min)

- **WhatsMyName:** `whatsmyname.app/?q=TU_USUARIO`. Filtra por categoría y exporta a CSV en `02-personas/`.
- **Namechk:** `namechk.com`. Muestra dónde el nombre está **tomado** (que no es lo mismo que "es tuyo").
- **Have I Been Pwned:** `haveibeenpwned.com` con `TU_CORREO`: ¿en qué filtraciones apareció?

### 3.2 Maigret (10 min)

```bash
cd 02-personas
maigret TU_USUARIO --html --timeout 15
cd ..
```
`maigret` revisa cientos de sitios, **extrae datos de los perfiles que encuentra** (nombre, enlaces a otras cuentas) y sigue esos nuevos usuarios; `--html` genera un reporte en `reports/`; `--timeout` evita quedarse esperando sitios lentos.

### 3.3 Blackbird (5 min)

```bash
cd ~/blackbird
.venv/bin/python blackbird.py --username TU_USUARIO --csv
cd ~/recon-qhapaq
```
`blackbird.py` hace lo mismo con su propia lista de sitios (incluye la de WhatsMyName). Se ejecuta **desde su carpeta** porque busca sus listas en el directorio actual, y con el Python del `.venv` para usar sus dependencias; `--csv` guarda el resultado en `~/blackbird/results/`.

### 3.4 holehe (5 min)

```bash
holehe TU_CORREO --only-used
```
`holehe` pregunta a cada sitio "¿este correo tiene cuenta?" usando su flujo de recuperación de contraseña, **sin avisarle al dueño**; `--only-used` muestra solo los sitios donde existe.

> ⚠️ Justo porque no avisa al dueño, usarlo con correos ajenos sin autorización es un problema ético y legal. Por eso, solo el tuyo.

### 3.5 Lo que separa a un pro: verificar (5 min)

Llena la tabla en tu bitácora:

| Herramienta | Cuentas "encontradas" | Verificadas a mano | Falsos positivos |
|---|---|---|---|
| WhatsMyName | | | |
| Maigret | | | |
| Blackbird | | | |
| holehe | | | |

Abre al menos 5 resultados y confirma si **eres tú**. Un informe de OSINT con falsos positivos es peor que no tener informe: puede acusar a la persona equivocada.

---

## ☕ Pausa (10 min)

---

## Lab 4 · OSINT de imágenes (25 min) · Pasivo

En `03-imagenes/` tienes dos imágenes que "se filtraron" de Qhapaq.

### 4.1 Metadatos EXIF: `foto-oficina.jpg` (10 min)

```bash
cd 03-imagenes
exiftool foto-oficina.jpg
```
`exiftool` lee los metadatos que la cámara o el celular guardan dentro del archivo: modelo, fecha, software, autor y, si el GPS estaba encendido, **dónde** se tomó.

```bash
exiftool -n -GPSLatitude -GPSLongitude foto-oficina.jpg
```
`-n` muestra las coordenadas en números decimales, listos para pegar en un mapa (OpenStreetMap o Google Maps).

Responde en la bitácora:

1. ¿Quién la tomó? ¿Con qué teléfono? ¿Cuándo?
2. ¿Dónde se tomó? (ciudad y lugar exacto)
3. Mira la **imagen** y no solo los metadatos: ¿qué información sensible se ve?
4. El autor aparece como `jdiaz`. Guárdalo: lo vas a volver a ver en el Lab 5.

```bash
cp foto-oficina.jpg foto-limpia.jpg
exiftool -all= -overwrite_original foto-limpia.jpg
exiftool foto-limpia.jpg | wc -l
```
`-all=` borra todos los metadatos de la copia (`-overwrite_original` evita que deje un respaldo `_original`); `wc -l` cuenta las líneas que quedan. Esto es lo que debería hacer la empresa **antes** de publicar una foto.

### 4.2 ¿Está editada? `comunicado-editado.jpg` (8 min)

```bash
exiftool -Software -ModifyDate comunicado-editado.jpg
```
`-Software` y `-ModifyDate` muestran solo esas dos etiquetas: con qué programa se guardó por última vez y cuándo.

Sube la imagen a **FotoForensics** (`fotoforensics.com`) y mira el **ELA** (*Error Level Analysis*): una zona que se pegó después y se comprimió **una vez menos** que el resto brilla distinto.

❓ ¿Qué parte del comunicado fue modificada? ¿Qué decía probablemente antes? ¿A qué hora se editó?

### 4.3 Búsqueda inversa (7 min)

1. Descarga de **Wikimedia Commons** una foto de un lugar conocido del Perú (por ejemplo, la Catedral de Arequipa). Recórtala y bórrale los metadatos con `exiftool -all= -overwrite_original`.
2. Búscala en **TinEye** (`tineye.com`) y en **Google Lens** (`lens.google.com`).
3. Anota: ¿cuál de los dos encontró la fuente original?, ¿cuál identificó el lugar?, ¿qué pasó al recortarla?

> 🧠 Pro: TinEye es bueno para encontrar **la misma imagen** (y la más antigua). Lens es bueno para reconocer **qué hay** en la imagen. Por eso un investigador usa los dos.

```bash
cd ..
```
Vuelve a la raíz de tu carpeta de trabajo.

---

## Lab 5 · Reconocimiento activo de la red interna de Qhapaq (60 min) · Activo

Ahora sí le hablas a los sistemas. Red: `10.30.0.0/24`, dominio interno `qhapaq.lab`.

### 5.1 Alcance escrito (2 min)

```bash
printf '10.30.0.10\n10.30.0.25\n10.30.0.45\n10.30.0.53\n10.30.0.60\n10.30.0.161\n' > 04-activo/alcance.txt
printf '10.30.0.250\n' > 04-activo/fuera-de-alcance.txt
```
Desde ahora, cada escaneo lee estos archivos. Si no está en `alcance.txt`, no existe.

### 5.2 Descubrimiento de hosts (3 min)

```bash
sudo nmap -sn -n 10.30.0.0/24 --excludefile 04-activo/fuera-de-alcance.txt -oA 04-activo/descubrimiento
```
`-sn` solo pregunta si el host está vivo (en una red local lo hace por ARP, que no se puede bloquear); `-n` no resuelve nombres (más rápido y silencioso); `sudo` permite paquetes "crudos".

### 5.3 TCP: los 1000 de siempre contra los 65535 (8 min)

```bash
sudo nmap -n -iL 04-activo/alcance.txt -oA 04-activo/tcp-top1000
```
Sin `-p`, nmap revisa solo los **1000 puertos más comunes**.

```bash
sudo nmap -sS -p- --min-rate 3000 -n -iL 04-activo/alcance.txt -oA 04-activo/tcp-todos
```
`-sS` es el escaneo SYN (abre la conexión a medias y no la completa); `-p-` revisa los 65535 puertos; `--min-rate 3000` envía al menos 3000 paquetes por segundo (en una red de laboratorio, sin problema; en producción, **cuidado**).

❓ Compara `10.30.0.60` en los dos escaneos. ¿Cuántos puertos te habrías perdido con el escaneo por defecto?

```bash
grep -oP '\d+/open' 04-activo/tcp-todos.gnmap | cut -d/ -f1 | sort -un | paste -sd,
```
Saca de la salida "grepeable" (`.gnmap`) la lista de puertos abiertos, sin repetir y separada por comas, lista para usarse en `-p`.

### 5.4 UDP: el que todos olvidan (5 min)

```bash
sudo nmap -sU --top-ports 50 -n -iL 04-activo/alcance.txt -oA 04-activo/udp-top50
```
`-sU` escanea UDP. Es lento porque UDP no confirma nada: nmap tiene que esperar. Por eso se limita a los 50 más comunes. Mientras corre, adelanta el 5.6 en otra terminal.

### 5.5 Versiones y scripts (5 min)

```bash
sudo nmap -sV -sC -p PUERTOS -n -iL 04-activo/alcance.txt -oA 04-activo/servicios
```
Reemplaza `PUERTOS` por la lista del 5.3. `-sV` conversa con cada puerto para identificar el **producto y la versión**; `-sC` corre los scripts NSE "seguros" por defecto.

❓ En el 5.3, el puerto `2222` aparecía como `EtherNetIP-1`. ¿Qué es en realidad? ¿Qué te enseña eso sobre la columna `SERVICE` sin `-sV`?

```bash
xsltproc 04-activo/servicios.xml -o 04-activo/servicios.html
```
`xsltproc` convierte el XML de nmap en un reporte HTML navegable: ábrelo con el navegador.

### 5.6 Fingerprinting servicio por servicio (35 min)

Cada servicio te cuenta algo. Anota cada dato en `mapa-superficie.md` a medida que avanzas.

#### DNS · 10.30.0.53

```bash
dig @10.30.0.53 version.bind chaos txt +short
```
Pregunta al servidor qué software y versión es (la clase `chaos` es una consulta especial que muchos servidores responden).

```bash
dig axfr qhapaq.lab @10.30.0.53 | tee 04-activo/axfr-qhapaq.txt
```
La misma transferencia de zona del Lab 1, pero ahora contra el DNS interno de Qhapaq.

🚩 **Bandera 05** está en un registro TXT.
❓ ¿Qué host aparece en el DNS pero **no** responde? ¿Qué host aparece pero es de un **tercero**?

#### Web · 10.30.0.10

```bash
curl -sI http://10.30.0.10/
whatweb http://10.30.0.10/
```
Las cabeceras (`Server`, `X-Powered-By`) y el HTML (etiqueta `generator`) delatan producto y versión. ¿Coinciden entre sí? ¿Alguna versión te parece **demasiado vieja** para ser verdad?

```bash
echo | openssl s_client -connect 10.30.0.10:443 2>/dev/null | openssl x509 -noout -subject -ext subjectAltName
```
`s_client` se conecta por TLS y `x509` imprime el dueño del certificado (`subject`) y sus nombres alternativos (`SAN`).

🚩 **Bandera 06** está en el certificado.
❓ Compara los SAN con la zona DNS: ¿qué nombres están en el certificado y **no** en el DNS? (Igual que `crt.sh` en el Lab 1.)

#### SMB · 10.30.0.45

```bash
smbclient -N -L //10.30.0.45
```
`-N` entra **sin contraseña** (sesión nula o de invitado); `-L` lista los recursos compartidos.

```bash
smbclient -N //10.30.0.45/publico -c 'ls'
smbclient -N //10.30.0.45/publico -c 'get organigrama.txt evidencias/smb-organigrama.txt'
smbclient -N //10.30.0.45/publico -c 'get politica-contrasenas.txt evidencias/smb-politica.txt'
```
`-c` ejecuta comandos dentro del recurso compartido: `ls` lista y `get` descarga a tu carpeta de evidencias.

🚩 **Bandera 08** está en uno de esos archivos.
❓ ¿Puedes entrar a `rrhh`? ¿Qué **formato de usuario** usa la empresa? ¿Qué dice la política de contraseñas? (Guárdalo para la Clase 04.)

#### SMTP · 10.30.0.25

Con el organigrama, arma la lista de posibles usuarios aplicando el formato que descubriste:

```bash
printf 'jdiaz\nmquispe\nrhuaman\ncflores\nlmamani\nsoporte\ngerencia\nadmin\n' > 04-activo/usuarios.txt
```
Cada línea es un candidato: personas (formato inicial + apellido) y cuentas de rol típicas.

```bash
{ printf 'EHLO kali\r\n'; while read -r u; do printf 'VRFY %s\r\n' "$u"; done < 04-activo/usuarios.txt; printf 'QUIT\r\n'; } | nc -w 3 10.30.0.25 25 | tee 04-activo/smtp-vrfy.txt
```
Se abre **una** conversación SMTP y, por cada candidato, se envía `VRFY usuario` ("¿existe este buzón?"). `252` significa que existe y `550` que no.

❓ ¿Qué personas del organigrama **no** tienen buzón con el formato esperado? ¿Qué te dice eso?

#### SNMP · 10.30.0.161 (UDP)

```bash
printf 'public\nprivate\nqhapaq\nmonitor\nmanager\n' > 04-activo/comunidades.txt
onesixtyone -c 04-activo/comunidades.txt 10.30.0.161
```
SNMP v1/v2c se "autentica" con una palabra llamada *comunidad*; `onesixtyone` prueba una lista de comunidades a toda velocidad.

```bash
snmpwalk -v2c -c COMUNIDAD 10.30.0.161 1.3.6.1.2.1.1
```
`snmpwalk` recorre un árbol de datos (OID). `1.3.6.1.2.1.1` es el grupo *system*: descripción, contacto, nombre y ubicación del equipo.

🚩 **Bandera 07** está en ese grupo.

Pista pro: el OID `1.3.6.1.2.1.25.4.2.1.5` guarda **los parámetros de cada proceso en ejecución**. Recórrelo. ¿Algún programa recibió algo que no debería ir en la línea de comandos?

#### Redis · 10.30.0.60:6379

```bash
redis-cli -h 10.30.0.60 INFO server
```
Si Redis no pide contraseña, `INFO` devuelve versión, sistema operativo y configuración.

```bash
redis-cli -h 10.30.0.60 --scan
```
`--scan` lista las claves guardadas sin bloquear el servidor (a diferencia de `KEYS *`).

🚩 **Bandera 09**: léela con `GET` y el nombre de la clave que corresponda.
❌ Solo lectura: nada de `SET`, `DEL`, `CONFIG` ni `FLUSHALL`. Enumerar no es modificar.

#### El puerto que nadie conoce · 10.30.0.60

```bash
nc -nv 10.30.0.60 PUERTO
```
Reemplaza `PUERTO` por el que solo apareció con `-p-`. `nc` abre una conexión TCP "pelada": muchos servicios se presentan solos con un **banner**. Esto se llama *banner grabbing*.

🚩 **Bandera 10** es lo que responde.
❓ ¿Qué nombre le dio nmap a ese puerto en el 5.5? ¿Por qué no lo reconoció?

### 5.7 ¿Saliste del alcance? (2 min)

```bash
docker logs qi-erp
```
Si aparece tu IP, tocaste el servidor del tercero. Anótalo con la hora: en un trabajo real se reporta de inmediato.

---

## Lab 6 · Mapa de superficie de ataque (25 min)

Llena `mapa-superficie.md`. Es el entregable más importante: lo que **otro** pentester necesitaría para continuar sin repetir tu trabajo.

1. **Inventario:** host · puerto · servicio · versión real · cómo lo confirmaste.
2. **Exposiciones:** cada configuración insegura que viste (AXFR abierto, sesión nula, VRFY, comunidad `public`, Redis sin clave, cabeceras con versiones, SAN que delatan nombres).
3. **Usuarios y credenciales recolectados:** de dónde salió cada uno. Recuerda: **no se usan hoy.**
4. **Correlación pasivo ↔ activo:** `jdiaz` aparece en la foto, en la intranet, en el contacto de SNMP, en SMTP y en el organigrama. ¿Qué puedes decir de su rol y por qué es un objetivo interesante?
5. **Próximos pasos:** tres ataques que probarías en la Clase 04 y por qué, en orden de prioridad.

### Cierre

```bash
exit
sha256sum evidencias/* 04-activo/* > evidencias/SHA256SUMS
```
`exit` detiene la grabación de `script`; `sha256sum` congela la huella de tus evidencias.

```bash
cd ~/Clase-03/objetivo
docker compose down
```
Apaga la red de Qhapaq (o déjala arriba: la usaremos en la Clase 04).

### Entrega

Un `.zip` de `~/recon-qhapaq` **sin** los reportes de tus cuentas personales (de `02-personas/` entrega solo la tabla de verificación del 3.5, no los reportes HTML ni CSV):

- [ ] `bitacora-osint.md` con los Labs 1 a 4 respondidos
- [ ] `mapa-superficie.md` completo
- [ ] `01-pasivo/`, `03-imagenes/`, `04-activo/` y `evidencias/` con `SHA256SUMS`
- [ ] Banderas 05 a 10 con hora

---

## Errores comunes

| Síntoma | Causa probable | Solución |
|---|---|---|
| `$: command not found` | Copiaste el `$` del README de una herramienta. El `$` solo representa el prompt, no se escribe | Escribe el comando sin el `$`. Por ejemplo: `python3 ctfr.py --help` |
| `fatal: repository '.../tree/main/Clase-03/' not found` | Copiaste la URL de la **carpeta** en el navegador | Clona el repositorio `.../ST-EH.git` con *sparse checkout* (Lab 0.0) |
| `fatal: destination path 'ST-EH' already exists` | Ya lo clonaste en una clase anterior | `cd ~/ST-EH && git pull && git sparse-checkout add Clase-03` |
| `fatal error: Python.h: No such file or directory` al instalar Blackbird | Falta el paquete de desarrollo de Python para compilar `aiohttp` | `sudo apt install -y python3-dev build-essential` y repite el `pip install -r` |
| `no configuration file provided: not found` | Ejecutaste `docker compose` fuera de `objetivo/` | `cd ~/Clase-03/objetivo` y repite el comando |
| `cd: /root/Clase-03: No such file or directory` o `cp: cannot stat '/root/Clase-03/...'` | Estás como **root** (para root, `~` es `/root`) o no creaste el acceso directo del Lab 0.0 | Crea el acceso directo para el usuario que estás usando: `ln -sfn /home/TU_USUARIO/ST-EH/Clase-03 ~/Clase-03`. Lo ideal es `exit` y trabajar con tu usuario |
| El script de verificación no encuentra blackbird, maigret o holehe | Los instalaste como **root** (quedaron en `/root`) | Sal de root (`exit`) y repite el Lab 0.2 con tu usuario |
| `maigret: command not found`, o `[FALTA] maigret / holehe` en el script | No están instalados para **este** usuario, o `pipx` no agregó `~/.local/bin` al `PATH` | Con el mismo usuario que corre el script: `pipx install maigret && pipx install holehe && pipx ensurepath && exec bash`. Si dice *already installed*, basta con `pipx ensurepath && exec bash` |
| `externally-managed-environment` al usar `pip` | Kali protege el Python del sistema | Usa `pipx` (maigret, holehe) o el `.venv` (blackbird) |
| holehe marca todo con `[x]` "rate limit" | Demasiadas consultas desde tu IP | Espera unos minutos; no lo corras en bucle |
| theHarvester sin resultados en una fuente | La fuente limita por IP o necesita clave | Usa las fuentes del 1.3; las que piden clave se configuran en `api-keys.yaml` |
| Shodan no deja usar `country:` | No iniciaste sesión | Crea la cuenta gratuita e inicia sesión |
| `snmpwalk` responde `Timeout` | Comunidad incorrecta o te olvidaste de que es **UDP** | Revisa la comunidad con `onesixtyone` |
| `snmpwalk` muestra números en vez de nombres | Kali no trae las MIB con nombres | Es normal; usa los OID numéricos de la guía |
| `nmap -sU` tarda muchísimo | UDP espera respuestas que no llegan | Limita con `--top-ports` o `-p` |
| `Pool overlaps` al levantar el laboratorio | Ya existe una red 10.30.0.0/24 | `docker network ls` y borra la que sobra |
| `Operation not permitted` en `nmap -sS` | `-sS` y `-sU` necesitan privilegios | Antepón `sudo` |

---

## Para profundizar (opcional)

- OSINT Framework: osintframework.com
- Bellingcat Online Investigations Toolkit: bellingcat.gitbook.io/toolkit
- Google Hacking Database: exploit-db.com/google-hacking-database
- Nmap Reference Guide: nmap.org/book/man.html
- HackTricks: secciones de enumeración por puerto (53, 25, 161, 445, 6379)
