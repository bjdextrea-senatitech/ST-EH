# Laboratorio Clase 02 · El proceso de pentesting, de punta a punta

**SENATI · DC05 Ethical Hacking y Seguridad Ofensiva · Capítulo 2 del sílabo**
Tipos de pentesting · PTES / OWASP / OSSTMM · fases · marco legal · reportes

Hoy no se trata de "hackear": se trata de **trabajar como un pentester profesional**. Vas a hacer un pentest completo, pequeño y en tu propia VM, contra la empresa ficticia **Inversiones Qhapaq SAC**, siguiendo las 7 fases de PTES. Al final entregas lo que entrega un profesional: autorización, bitácora, evidencias con hash e informe.

> Regla de oro de la clase: **lo que no está en el alcance no existe**. En la red del laboratorio hay un servidor que NO es del cliente. Si lo tocas, se registra.

---

## Agenda (180 min)

| Tiempo | Bloque | Fase PTES |
|---|---|---|
| 25 min | Teoría (PPT) | — |
| 15 min | Lab 0 · Preparar el entorno y levantar Qhapaq | — |
| 25 min | Lab 1 · Pre-acuerdo: tipo de prueba, la carta mala y tus reglas | 1 |
| 35 min | Lab 2 · Inteligencia, amenazas y vulnerabilidades | 2 · 3 · 4 |
| 10 min | Pausa | |
| 30 min | Lab 3 · Explotación y post-explotación (con límites) | 5 · 6 |
| 30 min | Lab 4 · Reporte: CVSS 4.0, un hallazgo completo y el resumen ejecutivo | 7 |
| 10 min | Cierre · Hash de evidencias, limpieza y entrega | 7 |

**Meta mínima:** banderas 01, 02 y 03 + un hallazgo completo con CVSS.
**Meta completa:** las 4 banderas + 3 hallazgos con CVSS + resumen ejecutivo.

---

## Lab 0 · Preparar el entorno (15 min)

> **Tarea previa recomendada:** haz este Lab 0 antes de la clase. La primera construcción de las imágenes descarga paquetes y tarda unos minutos.

Todo se hace **dentro de tu VM Linux** (Kali o Ubuntu), no en Windows.

### 0.1 Instalar Docker en la VM (solo si no lo tienes)

```bash
sudo apt update
sudo apt install -y docker.io docker-compose nmap curl
```
`apt install` instala paquetes; `docker.io` es el motor de contenedores y `docker-compose` levanta varios contenedores a la vez.

```bash
sudo usermod -aG docker $USER
```
`usermod -aG` agrega tu usuario al grupo `docker` para no escribir `sudo` en cada comando. **Cierra sesión y vuelve a entrar** para que tome efecto.

### 0.2 Levantar la empresa Qhapaq

Descarga o clona la carpeta `Clase-02` **en tu home** (`~/Clase-02`). Todas las rutas de esta guía asumen esa ubicación.

```bash
cd ~/Clase-02/objetivo
docker compose up -d --build
```
`up -d --build` construye las imágenes y arranca los contenedores en segundo plano. Si tu sistema dice que `compose` no existe, usa `docker-compose up -d --build` (con guion).

```bash
docker compose ps
```
`ps` lista los contenedores del proyecto: deben salir `qhapaq-web`, `qhapaq-files` y `qhapaq-erp` en estado *running/Up*.

### 0.3 Verificar

```bash
bash ../scripts/00-verificar-entorno.sh
```
El script solo **lee**: revisa herramientas, que Docker funcione y que los objetivos respondan. No toca el servidor fuera de alcance.

---

## Lab 1 · Pre-acuerdo (25 min) · PTES fase 1

Antes de lanzar un solo paquete, un pentester profesional tiene **por escrito**: quién autoriza, qué se prueba, cuándo, cómo y qué pasa con lo que encuentre.

### 1.0 Tu carpeta de trabajo, ordenada por fases

```bash
mkdir -p ~/pentest-qhapaq/{00-preacuerdo,01-inteligencia,02-amenazas,03-vulnerabilidades,04-explotacion,05-post-explotacion,06-reporte,evidencias}
```
`mkdir -p` con llaves `{a,b}` crea varias carpetas de una vez; cada carpeta es una fase de PTES.

```bash
cd ~/pentest-qhapaq
cp ~/Clase-02/plantillas/carta-autorizacion-con-fallas.md ~/Clase-02/plantillas/reglas-de-enfrentamiento.md 00-preacuerdo/
cp ~/Clase-02/plantillas/hallazgo.md ~/Clase-02/plantillas/informe-ejecutivo.md 06-reporte/
cp ~/Clase-02/plantillas/bitacora-pentest.md .
```
`cp` copia cada plantilla a la carpeta de la fase donde se usa; la bitácora queda en la raíz porque se llena durante todo el pentest.

### 1a. ¿Qué tipo de prueba es? (5 min, en parejas)

Clasifica cada caso: **caja negra / gris / blanca** y **externa / interna**. Anota también si es pentest, análisis de vulnerabilidades o red team.

1. El banco te da solo su dominio público y te pide ver si alguien de internet puede entrar.
2. Te sientas en la oficina con un punto de red y una cuenta de usuario normal de dominio.
3. Te dan el código fuente de la app web, credenciales de cada rol y el diagrama de arquitectura.
4. Corres Nessus contra 400 servidores y entregas la lista priorizada, sin explotar nada.
5. Durante 4 semanas intentas llegar a la base de datos de tarjetas sin que el SOC te detecte.
6. **Qhapaq (hoy):** te dan el rango de red, te dicen qué IP no tocar y nada más.

### 1b. La carta mala (10 min)

Abre `~/pentest-qhapaq/00-preacuerdo/carta-autorizacion-con-fallas.md`. Es una autorización **real en apariencia** pero con al menos **10 problemas** que podrían dejarte expuesto a la Ley 30096.

Marca cada falla con 🔴 y escribe en una línea por qué es un problema y cómo la corregirías. Piensa en: quién firma, qué IP son del cliente, fechas, horarios, técnicas, datos personales, credenciales encontradas, contacto de emergencia, entregables.

### 1c. Tus reglas de enfrentamiento (10 min)

Abre `00-preacuerdo/reglas-de-enfrentamiento.md` y llénala para Qhapaq con estos datos:

- Cliente: Inversiones Qhapaq SAC · Contacto: el docente
- En alcance: `172.30.0.10` y `172.30.0.20`
- **Fuera de alcance:** `172.30.0.30` (ERP del proveedor Andes Cloud) y cualquier otra IP
- Ventana: hoy, durante la clase
- Prohibido: denegación de servicio, borrar o modificar datos, sacar datos personales de la máquina

> **No avances al Lab 2 sin tus reglas llenas.** En la vida real, sin autorización firmada no hay pentest: hay delito (Ley 30096, art. 2: acceder *o exceder lo autorizado*).

---

## Lab 2 · Inteligencia, amenazas y vulnerabilidades (35 min) · PTES fases 2, 3 y 4

### 2.1 Graba todo lo que haces

```bash
script -q -f -a evidencias/terminal-$(date +%F).log
```
`script` graba todo lo que aparece en tu terminal en un archivo; `-a` agrega sin borrar, `-f` escribe al instante. Para dejar de grabar: `exit`.

```bash
date -Is
```
`date -Is` imprime fecha y hora en formato ISO. Escríbelo **al inicio de cada fase**: así tu bitácora tiene horas exactas.

### 2.2 Define el alcance en un archivo (la máquina no adivina)

```bash
printf '172.30.0.10\n172.30.0.20\n' > 00-preacuerdo/alcance.txt
printf '172.30.0.30\n' > 00-preacuerdo/fuera-de-alcance.txt
```
`printf` escribe texto con saltos de línea `\n`; `>` lo guarda en un archivo. Desde ahora todas tus herramientas leen **estos** archivos.

### 2.3 Descubrimiento de hosts

```bash
nmap -sn 172.30.0.0/24 --excludefile 00-preacuerdo/fuera-de-alcance.txt -oA 01-inteligencia/descubrimiento
```
`-sn` solo pregunta "¿estás vivo?" sin escanear puertos; `--excludefile` saca del escaneo lo prohibido; `-oA` guarda el resultado en 3 formatos (evidencia).

❓ ¿Qué IP aparece además de .10 y .20? (pista: es tu propia VM vista desde la red de Docker). Anótala en la bitácora y **no** la trates como objetivo.

### 2.4 Puertos y servicios, solo en alcance

```bash
nmap -sV -sC -p- --min-rate 2000 -iL 00-preacuerdo/alcance.txt -oA 01-inteligencia/servicios
```
`-iL` lee los objetivos desde el archivo de alcance; `-p-` revisa los 65535 puertos; `-sV` detecta versiones; `-sC` corre los scripts por defecto de nmap.

Completa en tu bitácora la tabla **IP · puerto · servicio · versión · observación**.

### 2.5 Inteligencia sobre la web (guíate por OWASP WSTG)

```bash
curl -sI http://172.30.0.10/
```
`curl -I` pide solo las cabeceras HTTP: mira la cabecera `Server` (**WSTG-INFO-02**, huella del servidor web).

```bash
curl -s http://172.30.0.10/robots.txt
```
`robots.txt` le dice a los buscadores qué no indexar… y a un atacante dónde mirar (**WSTG-INFO-03**).

```bash
curl -s http://172.30.0.10/ | grep -n '<!--'
```
`grep -n '<!--'` busca comentarios HTML olvidados por los desarrolladores (**WSTG-INFO-05**).

Sigue la pista que encontraste. Cuando des con algo interesante, guárdalo como evidencia:

```bash
curl -s http://172.30.0.10/RUTA/ARCHIVO -o evidencias/web-ARCHIVO
```
`-o` guarda la respuesta en un archivo en vez de mostrarla. Cambia `RUTA/ARCHIVO` por lo que encontraste.

🚩 **Bandera 01** está en esa ruta.

### 2.6 Modelado de amenazas (5 min, en la bitácora) · PTES fase 3

Antes de atacar, responde en 3 líneas: ¿cuál es el activo más valioso de una empresa de inversiones?, ¿quién querría robarlo? y, con lo que ya viste, ¿por dónde entraría?

### 2.7 Análisis de vulnerabilidades · PTES fase 4

Con la tabla de servicios y las notas que encontraste en la web, lista las **hipótesis** de vulnerabilidad. Ejemplo de formato:

| # | Servicio | Hipótesis | Cómo la confirmo |
|---|---|---|---|
| V1 | FTP 21 | ¿acepta login anónimo? | revisar salida de `-sC` (script `ftp-anon`) |
| V2 | … | … | … |

Para confirmar V1 sin ninguna herramienta especial:

```bash
curl -s ftp://172.30.0.20/
```
`curl` también habla FTP: sin usuario, intenta entrar como `anonymous` y lista el directorio.

Navega por las carpetas agregando la ruta al final (`ftp://172.30.0.20/carpeta/`) y descarga lo que sea evidencia con `-o evidencias/ftp-NOMBRE`.

🚩 **Bandera 02** está en un archivo que un proveedor nunca debió poder leer.

---

## ☕ Pausa (10 min)

---

## Lab 3 · Explotación y post-explotación (30 min) · PTES fases 5 y 6

Antes de explotar, relee tus reglas: **¿esto está permitido?** Usar una credencial encontrada sí lo está en este laboratorio (lo dice tu RoE). Anótalo.

### 3.1 Acceso inicial

```bash
date -Is
ssh USUARIO@172.30.0.20
```
`ssh` abre una sesión remota; usa el usuario y la contraseña que encontraste en la fase anterior.

```bash
id
hostname
```
`id` muestra con qué usuario y grupos estás; `hostname` el nombre de la máquina. Son la **prueba mínima de acceso** que va en un informe.

🚩 **Bandera 03** está en el home del usuario.

### 3.2 Escalada de privilegios

```bash
sudo -l
```
`sudo -l` lista qué comandos puede ejecutar tu usuario como root. Es lo primero que se revisa al entrar a un Linux.

Pista: busca el binario permitido en **GTFOBins** (gtfobins.github.io) → sección *Sudo*. Entiende **por qué** funciona antes de ejecutarlo.

```bash
id
```
Si escalaste, `id` debe decir `uid=0(root)`. Esa línea **es** tu evidencia.

🚩 **Bandera 04** está en `/root`.

### 3.3 Post-explotación con ética: demuestra impacto sin llevarte datos

En el home de `soporte` hay una carpeta `backups`. Contiene datos personales (ficticios, pero trátalos como reales: Ley 29733).

```bash
ls -la ~/backups
head -2 ~/backups/clientes-2025.csv
wc -l ~/backups/clientes-2025.csv
```
`ls -la` lista con permisos y tamaños; `head -2` muestra solo las 2 primeras líneas (las cabeceras); `wc -l` cuenta líneas = cuántos clientes están expuestos.

❌ **No** copies el archivo a tu máquina. En el informe basta con: *"Se confirmó acceso a un archivo con N registros que incluyen DNI, teléfono y monto invertido"*. Eso es impacto demostrado sin crear un problema de datos personales (y sin caer en el art. 12-A de la Ley 30096 por poseer datos o credenciales ajenas sin justificación).

### 3.4 Limpieza

```bash
exit
```
Sal de la shell de root y de la sesión SSH. Anota en la bitácora: *"no se crearon archivos ni usuarios en el objetivo"*. Si hubieras creado algo, aquí lo listarías y lo borrarías.

### 3.5 ¿Tocaste lo que no debías?

```bash
docker logs qhapaq-erp
```
`docker logs` muestra el registro del servidor del proveedor. Si aparece tu IP, saliste del alcance: escríbelo en la bitácora con la hora. **En un trabajo real, esto se reporta al cliente de inmediato.**

---

## Lab 4 · Reporte (30 min) · PTES fase 7

El cliente no paga por tu shell de root: paga por **el informe**. Es lo único que queda cuando te vas.

### 4.1 Califica con CVSS 4.0 (10 min)

Abre la calculadora oficial: **first.org/cvss/calculator/4.0**. Para cada hallazgo, elige las métricas base y anota vector y puntaje:

| # | Hallazgo | Vector CVSS 4.0 | Puntaje | Severidad |
|---|---|---|---|---|
| H1 | FTP anónimo expone credenciales en texto claro | | | |
| H2 | `sudo` sin contraseña sobre un binario que permite shell | | | |
| H3 | Listado de directorio con notas internas de despliegue | | | |
| H4 | Versión exacta del servidor web en cabeceras | | | |

Pistas: ¿se ataca desde la red o hace falta estar dentro (AV)? ¿hace falta estar autenticado (PR)? ¿qué se pierde: confidencialidad, integridad, disponibilidad (VC/VI/VA)?

### 4.2 Un hallazgo completo (10 min)

Usa `06-reporte/hallazgo.md` y escribe **H1** completo: título, severidad, activos afectados, descripción, evidencia (con hora y nombre de archivo), impacto en lenguaje de negocio, recomendación concreta y referencias (WSTG/CWE).

### 4.3 Resumen ejecutivo (10 min)

Usa `06-reporte/informe-ejecutivo.md`. Máximo **media página**, sin comandos, para el gerente general. Debe responder: ¿qué hicimos?, ¿qué tan grave está?, ¿qué hago el lunes?

> Tip: los hallazgos sueltos son "Alto" y "Medio", pero **juntos forman una cadena**: un proveedor cualquiera llega a root y a los datos de 200 clientes. Esa cadena es el titular del resumen ejecutivo.

---

## Cierre (10 min)

### Integridad de evidencias

```bash
exit
```
Si seguías dentro de `script`, `exit` detiene la grabación de la terminal.

```bash
cd ~/pentest-qhapaq
sha256sum evidencias/* 01-inteligencia/* > evidencias/SHA256SUMS
```
`sha256sum` calcula una huella de cada archivo; si alguien lo modifica después, la huella cambia. Es la base de la cadena de custodia.

```bash
sha256sum -c evidencias/SHA256SUMS
```
`-c` vuelve a calcular y compara: todo debe decir `OK`.

### Apagar el laboratorio

```bash
cd ~/Clase-02/objetivo
docker compose down
```
`down` detiene y elimina los contenedores y la red del laboratorio.

### Entrega

Un `.zip` de tu carpeta `~/pentest-qhapaq` con:

- [ ] `00-preacuerdo/`: carta mala corregida + reglas de enfrentamiento llenas
- [ ] `bitacora-pentest.md` con horas, tabla de servicios, modelado de amenazas y hipótesis
- [ ] `evidencias/` con `SHA256SUMS` (sin el CSV de clientes)
- [ ] `06-reporte/`: tabla CVSS, hallazgo H1 completo y resumen ejecutivo
- [ ] Las banderas que obtuviste, cada una con la hora en que la encontraste

---

## Errores comunes

| Síntoma | Causa probable | Solución |
|---|---|---|
| `permission denied ... docker.sock` | Tu usuario no está en el grupo `docker` | `sudo usermod -aG docker $USER` y vuelve a iniciar sesión |
| `docker: 'compose' is not a docker command` | Tienes la versión con guion | Usa `docker-compose` en lugar de `docker compose` |
| `Pool overlaps with other one on this address space` | Ya existe una red Docker 172.30.0.0/24 | `docker network ls` y borra la que sobra con `docker network rm NOMBRE` |
| `nmap` sale "0 hosts up" | Los contenedores no están corriendo | `docker compose ps` y `docker compose up -d` |
| `curl ftp://...` se queda colgado | El contenedor `files` se reinició | `docker compose restart files` |
| `ssh` dice *Host key verification failed* | Reconstruiste el laboratorio y la llave cambió | `ssh-keygen -R 172.30.0.20` |
| La calculadora CVSS da un puntaje distinto al de tu compañero | Eligieron métricas distintas | Discútanlo: justificar cada métrica es parte del trabajo |

---

## Para profundizar (opcional)

- PTES: pentest-standard.org
- OWASP Web Security Testing Guide v4.2 (estable): owasp.org/www-project-web-security-testing-guide
- NIST SP 800-115, *Technical Guide to Information Security Testing and Assessment*
- OSSTMM 3: isecom.org
- Ley 30096 de Delitos Informáticos (Perú) y sus modificatorias; Ley 29733 de Protección de Datos Personales
