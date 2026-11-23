#!/usr/bin/env bash
# Clase 04 - Verificador de entorno. No ataca nada: solo comprueba que tienes las herramientas.
set -u
ok(){ printf '  [ OK ] %s\n' "$1"; }
no(){ printf '  [FALTA] %s\n' "$1"; FALLos=$((FALLos+1)); }
FALLos=0

echo "== Herramientas de hoy =="
for h in nmap nc hydra smbclient mysql redis-cli john ssh ssh2john tftp msfconsole; do
  if command -v "$h" >/dev/null 2>&1; then ok "$h"; else no "$h (apt install / parte de Kali)"; fi
done

echo "== Docker dentro de Kali =="
if command -v docker >/dev/null 2>&1; then ok "docker instalado"
  if docker info >/dev/null 2>&1; then ok "daemon de docker activo"
  else no "daemon docker apagado -> 'sudo service docker start'"; fi
  if docker compose version >/dev/null 2>&1; then ok "docker compose v2"; else no "docker compose v2"; fi
else no "docker (instala docker.io DENTRO de Kali, no Docker Desktop)"; fi

echo "== Diccionario rockyou =="
if [ -f /usr/share/wordlists/rockyou.txt ]; then ok "rockyou.txt"
elif [ -f /usr/share/wordlists/rockyou.txt.gz ]; then no "rockyou.txt.gz -> 'gunzip /usr/share/wordlists/rockyou.txt.gz'"
else no "rockyou.txt (apt install wordlists)"; fi

echo
if [ "$FALLos" -eq 0 ]; then echo "Todo listo. Levanta el lab: cd objetivo && docker compose up -d --build"
else echo "Faltan $FALLos elemento(s). Revísalos antes de empezar."; exit 1; fi
