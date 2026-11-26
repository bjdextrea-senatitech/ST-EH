#!/bin/bash
mkdir -p /root/.vnc /root/.flag
echo 'QHAPAQ{58-vnc-password-debil}' > /root/Escritorio-bandera.txt
# Password VNC debil (8 chars max en el protocolo clasico)
x11vnc -storepasswd 'monkey12' /root/.vnc/passwd >/dev/null 2>&1
# Un escritorio minimo con Xvfb para que haya algo que ver
Xvfb :1 -screen 0 1024x768x16 >/dev/null 2>&1 &
sleep 2
DISPLAY=:1 xterm -geometry 100x30 -e "cat /root/Escritorio-bandera.txt; bash" >/dev/null 2>&1 &
exec x11vnc -display :1 -rfbauth /root/.vnc/passwd -forever -shared -rfbport 5900 -o /var/log/x11vnc.log
