# Bitácora de explotación — Clase 04
**Alumno:** ____________________  **Fecha:** __________  **Alcance:** red 10.40.0.0/24 (laboratorio autorizado)

> Una ficha por host. Pega el comando, su `date -Is` y la evidencia (salida de `id` o la bandera con su hora).

---

## Host 10.40.0.___  ·  Servicio: ____________
- **Descubrimiento (comando nmap + hora):**
  ```
  ```
- **Versión detectada:**
- **Tipo de falla:**  ☐ CVE ____________  ☐ Credencial débil  ☐ Mala configuración
- **Explotación (comandos):**
  ```
  ```
- **Evidencia de acceso (id / bandera + hora):**
  ```
  ```
- **Recomendación de remediación (1 línea):**

---
_(repite la ficha para cada host: .5 .21 .45 .22 .33 .63 .38)_

## Resumen
| Host | Servicio | Falla | Bandera | Acceso logrado |
|------|----------|-------|---------|----------------|
| .5   | firewall/tftp |   | 11, 12 |   |
| .21  | vsftpd 2.3.4  |   | 13 |   |
| .45  | smb           |   | 14 |   |
| .22  | ssh           |   | 15,16,17 |   |
| .33  | mysql/web     |   | 18,19 |   |
| .63  | redis         |   | 21 |   |
| .38  | rdp           |   | 20 |   |
