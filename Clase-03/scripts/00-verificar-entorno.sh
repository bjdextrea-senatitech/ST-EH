#!/usr/bin/env bash
# Clase 03 · Verifica herramientas y la red interna de Inversiones Qhapaq.
# Solo LEE: no modifica nada y no toca el servidor fuera de alcance (10.30.0.250).

ok=0
fallas=0

bien() { printf '  \033[32m[OK]\033[0m    %s\n' "$1"; ok=$((ok + 1)); }
mal()  { printf '  \033[31m[FALTA]\033[0m %s\n' "$1"; printf '          -> %s\n' "$2"; fallas=$((fallas + 1)); }

echo
echo "== 1. Herramientas del sistema =="
for herramienta in docker nmap dig curl nc openssl smbclient snmpwalk onesixtyone redis-cli whatweb exiftool xsltproc theHarvester git; do
  if command -v "$herramienta" >/dev/null 2>&1; then
    bien "$herramienta"
  else
    mal "$herramienta" "revisa el 'sudo apt install' del Lab 0.1"
  fi
done

if docker compose version >/dev/null 2>&1; then
  bien "docker compose (plugin)"
elif command -v docker-compose >/dev/null 2>&1; then
  bien "docker-compose (con guion): úsalo en lugar de 'docker compose'"
else
  mal "docker compose" "sudo apt install -y docker-compose"
fi

echo
echo "== 2. Herramientas OSINT de Python =="
for herramienta in maigret holehe; do
  if command -v "$herramienta" >/dev/null 2>&1; then
    bien "$herramienta"
  else
    mal "$herramienta" "pipx install $herramienta  (y luego: pipx ensurepath)"
  fi
done

if [ -x "$HOME/blackbird/.venv/bin/python" ] && [ -f "$HOME/blackbird/blackbird.py" ]; then
  bien "blackbird (~/blackbird con .venv)"
else
  mal "blackbird" "revisa el Lab 0.2: git clone + python3 -m venv + pip install -r"
fi

echo
echo "== 3. Docker y contenedores =="
if docker info >/dev/null 2>&1; then
  bien "puedes usar Docker sin sudo"
else
  mal "no puedes hablar con Docker" "sudo usermod -aG docker \$USER  y vuelve a iniciar sesión"
fi

for contenedor in qi-ns1 qi-www qi-mail qi-files qi-db qi-monitor qi-erp; do
  estado=$(docker inspect -f '{{.State.Status}}' "$contenedor" 2>/dev/null)
  if [ "$estado" = "running" ]; then
    bien "contenedor $contenedor corriendo"
  else
    mal "contenedor $contenedor (${estado:-no existe})" "cd ~/Clase-03/objetivo && docker compose up -d --build"
  fi
done

echo
echo "== 4. Objetivos en alcance (TCP) =="
probar_puerto() {
  timeout 3 bash -c "exec 3<>/dev/tcp/$1/$2" 2>/dev/null
}
for objetivo in 10.30.0.53:53 10.30.0.10:80 10.30.0.10:443 10.30.0.25:25 10.30.0.45:445 10.30.0.60:6379; do
  ip=${objetivo%%:*}
  puerto=${objetivo##*:}
  if probar_puerto "$ip" "$puerto"; then
    bien "$ip responde en el puerto $puerto"
  else
    mal "$ip no responde en el puerto $puerto" "docker compose ps  /  docker compose restart"
  fi
done

echo
echo "  (SNMP en 10.30.0.161 es UDP: se prueba en el Lab 5. 10.30.0.250 NO se prueba: está fuera de alcance)"
echo
echo "== Resultado: $ok correctos, $fallas por resolver =="
if [ "$fallas" -eq 0 ]; then
  echo "   Listo para la clase."
else
  echo "   Resuelve lo que falta antes de la clase."
fi
echo
