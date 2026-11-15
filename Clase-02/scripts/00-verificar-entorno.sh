#!/usr/bin/env bash
# Clase 02 · Verifica que tu VM está lista para el pentest de Inversiones Qhapaq.
# Solo LEE: no modifica nada y no toca el servidor fuera de alcance (172.30.0.30).

ok=0
fallas=0

bien()  { printf '  \033[32m[OK]\033[0m    %s\n' "$1"; ok=$((ok + 1)); }
mal()   { printf '  \033[31m[FALTA]\033[0m %s\n' "$1"; printf '          -> %s\n' "$2"; fallas=$((fallas + 1)); }

echo
echo "== 1. Herramientas =="
for herramienta in docker nmap curl ssh script sha256sum; do
  if command -v "$herramienta" >/dev/null 2>&1; then
    bien "$herramienta"
  else
    mal "$herramienta" "sudo apt install -y $herramienta   (docker -> docker.io, script -> bsdutils)"
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
echo "== 2. Docker =="
if docker info >/dev/null 2>&1; then
  bien "puedes usar Docker sin sudo"
else
  mal "no puedes hablar con Docker" "sudo usermod -aG docker \$USER  y vuelve a iniciar sesión"
fi

for contenedor in qhapaq-web qhapaq-files qhapaq-erp; do
  estado=$(docker inspect -f '{{.State.Status}}' "$contenedor" 2>/dev/null)
  if [ "$estado" = "running" ]; then
    bien "contenedor $contenedor corriendo"
  else
    mal "contenedor $contenedor (${estado:-no existe})" "cd ~/Clase-02/objetivo && docker compose up -d --build"
  fi
done

echo
echo "== 3. Objetivos en alcance =="
probar_puerto() {
  timeout 3 bash -c "exec 3<>/dev/tcp/$1/$2" 2>/dev/null
}
for objetivo in 172.30.0.10:80 172.30.0.20:21 172.30.0.20:22; do
  ip=${objetivo%%:*}
  puerto=${objetivo##*:}
  if probar_puerto "$ip" "$puerto"; then
    bien "$ip responde en el puerto $puerto"
  else
    mal "$ip no responde en el puerto $puerto" "docker compose ps  /  docker compose restart"
  fi
done

echo
echo "  (172.30.0.30 NO se prueba: está fuera de alcance)"
echo
echo "== Resultado: $ok correctos, $fallas por resolver =="
[ "$fallas" -eq 0 ] && echo "   Listo para el Lab 1." || echo "   Resuelve lo que falta antes de seguir."
echo
