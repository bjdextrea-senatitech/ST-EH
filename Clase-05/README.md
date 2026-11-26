# Clase 05 — Explotación de Servicios (SENATI Tech · Módulo 05)

Laboratorio **100% ofensivo** y **dockerizado**, pensado para 180 min dentro de **Kali Linux 2026**.
Cubre la explotación de 20+ servicios con la misma metodología de 4 pasos
(escaneo → detección → enumeración → explotación por **CVE** o **mala práctica**).

## Contenido
```
Clase-05/
├── README.md
├── teoria-breve.md                 # teoría mínima (15 min)
├── laboratorio-clase05.md          # GUÍA del laboratorio (3 horas, paso a paso)
├── chuleta-comandos.md             # todos los comandos de un vistazo (incl. ver IP de contenedores)
├── Clase05_Explotacion_de_Servicios.pptx
├── scripts/
│   └── 00-verificar-entorno.sh     # comprueba las herramientas de tu Kali
├── herramientas/
│   ├── omigod.xml                  # payload OMIGOD (WinRM/OMI)
│   └── heartbleed.py               # PoC didáctico de Heartbleed
├── reto-ollama/                    # reto final: triage con IA local
│   ├── 00-instalar-ollama.sh
│   ├── triage.sh
│   └── README.md
├── plantillas/
│   └── bitacora-clase05.md         # formato de entrega
├── objetivo/                       # EL LABORATORIO (docker compose)
│   ├── docker-compose.yml          # 15 servicios core + 2 de nube (perfil "nube")
│   └── <un directorio por servicio con su Dockerfile>
└── solucion-docente/               # SOLUCIONARIO (en .gitignore: no subir a GitHub)
```

## Arranque rápido (en Kali, como root)
```bash
sudo service docker start
cd objetivo
docker compose up -d --build        # primera vez ~15-20 min (necesita internet)
docker compose ps
docker network inspect qhapaq-sede -f '{{range .Containers}}{{.Name}} {{.IPv4Address}}{{"\n"}}{{end}}'
```
Opcional (imágenes grandes): `docker compose --profile nube up -d`  → agrega MSSQL y MongoDB.

## Notas
- Todas las imágenes parten de `ubuntu:14.04/20.04/24.04` de Docker Hub; MSSQL y Mongo usan imágenes oficiales.
- Las banderas (`QHAPAQ{...}`) están en el código fuente de `objetivo/`: se evalúa la **bitácora con hora**, no la bandera.
- Primer arranque: `qx-legacy` recompila OpenSSL (Heartbleed) y `qx-dc01` aprovisiona el dominio. Es normal que tarden 1–4 min.
- `solucion-docente/` está en `.gitignore`: no se sube al repositorio de los alumnos.
