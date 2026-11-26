#!/usr/bin/env bash
# Reto: copiloto de triage con IA LOCAL.
# 1) escanea el rango  2) resume servicios  3) le pide al LLM que priorice el ataque.
# Uso: bash triage.sh 10.55.0.0/24 [modelo]
set -u
RANGO="${1:-10.55.0.0/24}"
MODELO="${2:-llama3.2:3b}"
OUT="scan-$(date +%H%M%S).txt"
echo "[*] Escaneando $RANGO (esto tarda un poco)..."
nmap -sV -T4 --open -oN "$OUT" "$RANGO" >/dev/null 2>&1
echo "[*] Servicios detectados -> $OUT"
RESUMEN=$(grep -E "Nmap scan report|/tcp|/udp" "$OUT")

PROMPT=$(cat <<P
Eres un asistente de un pentester con autorizacion escrita sobre la red de laboratorio QHAPAQ (10.55.0.0/24).
A continuacion esta la salida resumida de un escaneo nmap. Para CADA host:
- di que servicio y version hay,
- si hay un CVE conocido famoso o una mala practica tipica asociada a esa version,
- y que herramienta concreta usarias primero (nmap NSE, hydra, impacket, redis-cli, etc).
Ordena los objetivos de MAS a MENOS prometedor. Responde en espanol, en vinetas, sin inventar versiones.
No ejecutes nada: solo prioriza y sugiere. La decision y la ejecucion las hace el humano.

SALIDA NMAP:
$RESUMEN
P
)
echo "[*] Pidiendo priorizacion al modelo local $MODELO ..."
echo "----------------------------------------------------------------"
ollama run "$MODELO" "$PROMPT"
echo "----------------------------------------------------------------"
echo "[!] Recuerda: el LLM es un COPILOTO. Verifica cada sugerencia; el ataque real y su permiso son tuyos."
