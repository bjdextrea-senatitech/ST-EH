#!/usr/bin/env bash
# Verificador de entorno — Clase 05 (Explotación de servicios)
# Uso: bash scripts/00-verificar-entorno.sh
set -u
ok(){ printf '  \033[32m[OK]\033[0m %s\n' "$1"; }
no(){ printf '  \033[31m[--]\033[0m %s\n' "$1"; FALTA=1; }
FALTA=0
echo "== Herramientas de ataque en Kali =="
for t in nmap hydra smbclient rpcclient hashcat john redis-cli mysql psql snmpwalk snmpget \
         onesixtyone radtest swaks svwar svcrack vncviewer xfreerdp curl nc ssh ssh-keygen \
         gpp-decrypt mongosh; do
  command -v "$t" >/dev/null 2>&1 && ok "$t" || no "$t  (falta: apt install / pipx)"
done
echo "== Impacket (scripts clave) =="
for t in impacket-GetNPUsers impacket-GetUserSPNs impacket-secretsdump impacket-smbclient impacket-mssqlclient; do
  command -v "$t" >/dev/null 2>&1 && ok "$t" || no "$t  (pipx install impacket)"
done
echo "== Diccionario =="
if [ -f /usr/share/wordlists/rockyou.txt ]; then ok "rockyou.txt"
elif [ -f /usr/share/wordlists/rockyou.txt.gz ]; then no "rockyou.txt.gz sin descomprimir -> sudo gunzip -k /usr/share/wordlists/rockyou.txt.gz"
else no "rockyou.txt (apt install wordlists)"; fi
echo "== Docker dentro de Kali =="
if command -v docker >/dev/null 2>&1; then ok "docker ($(docker --version | awk '{print $3}' | tr -d ,))"
  docker info >/dev/null 2>&1 && ok "daemon docker corriendo" || no "daemon docker apagado -> sudo service docker start"
  docker compose version >/dev/null 2>&1 && ok "docker compose v2" || no "falta docker compose v2 (apt install docker-compose-plugin)"
else no "docker (apt install docker.io docker-compose-plugin)"; fi
echo "== Laboratorio arriba (opcional) =="
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q qx-; then
  N=$(docker ps --format '{{.Names}}' | grep -c qx-); ok "$N contenedores qx-* arriba"
  echo "  IPs:"; docker network inspect qhapaq-sede -f '{{range .Containers}}    {{.Name}} {{.IPv4Address}}{{"\n"}}{{end}}' 2>/dev/null
else echo "  (aún no levantas el lab: cd objetivo && docker compose up -d --build)"; fi
echo
[ "$FALTA" = 0 ] && echo -e "\033[32mEntorno listo.\033[0m" || echo -e "\033[33mInstala lo marcado [--] antes de empezar.\033[0m"
echo "Instalación rápida en Kali:"
echo "  sudo apt update && sudo apt install -y nmap hydra smbclient samba-common-bin hashcat john \\"
echo "     redis-tools default-mysql-client postgresql-client snmp onesixtyone freeradius-utils \\"
echo "     swaks sipvicious tigervnc-viewer freerdp2-x11 netcat-openbsd wordlists docker.io docker-compose-plugin"
echo "  pipx install impacket    # GetNPUsers, GetUserSPNs, secretsdump, mssqlclient..."
echo "  # mongosh: paquete mongodb-mongosh de MongoDB; gpp-decrypt ya viene en Kali"
