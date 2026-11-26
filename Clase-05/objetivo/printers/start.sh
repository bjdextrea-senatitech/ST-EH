#!/bin/bash
echo 'QHAPAQ{61-cups-ipp-impresora-expuesta}' > /opt/flag-cups.txt; chmod 644 /opt/flag-cups.txt
# CUPS escuchando en toda la red, admin web sin TLS, compartido
sed -i 's/^Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf 2>/dev/null
sed -i 's/Browsing No/Browsing Yes/' /etc/cups/cupsd.conf 2>/dev/null
# Permitir acceso remoto al panel y a los recursos
perl -0pi -e 's/<Location \/>\s*\n\s*Order allow,deny\n/<Location \/>\n  Order allow,deny\n  Allow all\n/g' /etc/cups/cupsd.conf 2>/dev/null
cupsd
sleep 3
# Cola de impresora "cruda" (raw) sobre socket 9100 interno + una compartida
lpadmin -p RecepcionHP -E -v socket://localhost:9100 -m raw -D "Recepcion - cola de impresion RRHH" -L "Oficina 2 - nota TI: clave panel QHAPAQ{61-cups-ipp-impresora-expuesta}" 2>/dev/null
lpadmin -p Contabilidad -E -v socket://localhost:9100 -m raw 2>/dev/null
cupsctl --share-printers 2>/dev/null
# Listener crudo 9100 (PJL/PostScript) que guarda lo que reciba
( while true; do nc -l -p 9100 -q1 >> /tmp/spool-9100.raw 2>/dev/null || sleep 1; done ) &
cupsctl 2>/dev/null
tail -F /var/log/cups/error_log 2>/dev/null
