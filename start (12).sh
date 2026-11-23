#!/bin/bash
mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld
mysqld_safe >/dev/null 2>&1 &
for _ in $(seq 1 30); do mysqladmin ping >/dev/null 2>&1 && break; sleep 1; done
# Carga los datos solo la primera vez (evita filas duplicadas al reiniciar)
if [ ! -f /var/lib/mysql/.qhapaq ]; then mysql < /opt/init.sql && touch /var/lib/mysql/.qhapaq; fi
exec apachectl -D FOREGROUND
