# Teoría breve — Explotación de servicios (Clase 05)

## La metodología (4 pasos, para TODO servicio)
1. **Escaneo del host** — ¿qué puertos abiertos? `nmap -p- -sS` (TCP) y `nmap -sU --top-ports 50` (UDP).
2. **Detección del servicio** — ¿qué software y versión? `nmap -sV -sC`.
3. **Enumeración** — exprimir el servicio *antes* de disparar: usuarios, shares, bases, config, banners.
4. **Explotación** — por **mala práctica de configuración** o por **CVE** (con su exploit).

> Regla de oro: el 80% del éxito está en la **enumeración**. Disparar sin enumerar es ruido.

## CVE vs mala práctica
- **CVE**: fallo del *software* (ej. `CVE-2015-3306` en ProFTPd). Se parchea **actualizando**.
- **Mala práctica**: fallo de *configuración* (sin auth, clave débil, permiso de más, comunidad por defecto, relay abierto). No la ve un escáner de CVEs; se encuentra **enumerando**. Se corrige **configurando bien**.

## Vocabulario mínimo
| Término | En una línea |
|---|---|
| RCE | Ejecución remota de código: el premio mayor. |
| LPE | Escalada local (de usuario a root/SYSTEM). |
| Shell "como www-data/postgres/redis" | **No** es root: casi siempre falta una escalada. |
| Hash NT / Pass-the-Hash | Autenticar con el hash sin conocer la clave. |
| Kerberoasting / AS-REP | Sacar tickets Kerberos y crackear claves **offline**. |
| GTFOBins | Binarios legítimos (tar, find…) que con `sudo` dan root. |
| CVSS | Puntaje de gravedad de un CVE (0–10). |

## Los CVE de hoy (para reconocerlos)
- **CVE-2015-3306** — ProFTPd `mod_copy`: `SITE CPFR/CPTO` copian archivos **sin login**.
- **CVE-2014-6271 (Shellshock)** — bash ejecuta código escondido en variables de entorno (CGI).
- **CVE-2014-0160 (Heartbleed)** — OpenSSL devuelve hasta 64 KB de **RAM** por un heartbeat mal medido.
- **CVE-2019-9193** — PostgreSQL `COPY ... FROM PROGRAM` ejecuta comandos del SO.
- **CVE-2021-38647 (OMIGOD)** — agente OMI/WinRM: SOAP sin auth = comandos como **root**.

## Las malas prácticas de hoy
- **Redis** sin contraseña → escribe `authorized_keys` = RCE.
- **MySQL** con privilegio `FILE` + `secure_file_priv` vacío → `INTO OUTFILE` = webshell.
- **SMB/rpcclient** sesión nula → usuarios y descripciones con claves.
- **Kerberos**: cuenta sin preautenticación (AS-REP) y cuenta de servicio con SPN y clave débil (Kerberoast).
- **GPP** `cpassword` en SYSVOL (clave AES publicada por Microsoft).
- **SNMP** comunidades `public`/`private` por defecto.
- **VNC/RDP/SSH/VoIP/RADIUS** con credenciales/secretos débiles.
- **SMTP** relay abierto + `VRFY`.
- **Impresoras** CUPS/IPP y 9100 expuestos.

## Ética (Perú)
Ley 30096 (art. 2 "accede o se excede en lo autorizado"; art. 12 exención si hay **autorización**). Todo esto
es legal **solo** sobre tu laboratorio o con permiso escrito. Fuera de `qhapaq-sede` no se toca nada.
