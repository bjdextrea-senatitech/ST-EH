# Bitácora — Clase 05 · Explotación de servicios
**Alumno:** ____________________  **Fecha:** __________  **Kali:** 2026

> Por cada bandera: escaneo → enumeración → explotación (con hora) → CVE o mala práctica + remediación.

## 🚩 QHAPAQ{__-________}  (host 10.55.0.__ , servicio ______)
- **Escaneo:** `nmap ...`
```
(pega la salida: puerto + versión)
```
- **Enumeración:** (usuario / recurso / versión / config hallada)
- **Explotación:** `...`  — hora: `date -Is` → __________
```
(evidencia: id / contenido de la bandera / Access-Accept, etc.)
```
- **Tipo:** ☐ CVE (____________)  ☐ Mala práctica
- **Remediación:** ______________________________________________

---
(repite el bloque por cada bandera)

## Resumen
| 🚩 | Servicio | CVE/misconfig | Lograda |
|----|----------|---------------|---------|
| 41 | WinRM/OMI | CVE-2021-38647 | ☐ |
| 42 | SMB/rpcclient | misconfig | ☐ |
| 43 | Kerberos | misconfig (AS-REP) | ☐ |
| 44 | Kerberos | misconfig (SPN) | ☐ |
| 45 | SYSVOL/GPP | MS14-025 | ☐ |
| 46 | SMB/AD | PtH/DCSync | ☐ |
| 47 | FTP | CVE-2015-3306 | ☐ |
| 48/48b | SSH | misconfig + sudo | ☐ |
| 49 | RDP | misconfig | ☐ |
| 50/50a | MySQL | misconfig (FILE) | ☐ |
| 51 | PostgreSQL | CVE-2019-9193 | ☐ |
| 52/52b | MSSQL | misconfig (xp_cmdshell) | ☐ |
| 53 | HTTP | CVE-2014-6271 | ☐ |
| 54 | HTTPS | CVE-2014-0160 | ☐ |
| 55 | Redis | misconfig (sin auth) | ☐ |
| 56 | MongoDB | misconfig (sin auth) | ☐ |
| 57/57a | SNMP | misconfig (community) | ☐ |
| 58 | VNC | misconfig (pass débil) | ☐ |
| 59 | VoIP | misconfig (SIP) | ☐ |
| 60 | RADIUS | misconfig (secreto) | ☐ |
| 61 | Impresoras | misconfig (IPP/9100) | ☐ |
| 62 | SMTP | misconfig (relay/VRFY) | ☐ |

## Reto Ollama 🤖
- Salida de `triage.sh`: (adjunta)
- ¿El modelo acertó / alucinó? ______________________________________
- Mi mejora al prompt: ______________________________________________
