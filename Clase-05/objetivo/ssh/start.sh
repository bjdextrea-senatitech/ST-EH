#!/bin/bash
mkdir -p /var/run/sshd
echo 'QHAPAQ{48-ssh-credencial-debil-fuerza-bruta}' > /home/soporte/flag-user.txt 2>/dev/null
echo 'QHAPAQ{48b-ssh-escalada-sudo-tar}' > /root/flag-root.txt; chmod 600 /root/flag-root.txt
exec /usr/sbin/sshd -D -e
