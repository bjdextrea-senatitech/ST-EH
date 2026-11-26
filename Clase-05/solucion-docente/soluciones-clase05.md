# SOLUCIONARIO DOCENTE — Clase 05 (NO repartir) · verificado end-to-end en sandbox

## Tabla de banderas y credenciales
| 🚩 | Host (IP) | Técnica | Credencial / clave | Comprobado |
|---|---|---|---|---|
| 41 | mgmt .11 | OMIGOD WinRM (CVE-2021-38647) | — (sin auth) | ✅ `id=root` + flag |
| 42 | dc01 .10 | rpcclient sesión nula | — | ✅ descripción svc_impresion |
| 43 | dc01 .10 | AS-REP roast | pramos:**sunshine1** (rockyou L641) | ✅ hashcat 18200 |
| 44 | dc01 .10 | Kerberoast | svc_sql:**Password123** | ✅ hashcat 13100 (ccacheroast) |
| 45 | dc01 .10 | GPP cpassword | adm_soporte:**Soporte#Qhapaq2026** | ✅ AES MS-GPPREF |
| 46 | dc01 .10 | Pass-the-Hash DA | hash NT de Soporte#Qhapaq2026 = `460071c104b69873bba310a040d1cd0c` | ✅ smbclient --pw-nt-hash |
| 47 | ftp .21 | ProFTPd mod_copy (CVE-2015-3306) | — (sin login) | ✅ CPFR/CPTO |
| 48 | ssh .22 | fuerza bruta | soporte:**verano2025** | ✅ hydra |
| 48b| ssh .22 | sudo tar GTFOBins → root | — | ✅ |
| 49 | rdp .38 | credencial débil | gerencia:**Gerencia#2025** | ⚠️ puerto 3389 OK (login no scripteado) |
| 50 | mysql .33 | FILE → INTO OUTFILE webshell | webapp:**W3bApp#2023** | ✅ RCE www-data |
| 50a| mysql .33 | secreto en tabla | — | ✅ |
| 51 | postgres .32 | COPY FROM PROGRAM (CVE-2019-9193) | appsql:**Postgr3s#2024** (superuser) | ✅ RCE postgres |
| 52 | mssql .14 | sa débil (nube) | sa:**Qhapaq#2023** | ⛔ imagen mcr (en Kali) |
| 52b| mssql .14 | xp_cmdshell RCE (nube) | — | ⛔ en Kali |
| 53 | legacy .43 | Shellshock (CVE-2014-6271) | — | ✅ |
| 54 | legacy .43 | Heartbleed (CVE-2014-0160) | — | ✅ (fuga ~15 intentos → token) |
| 55 | redis .63 | sin auth → SSH key RCE | — | ✅ shell redis@ |
| 56 | mongo .27 | NoSQL sin auth (nube) | — | ⛔ imagen mongo:6 (en Kali) |
| 57 | snmp .161 | EXTEND expone salida de comandos | community **public** | ✅ |
| 57a| snmp .161 | fuga sysLocation | community **public** | ✅ |
| 58 | vnc .59 | password débil | **monkey12** (rockyou L3247) | ✅ hydra vnc |
| 59 | voip .60 | SIP enum + secreto | 1002:**verano2025** | ✅ svwar + svcrack |
| 60 | radius .18 | secreto compartido | NAS **testing123**, admin-wifi:**Wifi.Qhapaq!2026** | ✅ radtest Accept |
| 61 | printers .31 | CUPS/IPP expuesto | — | ✅ lpstat -l remoto |
| 62 | smtp .25 | open relay + VRFY | — | ✅ 252/550 + relay 250 |

> ⚠️ RDP: xrdp autentica contra el usuario local `gerencia` por PAM; el puerto y el usuario están verificados, el login interactivo no se automatizó en el sandbox (igual que la bandera 20 de C4).
> ⛔ MSSQL y Mongo usan imágenes oficiales (mcr/dockerhub) bloqueadas en el sandbox: se validan en el Kali del alumno con internet. Config estándar y probada documentalmente.

## Cadena narrativa sugerida (para guiar en vivo)
1. **rpcclient nula** (42) → la descripción de `svc_impresion` da `Impresora2026!`.
2. Esa cuenta lee **SYSVOL** → **GPP** (45) → `adm_soporte:Soporte#Qhapaq2026` que es **Domain Admin** → **PtH/DCSync** (46) = dominio completo.
3. En paralelo: **AS-REP** (43, pramos) → con pramos haces **Kerberoast** (44) → `svc_sql`.
4. Servicios "sueltos" (47–62) son independientes: cada grupo ataca varios a la vez.

## GPP — descifrar cpassword a mano (por si falta gpp-decrypt)
```python
import base64
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
cp="<cpassword>"; cp+="="*(-len(cp)%4)
key=bytes.fromhex("4e9906e8fcb66cc9faf49310620ffee8f496e806cc057990209b09a433b66c1b")  # clave pública MS-GPPREF
d=Cipher(algorithms.AES(key),modes.CBC(b"\x00"*16)).decryptor()
p=d.update(base64.b64decode(cp))+d.finalize(); print(p[:-p[-1]].decode("utf-16-le"))
```

## Kerberoast en Samba — nota técnica
Samba 4.19 (Heimdal) exige preautenticación a todo por defecto; el lab la desactiva a nivel KDC
(`/etc/krb5.conf [kdc] require-preauth = false`) para que el flag `DONT_REQ_PREAUTH` de `pramos`
se respete como en un AD real. El TGS de impacket puede fallar con `KRB_AP_ERR_INAPP_CKSUM` contra
Heimdal; alternativa fiable usada aquí: `kinit` + `minikerberos-ccacheroast` (paquete `kerberoast`).
En el Kali del alumno contra este mismo DC, `impacket-GetUserSPNs` suele funcionar; si no, usar la vía kinit.

## Reinicio entre grupos
`docker compose restart qx-<servicio>` (redis/mysql/postgres regeneran estado). El DC conserva el dominio
(marca `/var/lib/samba/.qhapaq-listo`); para re-aprovisionar: `docker compose down && docker compose up -d`.

## Diccionarios usados
- rockyou.txt (AS-REP sunshine1 L641, Kerberoast Password123).
- Claves "de empresa" (verano2025, Gerencia#2025, Wifi.Qhapaq!2026): van en un `claves.txt` dirigido que arma el alumno.
