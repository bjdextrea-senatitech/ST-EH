# Clase 05 · Ataques a Web y APIs

Material de la clase. Orden sugerido:
1. `laboratorio-clase05.md` — la guía paso a paso.
2. `chuleta-payloads.md` — payloads listos para Burp/curl.
3. `plantillas/hallazgo-web.md` — para la entrega.
4. `Clase05_Ataques_Web_y_APIs.pptx` — diapositivas.

## Montar el laboratorio (Docker DENTRO de Kali)
```bash
cd objetivo
docker compose up -d --build                 # portal Flask en 10.50.0.10:5000 y localhost:5000
docker compose --profile juice up -d         # opcional: OWASP Juice Shop en localhost:3000
```
Verifica tu equipo antes: `./scripts/00-verificar-entorno.sh`

> `solucion-docente/` está en `.gitignore`: NO lo subas al repo del alumno.
