#!/bin/bash
cat > /etc/freeradius/3.0/clients.conf <<CL
client all {
    ipaddr = 0.0.0.0/0
    secret = testing123
    require_message_authenticator = no
}
CL
cat > /etc/freeradius/3.0/mods-config/files/authorize <<US
admin-wifi Cleartext-Password := "Wifi.Qhapaq!2026"
    Reply-Message := "QHAPAQ{60-radius-secreto-compartido-debil}"
soporte-vpn Cleartext-Password := "Soporte2026"
US
F=/etc/freeradius/3.0/sites-enabled/default
# Eliminar SOLO los bloques "listen { ... }" que contengan ipv6addr (contador de llaves, respeta anidado)
awk '
/^[[:space:]]*listen[[:space:]]*\{/ && depth==0 { buf=$0"\n"; depth=1; v6=0; next }
depth>0 {
  buf=buf $0"\n";
  if ($0 ~ /^[[:space:]]*ipv6addr/) v6=1;
  n=gsub(/\{/,"{"); m=gsub(/\}/,"}"); depth+=n-m;
  if (depth==0) { if(!v6) printf "%s", buf; buf="" }
  next
}
{ print }
' "$F" > /tmp/d && mv /tmp/d "$F"
chown -R freerad:freerad /etc/freeradius/3.0 2>/dev/null
exec freeradius -f -l stdout
