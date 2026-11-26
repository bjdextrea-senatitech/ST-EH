#!/bin/bash
rm -f /var/run/xrdp/xrdp*.pid /var/run/xrdp*.pid 2>/dev/null
echo 'QHAPAQ{49-rdp-credencial-debil}' > /home/gerencia/Escritorio-bandera.txt 2>/dev/null || true
mkdir -p /home/gerencia/Desktop; echo 'QHAPAQ{49-rdp-credencial-debil}' > /home/gerencia/Desktop/bandera.txt; chown -R gerencia:gerencia /home/gerencia
service dbus start 2>/dev/null
/usr/sbin/xrdp-sesman
exec /usr/sbin/xrdp --nodaemon
