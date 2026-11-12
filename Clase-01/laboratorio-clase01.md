# Clase 01 · Linux para Pentesting · Laboratorio con OverTheWire Bandit

**SENATI · Diplomado en Gestión de la Ciberseguridad · Módulo 05: Ethical Hacking y Seguridad Ofensiva**
**Capítulo 1 del sílabo:** comandos útiles en Linux · conexiones SSH · manejo de servicios · bash scripting básico

---

## Agenda (3 horas)

| Bloque | Min | Qué hacemos |
|---|---|---|
| Teoría (PPT) | 30 | Linux, terminal, SSH, permisos, pipes, servicios, bash |
| Lab 0 · Preparar | 10 | Verificar entorno, carpeta de claves, primer SSH |
| Lab 1 · Archivos y búsqueda | 35 | Bandit 0 → 10 |
| Pausa | 10 | |
| Lab 2 · Datos, red y llaves | 35 | Bandit 10 → 20 |
| Lab 3 · Cron y bash scripting | 25 | Bandit 20 → 25 |
| Lab 4 · Escapes, git y variables | (tarea) | Bandit 25 → 34. Si terminas antes, sigue en clase |
| Lab 5 · Servicios en Linux | 15 | systemctl, ss, journalctl en tu VM |
| Entrega | 10 | Bitácora en GitHub |

**Meta en clase:** llegar como mínimo a **bandit20**. Los rápidos van por **bandit25**. Del 25 al 34 queda de tarea.

---

## Reglas del juego

1. **Bandit es un servidor público y legal para practicar.** Lo administra OverTheWire. Fuera de él, lo que aprendas hoy solo se usa contra equipos propios o con autorización por escrito.
2. **Las contraseñas no se publican.** Ni en GitHub, ni en el chat del curso, ni en capturas. OverTheWire lo pide expresamente. En la bitácora van **comandos e ideas**, no claves.
3. **No rompas nada del servidor** y no dejes procesos corriendo. Lo comparte gente de todo el mundo.
4. **Trabaja en carpetas temporales propias:** `mktemp -d` te da una carpeta única en `/tmp`. Nadie puede listar `/tmp`, pero si eliges un nombre fácil, otro jugador lo adivina.
5. **Lee el enunciado de cada nivel** en https://overthewire.org/wargames/bandit/ (cada nivel tiene su página). La teoría de apoyo de cada nivel está en https://mayadevbe.me/posts/overthewire/bandit/overview/. Esta guía te da los comandos y las pistas, no la respuesta.
6. **`man` primero, Google después.** `man find` explica en 2 minutos lo que buscas en 10.

---

## Lab 0 · Preparar el entorno (10 min)

Trabaja en tu **Kali** (VirtualBox) o en **Ubuntu/WSL**. En Windows puro también sirve `ssh` desde PowerShell para los primeros niveles, pero desde el nivel 13 necesitas `scp`, `nc` y `openssl`: mejor Kali.

```bash
# Clona el repo del curso (tu docente te da la URL) y entra a la carpeta de la clase.
git clone <URL-del-repo-del-curso>
cd <repo>/Clase-01/scripts

# Revisa que tengas todas las herramientas y que llegues al servidor (solo lee, no cambia nada).
bash 00-verificar-entorno.sh
```

Si falta algo:

```bash
# apt instala paquetes; -y responde "sí" automáticamente.
sudo apt update && sudo apt install -y openssh-client netcat-openbsd openssl nmap git file xxd binutils bzip2
```

Primer ingreso, **escrito a mano** (apréndete la forma):

```bash
# ssh: cliente de shell segura. -p 2220 cambia el puerto (por defecto es 22). usuario@servidor.
ssh -p 2220 bandit0@bandit.labs.overthewire.org
```

- La primera vez pregunta si confías en la huella del servidor: escribe `yes`.
- La contraseña **no se ve** mientras escribes. Es normal.
- Para salir del servidor: `exit` (o `Ctrl + D`).

Prepara **en tu máquina** (no en el servidor) una carpeta privada para las claves:

```bash
mkdir -p ~/bandit/claves ~/bandit/llaves      # -p crea toda la ruta y no falla si ya existe
chmod 700 ~/bandit                            # 700 = rwx solo para ti; grupo y otros no entran
ls -ld ~/bandit                               # -d muestra los permisos de la carpeta, no su contenido
```

Cada vez que encuentres una clave, sal del servidor (`exit`) y guárdala:

```bash
nano ~/bandit/claves/bandit1                  # pega la clave, Ctrl+O para guardar, Ctrl+X para salir
chmod 600 ~/bandit/claves/bandit1             # 600 = rw- solo para ti
cat ~/bandit/claves/bandit1                   # para copiarla cuando ssh te la pida
```

Para entrar al siguiente nivel escribe siempre el comando completo: cambia solo el número de `banditN`.

**✅ Checkpoint 0:** estás dentro como `bandit0` y `whoami` responde `bandit0`.

---

## Lab 1 · Archivos y búsqueda · Bandit 0 → 10 (35 min)

### Nivel 0 → 1 · Leer un archivo
**Objetivo:** la clave está en un archivo `readme` en tu carpeta personal.

```bash
pwd                  # muestra en qué carpeta estás (tu "home": /home/bandit0)
ls                   # lista lo que hay en la carpeta actual
cat readme           # imprime el contenido de un archivo
```

### Nivel 1 → 2 · Archivo llamado `-`
**Objetivo:** la clave está en un archivo llamado `-`.

```bash
ls -l                # -l: formato largo (permisos, dueño, tamaño, fecha)
cat ./-              # "./" dice "el archivo - de esta carpeta"; sin eso, cat cree que "-" es el teclado
```

**Pista:** muchos comandos interpretan `-` como "entrada estándar". Indicar la ruta rompe la ambigüedad.

### Nivel 2 → 3 · Espacios (y guiones) en el nombre
**Objetivo:** el nombre del archivo tiene espacios.

```bash
ls -l                         # observa el nombre completo
cat "nombre con espacios"     # las comillas mantienen el nombre como UNA sola palabra
cat -- "--nombre"             # "--" le dice al comando: "lo que sigue ya no son opciones"
```

**Pista:** la tecla **Tab** autocompleta y escapa los espacios por ti. Combina comillas y `./` o `--`.

### Nivel 3 → 4 · Archivos ocultos
**Objetivo:** la clave está en un archivo oculto dentro de `inhere`.

```bash
cd inhere            # cambia de carpeta
ls -la               # -a: muestra también los archivos que empiezan con "." (ocultos)
```

**Pista:** el nombre empieza con puntos. Cópialo con Tab.

### Nivel 4 → 5 · El único archivo legible por humanos
**Objetivo:** en `inhere` hay varios archivos; solo uno es texto.

```bash
file ./inhere/*      # file mira los primeros bytes ("firma") y dice qué tipo de archivo es
```

**Pista:** busca la respuesta `ASCII text`. Los nombres empiezan con `-`: por eso `./`.

### Nivel 5 → 6 · Buscar por propiedades
**Objetivo:** archivo en `inhere` que sea legible, de **1033 bytes** y **no ejecutable**.

```bash
find inhere -type f -size 1033c                  # -type f: solo archivos; -size 1033c: 1033 bytes exactos (c = bytes)
find inhere -type f -size 1033c ! -executable    # "!" niega la condición que sigue
```

### Nivel 6 → 7 · Buscar en todo el servidor
**Objetivo:** archivo en **cualquier parte** del servidor, dueño `bandit7`, grupo `bandit6`, de 33 bytes.

```bash
find / -type f -user bandit7 -group bandit6 -size 33c                # "/" es la raíz: busca en todo el disco
find / -type f -user bandit7 -group bandit6 -size 33c 2>/dev/null    # 2> redirige los errores (canal 2) a la "basura"
```

**Pista:** sin `2>/dev/null` verás cientos de "Permission denied" y te costará encontrar el resultado.

### Nivel 7 → 8 · grep
**Objetivo:** la clave está en `data.txt` al lado de la palabra `millionth`.

```bash
wc -l data.txt               # wc -l cuenta líneas: confirma que el archivo es enorme
grep millionth data.txt      # grep imprime solo las líneas que contienen el texto buscado
```

### Nivel 8 → 9 · La línea que no se repite
**Objetivo:** en `data.txt`, la clave es la única línea que aparece **una sola vez**.

```bash
sort data.txt | head                 # sort ordena líneas; "|" (pipe) pasa la salida de uno a la entrada del otro
sort data.txt | uniq -c | head       # uniq -c cuenta repeticiones SEGUIDAS (por eso primero se ordena)
sort data.txt | uniq -u              # uniq -u muestra solo las líneas que no se repiten
```

### Nivel 9 → 10 · strings
**Objetivo:** `data.txt` es binario; la clave es texto legible precedida por varios `=`.

```bash
file data.txt                        # confirma que es "data", no texto
strings data.txt | grep "==="        # strings extrae secuencias de caracteres imprimibles de un binario
```

**✅ Checkpoint 1:** tienes guardada la clave de `bandit10`. Anota en tu bitácora qué comando te costó más.

---

## Lab 2 · Datos, red y llaves · Bandit 10 → 20 (35 min)

### Nivel 10 → 11 · Base64
**Objetivo:** `data.txt` está codificado en base64.

```bash
cat data.txt                 # el "=" al final es típico de base64
base64 -d data.txt           # -d decodifica (codificar NO es cifrar: no hay clave)
```

### Nivel 11 → 12 · ROT13 con tr
**Objetivo:** las letras de `data.txt` están rotadas 13 posiciones.

```bash
echo "Hola" | tr 'A-Za-z' 'N-ZA-Mn-za-m'     # tr traduce carácter por carácter: A→N, B→O ... (prueba con "Hola")
tr 'A-Za-z' 'N-ZA-Mn-za-m' < data.txt        # "<" usa el archivo como entrada del comando
```

### Nivel 12 → 13 · Hexdump y compresión en capas
**Objetivo:** `data.txt` es un **hexdump** de un archivo que fue comprimido varias veces.

```bash
DIR=$(mktemp -d)                 # crea una carpeta única en /tmp y guarda su ruta en la variable DIR
cp data.txt "$DIR"               # copia el archivo (en tu home no puedes escribir)
cd "$DIR"                        # trabaja ahí
xxd -r data.txt > datos          # xxd -r revierte el hexdump a los bytes originales
file datos                       # te dice con qué se comprimió: gzip, bzip2 o tar
mv datos datos.gz                # gzip exige la extensión .gz para descomprimir
gzip -d datos.gz                 # -d descomprime
bzip2 -d datos                   # descomprime bzip2 (renombra a datos.out)
tar -xf archivo                  # -x extrae, -f indica el archivo (tar empaqueta, no siempre comprime)
```

**Pista:** el ciclo es siempre **file → renombrar si hace falta → descomprimir → file otra vez**, hasta que `file` diga `ASCII text`. Son unas 8–9 capas. Al terminar: `rm -rf "$DIR"`.

### Nivel 13 → 14 · Entrar con llave privada
**Objetivo:** no hay clave: hay una **llave privada SSH** (`sshkey.private`) para entrar como `bandit14`.

Desde **tu máquina** (no desde el servidor):

```bash
mkdir -p ~/bandit/llaves                                    # carpeta para guardar llaves
scp -P 2220 bandit13@bandit.labs.overthewire.org:sshkey.private ~/bandit/llaves/bandit14.key
                                                            # scp copia archivos por SSH; ojo: aquí el puerto va con -P mayúscula
chmod 600 ~/bandit/llaves/bandit14.key                      # ssh rechaza llaves que otros puedan leer
ssh -i ~/bandit/llaves/bandit14.key -p 2220 bandit14@bandit.labs.overthewire.org
                                                            # -i indica la llave (identidad) a usar
```

Ya dentro como `bandit14`:

```bash
cat /etc/bandit_pass/bandit14        # cada usuario puede leer SU propia clave aquí: guárdala, la necesitas ya
```

### Nivel 14 → 15 · Primera conexión de red con nc
**Objetivo:** envía la clave de `bandit14` al puerto **30000** de `localhost`.

```bash
nc localhost 30000                                   # netcat abre una conexión TCP "cruda": lo que escribes viaja tal cual
cat /etc/bandit_pass/bandit14 | nc localhost 30000   # versión sin teclear: el pipe manda el contenido del archivo
```

### Nivel 15 → 16 · Lo mismo, pero con TLS
**Objetivo:** el puerto **30001** habla **SSL/TLS**: nc no sirve.

```bash
openssl s_client -connect localhost:30001                    # cliente TLS: hace el "apretón de manos" y luego te deja escribir
openssl s_client -connect localhost:30001 -quiet             # -quiet oculta el certificado y deja solo la conversación
```

**Pista:** pega la clave de `bandit15` y presiona Enter. Si se corta antes de responder, agrega `-ign_eof`.

### Nivel 16 → 17 · Escaneo de puertos con nmap
**Objetivo:** entre los puertos **31000–32000** hay uno con TLS que devuelve las credenciales.

```bash
nmap -p 31000-32000 localhost              # -p rango de puertos: ¿cuáles están abiertos?
nmap -sV -p 31000-32000 localhost          # -sV identifica el servicio de cada puerto (tarda más; ten paciencia)
```

**Pista:** los que dicen `echo` repiten lo que les mandas. Busca los que hablan `ssl`. Prueba con `openssl s_client` (como en el nivel 15) mandando la clave de bandit16. Lo que recibes no es una clave: es una **llave privada**. Guárdala en `~/bandit/llaves/bandit17.key` en tu máquina, aplica `chmod 600` y entra con `-i`, igual que en el nivel 13.

### Nivel 17 → 18 · diff
**Objetivo:** la clave es la única línea que cambió entre `passwords.old` y `passwords.new`.

```bash
diff passwords.old passwords.new     # diff muestra diferencias: "<" línea del primero, ">" línea del segundo
```

**Pista:** la clave es la del archivo **nuevo**. Al entrar como bandit18 te sacará de inmediato: ese es el siguiente reto.

### Nivel 18 → 19 · Ejecutar un comando remoto sin shell
**Objetivo:** el `.bashrc` de `bandit18` te desconecta al entrar. La clave está en `readme`.

```bash
ssh -p 2220 bandit18@bandit.labs.overthewire.org ls          # todo lo que va después del servidor se ejecuta allá y vuelve
ssh -p 2220 bandit18@bandit.labs.overthewire.org cat readme  # sin shell interactiva, el .bashrc no se carga
```

### Nivel 19 → 20 · Binarios setuid
**Objetivo:** usa el binario `bandit20-do` de tu home.

```bash
ls -l bandit20-do                    # mira la "s" en los permisos: rws = setuid (corre con los permisos de su DUEÑO)
./bandit20-do                        # sin argumentos te explica su uso
./bandit20-do id                     # compara: "euid" (usuario efectivo) ya no eres tú
```

**Pista:** si corre comandos como `bandit20`, ¿qué archivo de `/etc/bandit_pass/` puedes leer?

**✅ Checkpoint 2:** tienes la clave de `bandit20`. Esta es la **meta mínima** de la clase.

---

## Lab 3 · Cron y bash scripting · Bandit 20 → 25 (25 min)

### Nivel 20 → 21 · Dos procesos que se hablan
**Objetivo:** `suconnect` se conecta al puerto que le digas. Si recibe la clave de bandit20, responde con la de bandit21.

```bash
./suconnect                                          # lee su modo de uso
nc -l -p 4444 < /etc/bandit_pass/bandit20 &          # -l escucha; "&" lo deja en segundo plano y te devuelve la terminal
jobs                                                 # lista los trabajos en segundo plano de esta terminal
./suconnect 4444                                     # se conecta a tu "servidor" nc
```

**Pista:** si el puerto 4444 está ocupado por otro jugador, usa otro número alto (por ejemplo 4xxxx). Si tu nc no acepta `-p`, usa `nc -l 4444`.

### Nivel 21 → 22 · Leer un cron
**Objetivo:** un programa corre solo cada minuto vía **cron**. Averigua qué hace.

```bash
ls -l /etc/cron.d/                           # aquí viven las tareas programadas del sistema
cat /etc/cron.d/cronjob_bandit22             # formato: minuto hora día mes día_semana usuario comando  (* = siempre)
cat /usr/bin/cronjob_bandit22.sh             # lee el script que ejecuta: ahí está la pista
```

### Nivel 22 → 23 · Entender un script
**Objetivo:** igual que el anterior, pero el script calcula el nombre del archivo.

```bash
cat /etc/cron.d/cronjob_bandit23
cat /usr/bin/cronjob_bandit23.sh             # lee cada línea: $(...) ejecuta un comando y usa su salida
echo I am user bandit23 | md5sum             # md5sum calcula un hash: siempre da lo mismo para el mismo texto
echo I am user bandit23 | md5sum | cut -d ' ' -f 1     # cut -d ' ' -f 1: toma la primera "columna" separada por espacios
```

**Pista:** el script usa `$(whoami)`. ¿Qué devolvería si lo ejecuta **bandit23**?

### Nivel 23 → 24 · Tu primer script (lo ejecuta otro usuario)
**Objetivo:** el cron de `bandit24` ejecuta **y borra** todo script que pongas en `/var/spool/bandit24/foo/`.

```bash
cat /usr/bin/cronjob_bandit24.sh             # léelo completo: ¿qué ejecuta?, ¿qué condición revisa?
DIR=$(mktemp -d)                             # tu carpeta temporal
chmod 777 "$DIR"                             # bandit24 necesita poder escribir en ella
nano "$DIR/copiar.sh"                        # escribe tu script (ver estructura abajo)
chmod 755 "$DIR/copiar.sh"                   # permiso de ejecución para todos (si no, cron no lo corre)
cp "$DIR/copiar.sh" /var/spool/bandit24/foo/copiar-$RANDOM.sh   # $RANDOM da un número al azar: evita choques con otros
sleep 60; ls -l "$DIR"                       # espera un minuto y revisa
```

Estructura del script (complétalo tú):

```bash
#!/bin/bash
# Línea 1 (shebang): dice qué intérprete ejecuta el archivo.
# TODO: lee la clave de bandit24 y escríbela en un archivo dentro de tu $DIR (pon la ruta completa).
```

### Nivel 24 → 25 · Fuerza bruta con un bucle
**Objetivo:** el servicio de `localhost:30002` quiere `<clave de bandit24> <PIN de 4 dígitos>`. No conoces el PIN.

```bash
nc localhost 30002                           # pruébalo a mano una vez: mira el formato y el mensaje de error
seq -w 0 9999 | head                         # seq genera números; -w rellena con ceros (0000, 0001...)
for i in 1 2 3; do echo "intento $i"; done   # estructura de un bucle for en bash
nc -N localhost 30002 < archivo.txt          # -N: cuando se acaba el archivo, avisa al servidor y espera todas sus respuestas
```

Trabaja en el servidor, dentro de una carpeta temporal propia. El bucle `for` arma el archivo con los 10 000 intentos y `nc -N` lo envía:

```bash
cd "$(mktemp -d)"                                    # entra a una carpeta única en /tmp
CLAVE=$(cat /etc/bandit_pass/bandit24)               # lee tu propia clave (no la escribas a mano)
for PIN in $(seq -w 0 9999); do                      # recorre 0000 ... 9999
    echo "$CLAVE $PIN"                               # una línea por intento
done > intentos.txt                                  # todo va al archivo
wc -l intentos.txt                                   # deben ser 10000 líneas
nc -N localhost 30002 < intentos.txt | grep -v Wrong # envía todo y descarta los "Wrong"
```

**Reflexión:** esto es lo que hace Hydra contra un login. ¿Qué tres controles lo habrían frenado?

**✅ Checkpoint 3:** tienes la clave de `bandit25`.

---

## Lab 4 · Escapes, git y variables · Bandit 25 → 34 (tarea)

| Nivel | Tema | Comandos y pistas |
|---|---|---|
| 25 → 26 | Shell restringida | `cat /etc/passwd \| grep bandit26` (mira su shell). Copia `bandit26.sshkey` con `scp`. Al entrar usa `more`: **achica la ventana de tu terminal** para que no termine, pulsa `v` (abre `vim`). En vim: `:set shell=/bin/bash` y luego `:shell`. |
| 26 → 27 | setuid otra vez | Desde la shell que conseguiste: `ls -l` y el binario `bandit27-do` (igual que el nivel 19). |
| 27 → 28 | Git básico | `git clone ssh://bandit27-git@bandit.labs.overthewire.org:2220/home/bandit27-git/repo` desde tu máquina. `ls -la`, `cat`. |
| 28 → 29 | Historial | `git log` (commits), `git log -p` (con cambios), `git show <commit>`. Lo borrado sigue en la historia. |
| 29 → 30 | Ramas | `git branch -a` (todas las ramas, también remotas), `git checkout <rama>`. |
| 30 → 31 | Etiquetas | `git tag` lista etiquetas; `git show <etiqueta>`. |
| 31 → 32 | Subir cambios | Lee el README. `git add`, `git commit -m`, `git push`. Si `git add` "no hace nada", mira `.gitignore` y la opción `-f`. |
| 32 → 33 | Variables | La "uppershell" pone todo en MAYÚSCULAS. ¿Qué variable especial no tiene minúsculas y contiene el nombre de la shell? (`$0`). |
| 33 → 34 | Fin | Lee el `README.txt`. 🎉 |

**Lección de seguridad del Lab 4:** en el nivel 28 → 29 la clave se "borró" en un commit, pero sigue en el historial. Pasa en empresas reales (claves de AWS en GitHub). Herramientas como `gitleaks` y `trufflehog` buscan justo eso.

---

## Lab 5 · Servicios en Linux (15 min) · en TU VM, no en Bandit

Bandit no te deja administrar servicios. Esto se hace en tu Kali o Ubuntu.

```bash
systemctl status ssh                         # estado del servicio SSH (en Kali se llama "ssh"; en otras distros puede ser "sshd")
sudo systemctl start ssh                     # lo inicia ahora
ss -tlnp                                     # ss lista sockets: -t TCP, -l escuchando, -n números, -p proceso (con sudo)
sudo ss -tlnp | grep ':22'                   # confirma que ahora escucha en el puerto 22
sudo systemctl enable ssh                    # lo deja arrancando solo en cada inicio
systemctl is-enabled ssh                     # responde enabled / disabled
journalctl -u ssh -n 20 --no-pager           # últimas 20 líneas del log de ese servicio
sudo systemctl stop ssh                      # lo detiene
sudo systemctl disable ssh                   # y que no arranque solo (en una VM de pentest, menos servicios = menos superficie)
```

Mira qué puertos quedan expuestos a la red (los que vería un `nmap` desde otra máquina):

```bash
sudo ss -tulnp                               # todos los sockets en escucha, con su proceso
ss -tln | grep -v '127.0.0.1\|::1'           # deja fuera lo que solo escucha en la propia máquina
```

**Pregunta:** ¿qué puertos de tu VM vería un `nmap` desde otra máquina de la red? Anótalos en la bitácora.

**✅ Checkpoint 5:** sabes iniciar, detener, habilitar y revisar el log de un servicio.

---

## Entrega (10 min)

1. Haz **fork** del repo del curso y clónalo.
2. Copia `Clase-01/plantillas/bitacora-bandit.md` a `Clase-01/entregas/<tu-apellido>.md`.
3. Llénala: **comandos e ideas, nunca contraseñas**.
4. Antes de subir, verifica que no se te escapó ninguna clave:

```bash
grep -E '[A-Za-z0-9]{32}' entregas/<tu-apellido>.md      # busca textos de 32 caracteres seguidos (el formato de las claves). Debe salir vacío.
```

5. `git add`, `git commit -m "Clase 01 - <tu nombre>"`, `git push` y abre el **Pull Request**.

---

## Errores comunes

| Síntoma | Causa | Solución |
|---|---|---|
| `Permission denied (publickey,password)` | Clave mal copiada o usuario equivocado | Revisa espacios al final; usuario = `banditN` del nivel al que entras |
| `ssh: connect to host ... port 22` | Olvidaste `-p 2220` | El puerto es 2220 |
| `scp` no conecta | Usaste `-p` minúscula | En `scp` el puerto es `-P` mayúscula |
| `WARNING: UNPROTECTED PRIVATE KEY FILE!` | Llave con permisos abiertos | `chmod 600 llave` |
| `cat: -: ...` o el comando se queda esperando | El nombre empieza con `-` | `cat ./-` o `cat -- nombre` |
| `Permission denied` al crear archivos en tu home | En Bandit tu home es de solo lectura | Trabaja en `DIR=$(mktemp -d)` |
| `find` llena la pantalla de errores | No tienes permiso en muchas carpetas | Agrega `2>/dev/null` |
| `gzip: unknown suffix -- ignored` | gzip exige extensión `.gz` | `mv archivo archivo.gz` |
| El cron no ejecuta tu script (nivel 23) | Sin `chmod +x` o carpeta destino sin permisos | `chmod 755` al script y `chmod 777` a tu `$DIR` |
| `nc: Address already in use` (nivel 20) | Otro jugador usa ese puerto | Elige otro número alto |
| En el nivel 25 no aparece `--More--` | La ventana es demasiado grande | Achica la terminal antes de conectarte |
| El servidor se siente lento | Muchos jugadores a la vez | Paciencia; reintenta. No es tu culpa |

---

## Para seguir practicando

- **OverTheWire Leviathan** (siguiente wargame después de Bandit) y **Natas** (web: sirve para el Capítulo 5).
- `explainshell.com`: pegas un comando y te explica cada parte.
- `man bash`, sección *Pipelines* y *Redirection*.
