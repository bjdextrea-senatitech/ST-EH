# Clase 03 · Reconocimiento y enumeración

**SENATI · DC05 Ethical Hacking y Seguridad Ofensiva · Capítulo 3 del sílabo**
Reconocimiento pasivo y activo · Google Dorking · OSINT · Shodan · theHarvester · Nmap avanzado · Fingerprinting de servicios.

Primero miras sin tocar (organizaciones, personas e imágenes). Después enumeras servicio por servicio la red interna de *Inversiones Qhapaq SAC*. Entregas un mapa de la superficie de ataque.

| Archivo | Qué es |
|---|---|
| `Clase03_Reconocimiento_y_Enumeracion.pptx` | Teoría (~20 min) |
| `laboratorio-clase03.md` | **La guía del laboratorio** (240 min) |
| `objetivo/` | Red interna de Qhapaq: DNS, web, correo, archivos, base de datos, monitoreo y un servidor de terceros |
| `casos/imagenes/` | Dos imágenes "filtradas" para el OSINT de imágenes |
| `scripts/00-verificar-entorno.sh` | Revisa herramientas, Docker y objetivos (solo lee) |
| `plantillas/bitacora-osint.md` | Bitácora de los Labs 1 a 4 |
| `plantillas/mapa-superficie.md` | Entregable final |

**Antes de la clase** (dentro de Kali, con la carpeta en `~/Clase-03`): sigue el Lab 0 de la guía y termina con

```bash
cd ~/Clase-03/objetivo
docker compose up -d --build
bash ../scripts/00-verificar-entorno.sh
```

> Las herramientas de personas se usan **solo con tu propio usuario y correo**. `10.30.0.250` está **fuera de alcance**.
