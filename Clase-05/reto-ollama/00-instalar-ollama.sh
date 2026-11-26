#!/usr/bin/env bash
# Instala Ollama (LLM local, todo offline) y un modelo pequeno para triage. Ejecutar en Kali.
set -e
if ! command -v ollama >/dev/null 2>&1; then
  echo "[*] Instalando Ollama..."
  curl -fsSL https://ollama.com/install.sh | sh
fi
# arrancar el servicio en segundo plano si no corre
pgrep -x ollama >/dev/null || (ollama serve >/tmp/ollama.log 2>&1 &) ; sleep 3
MODELO="${1:-llama3.2:3b}"   # pequeno y rapido; alternativas: qwen2.5:3b, phi3:mini
echo "[*] Descargando modelo $MODELO (una sola vez)..."
ollama pull "$MODELO"
echo "[OK] Listo. Modelo: $MODELO"
