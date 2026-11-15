#!/bin/bash
/usr/sbin/sshd

# Redis sin contraseña y escuchando en todas las interfaces (error intencional)
redis-server --bind 0.0.0.0 --protected-mode no --port 6379 --save '' --daemonize no &
sleep 1
redis-cli SET app:nombre "Portal de inversiones Qhapaq" >/dev/null
redis-cli SET app:entorno "produccion" >/dev/null
redis-cli SET flag "QHAPAQ{09-redis-sin-autenticacion}" >/dev/null
redis-cli SET sesion:jdiaz "token=7f3a9c...expira=2026-12-31" >/dev/null

# Agente de backup "propio" con un banner que nmap no reconoce
socat TCP-LISTEN:48620,fork,reuseaddr \
  SYSTEM:'echo "QBA/1.2 Qhapaq Backup Agent listo - build 2019-03 - QHAPAQ{10-banner-grabbing}"' &

wait -n
