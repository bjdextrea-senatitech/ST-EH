# Clase 04 · Explotación de Servicios

Material de la clase. Orden sugerido:
1. `laboratorio-clase04.md` — la guía paso a paso (lo que sigue el alumno).
2. `recetario-nmap.md` — 80 ejemplos de nmap, referencia de consulta.
3. `plantillas/bitacora-explotacion.md` — para la entrega.
4. `Clase04_Explotacion_de_Servicios.pptx` — diapositivas.

## Montar el laboratorio (Docker DENTRO de Kali)
```bash
cd objetivo
docker compose up -d --build          # 7 servicios en la red 10.40.0.0/24
docker compose --profile mssql up -d  # opcional: añade SQL Server (.14)
docker compose ps
```
Verifica tu equipo antes: `./scripts/00-verificar-entorno.sh`

> `solucion-docente/` está en `.gitignore`: NO lo subas al repo del alumno.
