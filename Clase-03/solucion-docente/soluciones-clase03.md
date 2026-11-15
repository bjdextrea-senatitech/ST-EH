# Solución docente · Clase 03 (NO subir: está en .gitignore)

## Banderas

| # | Bandera | Host | Técnica |
|---|---|---|---|
| 05 | `QHAPAQ{05-transferencia-de-zona-abierta}` | 10.30.0.53 | `dig axfr qhapaq.lab @10.30.0.53` → TXT `_flag` |
| 06 | `QHAPAQ{06-el-certificado-habla}` | 10.30.0.10:443 | `openssl s_client` + `x509 -subject` → campo OU |
| 07 | `QHAPAQ{07-snmp-comunidad-public}` | 10.30.0.161/udp | `snmpwalk -v2c -c public ... 1.3.6.1.2.1.1` → sysLocation |
| 08 | `QHAPAQ{08-sesion-nula-smb}` | 10.30.0.45 | `smbclient -N //10.30.0.45/publico` → organigrama.txt |
| 09 | `QHAPAQ{09-redis-sin-autenticacion}` | 10.30.0.60:6379 | `redis-cli -h 10.30.0.60 GET flag` |
| 10 | `QHAPAQ{10-banner-grabbing}` | 10.30.0.60:48620 | `nc -nv 10.30.0.60 48620` (solo aparece con `-p-`) |

## Inventario real (probado)

| Host | Puertos | Detalle |
|---|---|---|
| .53 ns1 | 53/tcp, 53/udp | BIND 9, `version.bind` = "BIND 9 - Qhapaq DNS interno", AXFR abierto |
| .10 www | 80, 443 | Apache 2.4.58 (Ubuntu) OpenSSL 3.0.13. **Señuelos**: `X-Powered-By: PHP/7.4.3` y `generator: WordPress 5.8.1` (no hay PHP ni WordPress: es HTML estático). SAN: www, intranet, dev, vpn-old, portal-rrhh |
| .25 mail | 25 | Postfix, `VRFY` habilitado. Existen: jdiaz, mquispe, rhuaman, soporte, gerencia (+ cuentas de sistema como root, backup). **No** existen cflores ni lmamani (las personas de gerencia y soporte usan cuentas de rol) |
| .45 files | 445 | Samba (nmap adivina "4.6.2", que es falso: es la de Ubuntu 24.04). Comparte `publico` (invitado) y `rrhh` (denegado). Firma SMB no obligatoria |
| .60 db | 2222, 6379, 48620 | OpenSSH 9.6p1 en 2222 (nmap sin `-sV` lo llama EtherNetIP-1), Redis 7.0.15 sin clave, agente propio en 48620 |
| .161 monitor | 161/udp, 199/tcp | net-snmp, comunidad `public`, contacto jdiaz@qhapaq.lab. 199/tcp = SMUX de snmpd |

Escaneo por defecto (top 1000) en .60 solo ve **2222**: 6379 y 48620 aparecen únicamente con `-p-`.

## Credenciales y datos para la Clase 04 (no se usan en la 03)

- SNMP, OID `1.3.6.1.2.1.25.4.2.1.5`: `/usr/local/bin/qhapaq-sync --server 10.30.0.60 --user svc_backup --password Backup2026!` → sirve para SSH en 10.30.0.60:2222 (**probado** que la cuenta existe con esa clave).
- SMB `politica-contrasenas.txt`: patrón `Empresa + Año + símbolo` (Qhapaq2019!) → diccionario dirigido para la Clase 04.
- Foto: WiFi `Qhapaq-Staff / Qhapaq2026!` (ojo: mismo patrón que la política).
- Usuarios válidos por SMTP: jdiaz, mquispe, rhuaman, soporte, gerencia.
- Redis: `sesion:jdiaz` (token ficticio).

## Nombres en certificado pero no en DNS

`vpn-old.qhapaq.lab` y `portal-rrhh.qhapaq.lab`: hosts antiguos o internos que nadie limpió. En el DNS, `vpn` (.200) y `jenkins` (.70) **no responden**: registros huérfanos. `erp` (.250) es del tercero.

## Correlación `jdiaz`

Foto (Artist EXIF) · intranet ("Soporte TI: jdiaz@") · SNMP sysContact · buzón SMTP válido · organigrama (Jefe de TI). Conclusión esperada: es el administrador de TI, publica fotos con metadatos y su cuenta probablemente tiene privilegios → objetivo prioritario de phishing o de contraseñas.

## Lab 4

- foto-oficina.jpg: Samsung SM-A546E, autor jdiaz, 2026-10-03 09:14:22, GPS -16.398889, -71.536944 = Plaza de Armas de Arequipa (aprox.), descripción "Rack nuevo piso 2 - listo!". Visible: nota adhesiva con el WiFi y su clave.
- comunicado-editado.jpg: Software "Adobe Photoshop 25.0 (Windows)", ModifyDate 2026-11-10 23:51:07. El ELA marca la fecha "15 de noviembre" (decía "30 de noviembre"). Verificado con ELA propio: brillo medio 2.7 en el parche contra 0.4 en el resto.
- Las dos imágenes son sintéticas (generadas para la clase). La de la oficina **no** es una foto real, así que la búsqueda inversa no va a encontrar nada: por eso el 4.3 usa una foto pública de Wikimedia.

## Lab 1 y 2 (respuestas esperadas, cambian con el tiempo)

- vulnweb.com: subdominios típicos testphp, testhtml5, testasp, testaspnet, rest. Verificar en vivo antes de clase.
- zonetransfer.me: el AXFR devuelve decenas de registros, incluidos algunos "jugosos" puestos a propósito (registros internos, comentarios, ubicaciones).
- InternetDB de scanme.nmap.org (45.33.32.156): suele mostrar 22 y 80 entre otros. Verificar en vivo.

## Notas técnicas del entorno

- `nmap --script smb-enum-shares` no muestra nada contra Samba moderno (solo SMB2/3): por eso la guía usa `smbclient`. Alternativa en Kali: `nxc smb 10.30.0.45 -u '' -p '' --shares` (no probado aquí).
- `nmap --script smtp-enum-users` y `dns-zone-transfer` tampoco dieron salida contra este laboratorio con nmap 7.94: por eso la guía usa el bucle con `nc` y `dig`. Probar en Kali si quieres mostrarlos.
- `snmp-processes` de nmap **sí** muestra la contraseña del agente: buen atajo para mostrar en vivo.
- Si un alumno tocó .250: `docker logs qi-erp`. Para limpiar: `docker compose up -d --force-recreate erp-proveedor`.
