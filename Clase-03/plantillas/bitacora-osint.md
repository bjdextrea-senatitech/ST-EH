# Bitácora de reconocimiento · Clase 03

**Analista:** ______________________ · **Fecha:** ____________

> Cada hallazgo lleva: la consulta o comando exacto, la fecha y hora, y el archivo de evidencia.

## Lab 1 · OSINT de organizaciones (vulnweb.com / zonetransfer.me)

### Dorks

| Dork | N.° resultados | Qué descubrí |
|---|---|---|
| `site:vulnweb.com` | | |
| `site:vulnweb.com -www` | | |
| `site:vulnweb.com inurl:php` | | |
| `site:vulnweb.com intitle:login` | | |
| `site:vulnweb.com ext:txt OR ext:xml OR ext:bak` | | |
| `"vulnweb.com" -site:vulnweb.com` | | |
| Dork de la GHDB elegido: | — | Por qué es peligroso: |

### Subdominios por fuente

| Subdominio | crt.sh | theHarvester | Dorks |
|---|---|---|---|
| | | | |
| | | | |
| | | | |

### DNS

- MX (¿quién recibe su correo?):
- TXT (¿qué servicios usan?):
- AXFR de zonetransfer.me: N.° de registros = ____ · registro que una empresa no querría publicar:

### Tecnologías (BuiltWith / Wappalyzer / whatweb)

| Tecnología | Versión | Fuente |
|---|---|---|
| | | |
| | | |

## Lab 2 · Shodan y Censys

| Consulta | N.° resultados | Observación |
|---|---|---|
| `country:PE port:3389` | | |
| `country:PE port:445` | | |
| `country:PE "220" "vsftpd 2.3.4"` | | |
| `country:PE product:"Apache httpd"` | | versión más común: |

- InternetDB de 45.33.32.156 (puertos y CVE):
- Censys de 45.33.32.156 (¿coincide?):
- Mi consulta convertida a CenQL:

## Lab 3 · Mi huella digital

> No pegues aquí datos sensibles tuyos: solo conteos y conclusiones.

| Herramienta | Cuentas "encontradas" | Verificadas a mano | Falsos positivos |
|---|---|---|---|
| WhatsMyName | | | |
| Namechk | | | |
| Maigret | | | |
| Blackbird | | | |
| holehe | | | |

- Have I Been Pwned: ¿en cuántas filtraciones aparece mi correo?
- Tres cosas que voy a cerrar o cambiar después de esta clase:
  1.
  2.
  3.

## Lab 4 · Imágenes

### foto-oficina.jpg

- Autor:
- Teléfono:
- Fecha y hora:
- Coordenadas (decimales):
- Lugar exacto:
- Información sensible visible en la imagen:

### comunicado-editado.jpg

- Software y fecha de última modificación:
- Zona alterada según el ELA:
- Qué decía probablemente antes:

### Búsqueda inversa

| | TinEye | Google Lens |
|---|---|---|
| ¿Encontró la fuente original? | | |
| ¿Identificó el lugar? | | |
| ¿Qué cambió al recortarla? | | |
