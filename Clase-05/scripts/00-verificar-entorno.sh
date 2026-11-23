#!/usr/bin/env bash
# Clase 05 - Verificador de entorno. No ataca nada.
set -u
ok(){ printf '  [ OK ] %s\n' "$1"; }
no(){ printf '  [FALTA] %s\n' "$1"; F=$((F+1)); }
F=0
echo "== Herramientas web =="
for h in curl sqlmap ffuf hashcat; do
  if command -v "$h" >/dev/null 2>&1; then ok "$h"; else no "$h"; fi
done
echo "== Proxy de intercepción (al menos uno) =="
if command -v burpsuite >/dev/null 2>&1 || command -v caido >/dev/null 2>&1 || command -v zaproxy >/dev/null 2>&1; then
  ok "proxy disponible (burp/caido/zap)"
else no "ninguno de burpsuite/caido/zaproxy en PATH (Burp suele abrirse desde el menu)"; fi
echo "== Docker dentro de Kali =="
if command -v docker >/dev/null 2>&1; then ok "docker"
  if docker info >/dev/null 2>&1; then ok "daemon activo"; else no "daemon apagado -> sudo service docker start"; fi
  if docker compose version >/dev/null 2>&1; then ok "docker compose v2"; else no "docker compose v2"; fi
else no "docker (instala docker.io DENTRO de Kali)"; fi
echo "== Portal en pie (opcional, si ya lo levantaste) =="
if curl -s -m 3 http://10.50.0.10:5000/ 2>/dev/null | grep -q "Qhapaq"; then ok "portal responde en 10.50.0.10:5000"
else printf '  [i] portal aun no levantado (cd objetivo && docker compose up -d --build)\n'; fi
echo
if [ "$F" -eq 0 ]; then echo "Listo."; else echo "Faltan $F elemento(s)."; exit 1; fi
